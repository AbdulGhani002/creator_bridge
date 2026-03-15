from fastapi import APIRouter, Depends
from datetime import datetime
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_database
from security import get_current_user


router = APIRouter(prefix="/analytics", tags=["analytics"])


@router.get("/creator/me", response_model=dict)
async def creator_analytics(
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    creator_id = current_user.get("id")
    applications = await db.applications.count_documents({"creator_id": creator_id})
    accepted = await db.applications.count_documents({"creator_id": creator_id, "status": "accepted"})
    agreements = await db.agreements.count_documents({"creator_id": creator_id})
    completed = await db.agreements.count_documents({"creator_id": creator_id, "status": "completed"})

    # earnings from agreements
    pipeline = [
        {"$match": {"creator_id": creator_id, "status": "completed"}},
        {"$group": {"_id": "$creator_id", "total": {"$sum": "$payment_amount"}}}
    ]
    agg = await db.agreements.aggregate(pipeline).to_list(length=1)
    total_earnings = agg[0]["total"] if agg else 0

    return {
        "creator_id": creator_id,
        "applications": applications,
        "accepted_applications": accepted,
        "agreements": agreements,
        "completed_agreements": completed,
        "total_earnings": total_earnings,
        "updated_at": datetime.utcnow().isoformat()
    }


@router.get("/brand/me", response_model=dict)
async def brand_analytics(
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    brand_id = current_user.get("id")
    campaigns = await db.campaigns.count_documents({"brand_id": brand_id})
    open_campaigns = await db.campaigns.count_documents({"brand_id": brand_id, "status": "open"})
    applications = await db.applications.count_documents({"brand_id": brand_id})
    accepted = await db.applications.count_documents({"brand_id": brand_id, "status": "accepted"})
    agreements = await db.agreements.count_documents({"brand_id": brand_id})
    completed = await db.agreements.count_documents({"brand_id": brand_id, "status": "completed"})

    return {
        "brand_id": brand_id,
        "campaigns": campaigns,
        "open_campaigns": open_campaigns,
        "applications": applications,
        "accepted_applications": accepted,
        "agreements": agreements,
        "completed_agreements": completed,
        "updated_at": datetime.utcnow().isoformat()
    }

