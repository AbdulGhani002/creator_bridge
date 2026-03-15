from fastapi import APIRouter, HTTPException, Depends, Query, Path
from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import datetime
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_database
from security import get_current_user

AgreementStatus = Literal["draft", "sent", "accepted", "declined", "completed", "canceled"]


class AgreementCreate(BaseModel):
    campaign_id: str
    creator_id: str
    deliverables: str = Field(..., min_length=5, max_length=2000)
    deadline: Optional[datetime] = None
    payment_amount: float = Field(..., ge=0)
    terms: Optional[str] = None


class AgreementUpdate(BaseModel):
    deliverables: Optional[str] = None
    deadline: Optional[datetime] = None
    payment_amount: Optional[float] = None
    terms: Optional[str] = None
    status: Optional[AgreementStatus] = None


router = APIRouter(prefix="/agreements", tags=["agreements"])


def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc


@router.post("/", response_model=dict)
async def create_agreement(
    payload: AgreementCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    if current_user.get("role") != "brand":
        raise HTTPException(status_code=403, detail="Only brands can create agreements")

    agreement_doc = payload.dict()
    agreement_doc.update({
        "brand_id": current_user.get("id"),
        "status": "sent",
        "created_at": datetime.utcnow(),
        "updated_at": None
    })

    result = await db.agreements.insert_one(agreement_doc)
    return {"id": str(result.inserted_id), "status": "success", "message": "Agreement created"}


@router.get("/", response_model=dict)
async def list_agreements(
    campaign_id: Optional[str] = None,
    creator_id: Optional[str] = None,
    brand_id: Optional[str] = None,
    status: Optional[AgreementStatus] = None,
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

    if current_user.get("role") == "creator":
        query["creator_id"] = current_user.get("id")
    if current_user.get("role") == "brand":
        query["brand_id"] = current_user.get("id")

    items = await db.agreements.find(query).skip(skip).limit(limit).to_list(length=limit)
    items = [normalize_id(a) for a in items]
    total = await db.agreements.count_documents(query)
    return {"agreements": items, "total": total, "skip": skip, "limit": limit}


@router.put("/{agreement_id}", response_model=dict)
async def update_agreement(
    agreement_id: str = Path(..., description="Agreement ID"),
    payload: AgreementUpdate = None,
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    if not payload:
        raise HTTPException(status_code=400, detail="Missing update payload")

    try:
        agreement_obj_id = ObjectId(agreement_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid agreement id")

    agreement = await db.agreements.find_one({"_id": agreement_obj_id})
    if not agreement:
        raise HTTPException(status_code=404, detail="Agreement not found")

    if current_user.get("role") == "creator" and agreement.get("creator_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")
    if current_user.get("role") == "brand" and agreement.get("brand_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")

    update_data = payload.dict(exclude_unset=True)
    update_data["updated_at"] = datetime.utcnow()
    result = await db.agreements.update_one({"_id": agreement_obj_id}, {"$set": update_data})
    if result.modified_count == 0:
        raise HTTPException(status_code=400, detail="No changes applied")

    return {"status": "success", "message": "Agreement updated"}

