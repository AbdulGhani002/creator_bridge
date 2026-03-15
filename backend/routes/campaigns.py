from fastapi import APIRouter, HTTPException, Depends, Query, Path
from typing import Optional, List
from bson import ObjectId
from datetime import datetime
from pydantic import BaseModel, Field
from motor.motor_asyncio import AsyncIOMotorDatabase
from database import get_database
from security import get_current_user

# Models
class CampaignCreate(BaseModel):
    title: str
    description: str
    niche: str
    budget: float
    location: str
    required_followers: int = 0
    deliverables: str
    deadline: Optional[datetime] = None
    brand_id: Optional[str] = None

class CampaignUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    budget: Optional[float] = None
    location: Optional[str] = None
    required_followers: Optional[int] = None
    deliverables: Optional[str] = None
    deadline: Optional[datetime] = None
    status: Optional[str] = None

# Services
class CampaignService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.collection = db.campaigns

    async def create_campaign(self, campaign: CampaignCreate) -> str:
        campaign_dict = campaign.dict()
        campaign_dict["created_at"] = datetime.utcnow()
        campaign_dict["status"] = campaign_dict.get("status", "open") or "open"
        campaign_dict["applications_count"] = campaign_dict.get("applications_count", 0)
        result = await self.collection.insert_one(campaign_dict)
        return str(result.inserted_id)

    async def get_campaigns(
        self,
        skip: int = 0,
        limit: int = 10,
        niche: Optional[str] = None,
        status: Optional[str] = None
    ) -> List[dict]:
        query = {}
        if niche:
            query["niche"] = niche
        if status:
            query["status"] = status
        return await self.collection.find(query).skip(skip).limit(limit).to_list(length=limit)

    async def search_campaigns(
        self,
        niche: Optional[str] = None,
        location: Optional[str] = None,
        min_budget: Optional[float] = None,
        max_budget: Optional[float] = None,
        status: Optional[str] = None,
        skip: int = 0,
        limit: int = 20
    ) -> tuple:
        query: dict = {}
        if niche:
            query["niche"] = niche
        if location:
            query["location"] = {"$regex": location, "$options": "i"}
        if status:
            query["status"] = status
        if min_budget is not None or max_budget is not None:
            budget_filter: dict = {}
            if min_budget is not None:
                budget_filter["$gte"] = min_budget
            if max_budget is not None:
                budget_filter["$lte"] = max_budget
            query["budget"] = budget_filter

        total = await self.collection.count_documents(query)
        campaigns = await self.collection.find(query).skip(skip).limit(limit).to_list(length=limit)
        return campaigns, total

    async def get_campaign_by_id(self, campaign_id: str) -> Optional[dict]:
        try:
            return await self.collection.find_one({"_id": ObjectId(campaign_id)})
        except Exception:
            return None

    async def update_campaign(self, campaign_id: str, campaign_update: CampaignUpdate) -> bool:
        try:
            result = await self.collection.update_one(
                {"_id": ObjectId(campaign_id)},
                {"$set": campaign_update.dict(exclude_unset=True)}
            )
            return result.modified_count > 0
        except Exception:
            return False

    async def delete_campaign(self, campaign_id: str) -> bool:
        try:
            result = await self.collection.delete_one({"_id": ObjectId(campaign_id)})
            return result.deleted_count > 0
        except Exception:
            return False

# Router
router = APIRouter(prefix="/campaigns", tags=["campaigns"])

def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc

async def get_campaign_service(db: AsyncIOMotorDatabase = Depends(get_database)) -> CampaignService:
    return CampaignService(db)

@router.post("/", response_model=dict)
async def create_campaign(
    campaign: CampaignCreate,
    service: CampaignService = Depends(get_campaign_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    try:
        if current_user.get("role") != "brand":
            raise HTTPException(status_code=403, detail="Only brands can create campaigns")
        campaign.brand_id = current_user.get("id")
        campaign_id = await service.create_campaign(campaign)
        return {
            "id": campaign_id,
            "message": "Campaign created successfully",
            "status": "success"
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=dict)
async def list_campaigns(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    niche: Optional[str] = None,
    status: Optional[str] = None,
    service: CampaignService = Depends(get_campaign_service)
) -> dict:
    try:
        campaigns = await service.get_campaigns(skip=skip, limit=limit, niche=niche, status=status)
        campaigns = [normalize_id(c) for c in campaigns]
        return {
            "campaigns": campaigns,
            "count": len(campaigns),
            "skip": skip,
            "limit": limit
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/search", response_model=dict)
async def search_campaigns(
    niche: Optional[str] = None,
    location: Optional[str] = None,
    min_budget: Optional[float] = None,
    max_budget: Optional[float] = None,
    status: Optional[str] = "open",
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    service: CampaignService = Depends(get_campaign_service)
) -> dict:
    try:
        campaigns, total = await service.search_campaigns(
            niche=niche,
            location=location,
            min_budget=min_budget,
            max_budget=max_budget,
            status=status,
            skip=skip,
            limit=limit
        )
        campaigns = [normalize_id(c) for c in campaigns]
        return {
            "campaigns": campaigns,
            "total": total,
            "skip": skip,
            "limit": limit
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{campaign_id}", response_model=dict)
async def get_campaign(
    campaign_id: str = Path(..., description="Campaign ID"),
    service: CampaignService = Depends(get_campaign_service)
) -> dict:
    campaign = await service.get_campaign_by_id(campaign_id)
    if not campaign:
        raise HTTPException(status_code=404, detail="Campaign not found")
    return normalize_id(campaign)

@router.put("/{campaign_id}", response_model=dict)
async def update_campaign(
    campaign_id: str = Path(..., description="Campaign ID"),
    campaign_update: CampaignUpdate = None,
    service: CampaignService = Depends(get_campaign_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    if current_user.get("role") != "brand":
        raise HTTPException(status_code=403, detail="Only brands can update campaigns")
    campaign = await service.get_campaign_by_id(campaign_id)
    if not campaign or campaign.get("brand_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")
    success = await service.update_campaign(campaign_id, campaign_update)
    if not success:
        raise HTTPException(status_code=404, detail="Campaign not found")
    return {
        "message": "Campaign updated successfully",
        "status": "success"
    }

@router.delete("/{campaign_id}", response_model=dict)
async def delete_campaign(
    campaign_id: str = Path(..., description="Campaign ID"),
    service: CampaignService = Depends(get_campaign_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    if current_user.get("role") != "brand":
        raise HTTPException(status_code=403, detail="Only brands can delete campaigns")
    campaign = await service.get_campaign_by_id(campaign_id)
    if not campaign or campaign.get("brand_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")
    success = await service.delete_campaign(campaign_id)
    if not success:
        raise HTTPException(status_code=404, detail="Campaign not found")
    return {
        "message": "Campaign deleted successfully",
        "status": "success"
    }
