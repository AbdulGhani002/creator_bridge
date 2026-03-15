from fastapi import APIRouter, HTTPException, Depends
from typing import List
from motor.motor_asyncio import AsyncIOMotorDatabase
from database import get_database
from datetime import datetime

DEFAULT_PLANS = [
    {
        "name": "Basic",
        "price": 0,
        "period": "mo",
        "description": "Perfect for hobbyists just starting out.",
        "features": ["Standard Profile Page", "Basic Analytics", "Search Visibility"],
        "highlighted": False
    },
    {
        "name": "Pro",
        "price": 19,
        "period": "mo",
        "description": "Get discovered by brands and followers.",
        "features": ["Everything in Basic", "Appear in Search Results", "Advanced Audience Insights", "Custom Profile URL"],
        "highlighted": True
    },
    {
        "name": "Premium",
        "price": 49,
        "period": "mo",
        "description": "Maximum exposure for top creators.",
        "features": ["Everything in Pro", "Featured Listing (Top 1%)", "Ad-free Profile for Fans", "Priority Support 24/7"],
        "highlighted": False
    }
]

class PlanService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.collection = db.plans

    async def list_plans(self) -> List[dict]:
        plans = await self.collection.find({}).to_list(length=100)
        return plans

router = APIRouter(prefix="/plans", tags=["plans"])

def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc

async def get_plan_service(db: AsyncIOMotorDatabase = Depends(get_database)) -> PlanService:
    return PlanService(db)

@router.get("/", response_model=dict)
async def list_plans(service: PlanService = Depends(get_plan_service)) -> dict:
    try:
        plans = await service.list_plans()
        if not plans:
            return {"plans": DEFAULT_PLANS, "count": len(DEFAULT_PLANS)}
        plans = [normalize_id(p) for p in plans]
        return {"plans": plans, "count": len(plans)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
