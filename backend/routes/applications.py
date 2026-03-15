from fastapi import APIRouter, HTTPException, Depends, Query, Path
from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import datetime
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_database
from security import get_current_user


ApplicationStatus = Literal["pending", "accepted", "rejected", "completed", "withdrawn"]


class ApplicationCreate(BaseModel):
    campaign_id: str
    proposal: str = Field(..., min_length=10, max_length=2000)


class ApplicationUpdate(BaseModel):
    status: ApplicationStatus


router = APIRouter(prefix="/applications", tags=["applications"])


def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc


@router.post("/", response_model=dict)
async def create_application(
    payload: ApplicationCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    if current_user.get("role") != "creator":
        raise HTTPException(status_code=403, detail="Only creators can apply")

    try:
        campaign = await db.campaigns.find_one({"_id": ObjectId(payload.campaign_id)})
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid campaign id")

    if not campaign:
        raise HTTPException(status_code=404, detail="Campaign not found")

    existing = await db.applications.find_one({
        "campaign_id": payload.campaign_id,
        "creator_id": current_user.get("id")
    })
    if existing:
        raise HTTPException(status_code=400, detail="You already applied to this campaign")

    application_doc = {
        "campaign_id": payload.campaign_id,
        "creator_id": current_user.get("id"),
        "brand_id": campaign.get("brand_id"),
        "proposal": payload.proposal,
        "status": "pending",
        "created_at": datetime.utcnow(),
        "updated_at": None
    }
    result = await db.applications.insert_one(application_doc)

    # increment campaign application count
    await db.campaigns.update_one(
        {"_id": ObjectId(payload.campaign_id)},
        {"$inc": {"applications_count": 1}}
    )

    return {"id": str(result.inserted_id), "status": "success", "message": "Application submitted"}


@router.get("/", response_model=dict)
async def list_applications(
    campaign_id: Optional[str] = None,
    creator_id: Optional[str] = None,
    brand_id: Optional[str] = None,
    status: Optional[ApplicationStatus] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    query = {}
    if campaign_id:
        query["campaign_id"] = campaign_id
    if creator_id:
        query["creator_id"] = creator_id
    if brand_id:
        query["brand_id"] = brand_id
    if status:
        query["status"] = status

    # Enforce access rules
    if current_user.get("role") == "creator":
        query["creator_id"] = current_user.get("id")
    if current_user.get("role") == "brand":
        query["brand_id"] = current_user.get("id")

    items = await db.applications.find(query).skip(skip).limit(limit).to_list(length=limit)
    items = [normalize_id(a) for a in items]
    total = await db.applications.count_documents(query)
    return {"applications": items, "total": total, "skip": skip, "limit": limit}


@router.put("/{application_id}", response_model=dict)
async def update_application_status(
    application_id: str = Path(..., description="Application ID"),
    payload: ApplicationUpdate = None,
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    if not payload:
        raise HTTPException(status_code=400, detail="Missing update payload")

    # Only brand can accept/reject/complete; creator can withdraw
    if current_user.get("role") == "creator" and payload.status != "withdrawn":
        raise HTTPException(status_code=403, detail="Creators can only withdraw applications")

    if current_user.get("role") == "brand" and payload.status == "withdrawn":
        raise HTTPException(status_code=403, detail="Brands cannot withdraw applications")

    update = {
        "$set": {"status": payload.status, "updated_at": datetime.utcnow()}
    }

    try:
        app_obj_id = ObjectId(application_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid application id")

    # Access check
    application = await db.applications.find_one({"_id": app_obj_id})
    if not application:
        raise HTTPException(status_code=404, detail="Application not found")

    if current_user.get("role") == "creator" and application.get("creator_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")
    if current_user.get("role") == "brand" and application.get("brand_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")

    result = await db.applications.update_one({"_id": app_obj_id}, update)
    if result.modified_count == 0:
        raise HTTPException(status_code=400, detail="No changes applied")
    return {"status": "success", "message": "Application updated"}

