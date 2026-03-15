from fastapi import APIRouter, HTTPException, Depends, Query
from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import datetime
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_database
from security import get_current_user


RevieweeRole = Literal["creator", "brand"]


class ReviewCreate(BaseModel):
    reviewee_id: str
    reviewee_role: RevieweeRole
    rating: float = Field(..., ge=1, le=5)
    comment: Optional[str] = Field(default=None, max_length=2000)
    campaign_id: Optional[str] = None


router = APIRouter(prefix="/reviews", tags=["reviews"])


def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc


async def update_average_rating(db: AsyncIOMotorDatabase, reviewee_id: str, role: RevieweeRole):
    pipeline = [
        {"$match": {"reviewee_id": reviewee_id, "reviewee_role": role}},
        {"$group": {"_id": "$reviewee_id", "avg": {"$avg": "$rating"}, "count": {"$sum": 1}}}
    ]
    result = await db.reviews.aggregate(pipeline).to_list(length=1)
    if not result:
        return
    avg = round(result[0]["avg"], 2)
    count = result[0]["count"]
    if role == "creator":
        await db.creators.update_many({"user_id": reviewee_id}, {"$set": {"rating": avg, "reviews_count": count}})
    else:
        await db.brands.update_many({"user_id": reviewee_id}, {"$set": {"rating": avg, "reviews_count": count}})


@router.post("/", response_model=dict)
async def create_review(
    payload: ReviewCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    if payload.reviewee_id == current_user.get("id"):
        raise HTTPException(status_code=400, detail="You cannot review yourself")

    review_doc = payload.dict()
    review_doc.update({
        "reviewer_id": current_user.get("id"),
        "created_at": datetime.utcnow()
    })
    result = await db.reviews.insert_one(review_doc)

    await update_average_rating(db, payload.reviewee_id, payload.reviewee_role)

    return {"id": str(result.inserted_id), "status": "success", "message": "Review submitted"}


@router.get("/", response_model=dict)
async def list_reviews(
    reviewee_id: Optional[str] = None,
    reviewer_id: Optional[str] = None,
    reviewee_role: Optional[RevieweeRole] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    query = {}
    if reviewee_id:
        query["reviewee_id"] = reviewee_id
    if reviewer_id:
        query["reviewer_id"] = reviewer_id
    if reviewee_role:
        query["reviewee_role"] = reviewee_role

    items = await db.reviews.find(query).skip(skip).limit(limit).to_list(length=limit)
    items = [normalize_id(r) for r in items]
    total = await db.reviews.count_documents(query)
    return {"reviews": items, "total": total, "skip": skip, "limit": limit}

