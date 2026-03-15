from fastapi import APIRouter, HTTPException, Depends, Query, Path
from typing import Optional, List
from bson import ObjectId
from datetime import datetime
from pydantic import BaseModel
from motor.motor_asyncio import AsyncIOMotorDatabase
from database import get_database
from security import get_current_user

# Models
class CreatorProfile(BaseModel):
    user_id: Optional[str] = None
    name: str
    bio: str
    niche: Optional[str] = None
    location: str
    followers_count: int = 0
    verified: bool = False
    profile_image_url: Optional[str] = None
    portfolio_url: Optional[str] = None
    social_links: dict = {}
    platforms: Optional[list] = None
    subscription_tier: Optional[str] = "free"
    pricing_per_post: Optional[float] = None
    total_earnings: Optional[float] = 0.0
    rating: Optional[float] = None
    niches: Optional[list] = None
    followers: Optional[int] = None
    engagement_rate: Optional[float] = None
    monthly_reach: Optional[int] = None

    class Config:
        extra = "allow"

class CreatorUpdate(BaseModel):
    bio: Optional[str] = None
    niche: Optional[str] = None
    location: Optional[str] = None
    followers_count: Optional[int] = None
    portfolio_url: Optional[str] = None
    social_links: Optional[dict] = None
    platforms: Optional[list] = None
    subscription_tier: Optional[str] = None
    pricing_per_post: Optional[float] = None
    rating: Optional[float] = None

# Services
class CreatorService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
        self.creators_collection = db.creators
        self.users_collection = db.users
        self.applications_collection = db.applications

    async def create_creator_profile(self, creator: CreatorProfile) -> str:
        creator_dict = creator.dict()
        creator_dict["created_at"] = datetime.utcnow()
        creator_dict["verified"] = creator_dict.get("verified", False)
        result = await self.creators_collection.insert_one(creator_dict)
        return str(result.inserted_id)

    async def get_creators(
        self,
        skip: int = 0,
        limit: int = 10,
        niche: Optional[str] = None,
        verified_only: bool = False
    ) -> List[dict]:
        query = {}
        if niche:
            query["niche"] = niche
        if verified_only:
            query["verified"] = True
        creators = await self.creators_collection.find(query).skip(skip).limit(limit).to_list(length=limit)
        return creators

    async def search_creators_advanced(
        self,
        q: Optional[str] = None,
        niche: Optional[str] = None,
        location: Optional[str] = None,
        platform: Optional[str] = None,
        min_followers: Optional[int] = None,
        max_followers: Optional[int] = None,
        subscription_tier: Optional[str] = None,
        min_rating: Optional[float] = None,
        skip: int = 0,
        limit: int = 20
    ) -> tuple:
        query: dict = {}
        if q:
            query["$or"] = [
                {"name": {"$regex": q, "$options": "i"}},
                {"bio": {"$regex": q, "$options": "i"}}
            ]
        if niche:
            query["niche"] = niche
        if location:
            query["location"] = {"$regex": location, "$options": "i"}
        if platform:
            query["$or"] = query.get("$or", [])
            query["$or"].extend([
                {"platforms": {"$in": [platform]}},
                {f"social_links.{platform}": {"$exists": True}}
            ])
        if subscription_tier:
            query["subscription_tier"] = subscription_tier
        if min_rating is not None:
            query["rating"] = {"$gte": min_rating}
        if min_followers is not None or max_followers is not None:
            followers_field = "followers_count"
            if min_followers is not None:
                query.setdefault(followers_field, {})["$gte"] = min_followers
            if max_followers is not None:
                query.setdefault(followers_field, {})["$lte"] = max_followers

        total = await self.creators_collection.count_documents(query)
        creators = await self.creators_collection.find(query).skip(skip).limit(limit).to_list(length=limit)
        return creators, total

    async def get_creator_by_id(self, creator_id: str) -> Optional[dict]:
        try:
            return await self.creators_collection.find_one({"_id": ObjectId(creator_id)})
        except Exception:
            return None

    async def get_creator_by_user_id(self, user_id: str) -> Optional[dict]:
        return await self.creators_collection.find_one({"user_id": user_id})

    async def update_creator(self, creator_id: str, creator_update: CreatorUpdate) -> bool:
        try:
            result = await self.creators_collection.update_one(
                {"_id": ObjectId(creator_id)},
                {"$set": creator_update.dict(exclude_unset=True)}
            )
            return result.modified_count > 0
        except Exception:
            return False

    async def get_creator_stats(self, creator_id: str) -> Optional[dict]:
        try:
            creator = await self.get_creator_by_id(creator_id)
            if not creator:
                return None

            total_views = creator.get("monthly_reach", 0)
            followers = creator.get("followers", creator.get("followers_count", 0))
            engagement_rate = creator.get("engagement_rate", 5)
            total_engagements = int(followers * (engagement_rate / 100))
            campaigns_completed = len(creator.get("portfolio", []))

            return {
                "total_views": total_views,
                "total_engagements": total_engagements,
                "campaigns_completed": campaigns_completed,
                "avg_engagement_rate": engagement_rate
            }
        except Exception:
            return None

# Router
router = APIRouter(prefix="/creators", tags=["creators"])

def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc

async def get_creator_service(db: AsyncIOMotorDatabase = Depends(get_database)):
    return CreatorService(db)

@router.post("/", response_model=dict)
async def create_creator(
    creator: CreatorProfile,
    service: CreatorService = Depends(get_creator_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    try:
        if current_user.get("role") != "creator":
            raise HTTPException(status_code=403, detail="Only creators can create profiles")
        creator.user_id = current_user.get("id")
        if not creator.name:
            creator.name = current_user.get("name", "Creator")
        creator_id = await service.create_creator_profile(creator)
        return {
            "id": creator_id,
            "message": "Creator profile created successfully",
            "status": "success"
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=dict)
async def list_creators(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    niche: Optional[str] = None,
    verified: bool = Query(False),
    service: CreatorService = Depends(get_creator_service)
) -> dict:
    try:
        creators = await service.get_creators(skip=skip, limit=limit, niche=niche, verified_only=verified)
        creators = [normalize_id(c) for c in creators]
        return {
            "creators": creators,
            "count": len(creators),
            "skip": skip,
            "limit": limit
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/search", response_model=dict)
async def search_creators(
    q: Optional[str] = None,
    niche: Optional[str] = None,
    location: Optional[str] = None,
    platform: Optional[str] = None,
    min_followers: Optional[int] = None,
    max_followers: Optional[int] = None,
    subscription_tier: Optional[str] = None,
    min_rating: Optional[float] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    service: CreatorService = Depends(get_creator_service)
) -> dict:
    try:
        creators, total = await service.search_creators_advanced(
            q=q,
            niche=niche,
            location=location,
            platform=platform,
            min_followers=min_followers,
            max_followers=max_followers,
            subscription_tier=subscription_tier,
            min_rating=min_rating,
            skip=skip,
            limit=limit
        )
        creators = [normalize_id(c) for c in creators]
        return {
            "creators": creators,
            "total": total,
            "skip": skip,
            "limit": limit
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/by-location/{location}", response_model=dict)
async def creators_by_location(
    location: str,
    niche: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    service: CreatorService = Depends(get_creator_service)
) -> dict:
    try:
        creators, total = await service.search_creators_advanced(
            location=location,
            niche=niche,
            skip=skip,
            limit=limit
        )
        creators = [normalize_id(c) for c in creators]
        return {
            "creators": creators,
            "total": total,
            "skip": skip,
            "limit": limit
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{creator_id}", response_model=dict)
async def get_creator(
    creator_id: str = Path(..., description="Creator ID"),
    service: CreatorService = Depends(get_creator_service)
) -> dict:
    creator = await service.get_creator_by_id(creator_id)
    if not creator:
        raise HTTPException(status_code=404, detail="Creator not found")
    return normalize_id(creator)

@router.get("/user/{user_id}", response_model=dict)
async def get_creator_by_user(
    user_id: str = Path(..., description="User ID"),
    service: CreatorService = Depends(get_creator_service)
) -> dict:
    creator = await service.get_creator_by_user_id(user_id)
    if not creator:
        raise HTTPException(status_code=404, detail="Creator profile not found")
    return normalize_id(creator)

@router.put("/{creator_id}", response_model=dict)
async def update_creator(
    creator_id: str = Path(..., description="Creator ID"),
    creator_update: CreatorUpdate = None,
    service: CreatorService = Depends(get_creator_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    if current_user.get("role") != "creator":
        raise HTTPException(status_code=403, detail="Only creators can update profiles")
    creator = await service.get_creator_by_id(creator_id)
    if not creator or creator.get("user_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")
    success = await service.update_creator(creator_id, creator_update)
    if not success:
        raise HTTPException(status_code=404, detail="Creator not found")
    return {
        "message": "Creator profile updated successfully",
        "status": "success"
    }

@router.get("/{creator_id}/stats", response_model=dict)
async def get_creator_statistics(
    creator_id: str = Path(..., description="Creator ID"),
    service: CreatorService = Depends(get_creator_service)
) -> dict:
    stats = await service.get_creator_stats(creator_id)
    if not stats:
        raise HTTPException(status_code=404, detail="Creator not found")
    return {
        "stats": stats,
        "creator_id": creator_id
    }

@router.get("/{creator_id}/earnings", response_model=dict)
async def get_creator_earnings(
    creator_id: str = Path(..., description="Creator ID"),
    service: CreatorService = Depends(get_creator_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    creator = await service.get_creator_by_id(creator_id)
    if not creator:
        raise HTTPException(status_code=404, detail="Creator not found")
    if current_user.get("role") == "creator" and creator.get("user_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")

    return {
        "creator_id": creator_id,
        "overview": {
            "total_balance": creator.get("total_earnings", 4250.0),
            "pending_payout": 850.0,
            "pending_payout_date": "May 24"
        },
        "revenue_growth": [40, 60, 85, 45, 70, 90, 30],
        "payout_methods": [
            {
                "provider": "Stripe Connect",
                "masked_account": "**** 4242",
                "status": "connected"
            }
        ],
        "visibility": {
            "plan": creator.get("subscription_tier", "pro"),
            "public_profile": True,
            "incognito": False,
            "show_revenue": False
        }
    }
