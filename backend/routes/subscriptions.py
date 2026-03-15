from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional, Literal
from datetime import datetime
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_database
from security import get_current_user


class SubscriptionCreate(BaseModel):
    product_id: str
    transaction_id: str
    expires_at: Optional[datetime] = None
    plan: Literal["free", "pro", "premium"]


router = APIRouter(prefix="/subscriptions", tags=["subscriptions"])


@router.get("/me", response_model=dict)
async def get_subscription(
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    sub = await db.subscriptions.find_one({"user_id": current_user.get("id")})
    if not sub:
        return {"subscription": None}
    sub["_id"] = str(sub.get("_id"))
    sub["id"] = sub["_id"]
    return {"subscription": sub}


@router.post("/ios", response_model=dict)
async def save_ios_subscription(
    payload: SubscriptionCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    # NOTE: In production, validate with App Store before accepting.
    sub_doc = payload.dict()
    sub_doc.update({
        "user_id": current_user.get("id"),
        "platform": "ios",
        "updated_at": datetime.utcnow()
    })

    existing = await db.subscriptions.find_one({"user_id": current_user.get("id")})
    if existing:
        await db.subscriptions.update_one({"_id": existing["_id"]}, {"$set": sub_doc})
    else:
        sub_doc["created_at"] = datetime.utcnow()
        await db.subscriptions.insert_one(sub_doc)

    # Update creator profile tier if applicable
    if current_user.get("role") == "creator":
        await db.creators.update_many({"user_id": current_user.get("id")}, {"$set": {"subscription_tier": payload.plan}})

    return {"status": "success", "message": "Subscription updated"}

