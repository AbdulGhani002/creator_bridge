from fastapi import APIRouter, HTTPException, Depends, Query, Path
from typing import Optional, List
from bson import ObjectId
from datetime import datetime
from pydantic import BaseModel
from motor.motor_asyncio import AsyncIOMotorDatabase
from database import get_database
from security import get_current_user

# Models
class BrandProfile(BaseModel):
    user_id: Optional[str] = None
    company_name: Optional[str] = None
    industry: Optional[str] = None
    company_website: Optional[str] = None
    company_description: Optional[str] = None
    verified: bool = False
    followers: Optional[int] = None
    location: Optional[str] = None
    name: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None

    class Config:
        extra = "allow"

class BrandUpdate(BaseModel):
    company_name: Optional[str] = None
    industry: Optional[str] = None
    company_website: Optional[str] = None
    company_description: Optional[str] = None
    verified: Optional[bool] = None
    followers: Optional[int] = None
    location: Optional[str] = None

# Services
class BrandService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.collection = db.brands

    async def create_brand(self, brand: BrandProfile) -> str:
        brand_dict = brand.dict()
        brand_dict["created_at"] = datetime.utcnow()
        result = await self.collection.insert_one(brand_dict)
        return str(result.inserted_id)

    async def list_brands(self, skip: int, limit: int, verified: Optional[bool]) -> List[dict]:
        query = {}
        if verified is not None:
            query["verified"] = verified
        return await self.collection.find(query).skip(skip).limit(limit).to_list(length=limit)

    async def get_brand(self, brand_id: str) -> Optional[dict]:
        try:
            return await self.collection.find_one({"_id": ObjectId(brand_id)})
        except Exception:
            return None

    async def update_brand(self, brand_id: str, update: BrandUpdate) -> bool:
        try:
            result = await self.collection.update_one(
                {"_id": ObjectId(brand_id)},
                {"$set": update.dict(exclude_unset=True)}
            )
            return result.modified_count > 0
        except Exception:
            return False

# Router
router = APIRouter(prefix="/brands", tags=["brands"])

def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc

async def get_brand_service(db: AsyncIOMotorDatabase = Depends(get_database)) -> BrandService:
    return BrandService(db)

@router.post("/", response_model=dict)
async def create_brand(
    brand: BrandProfile,
    service: BrandService = Depends(get_brand_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    try:
        if current_user.get("role") != "brand":
            raise HTTPException(status_code=403, detail="Only brands can create profiles")
        brand.user_id = current_user.get("id")
        brand_id = await service.create_brand(brand)
        return {"id": brand_id, "message": "Brand created", "status": "success"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/", response_model=dict)
async def list_brands(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    verified: Optional[bool] = None,
    service: BrandService = Depends(get_brand_service)
) -> dict:
    try:
        brands = await service.list_brands(skip, limit, verified)
        brands = [normalize_id(b) for b in brands]
        return {"brands": brands, "count": len(brands), "skip": skip, "limit": limit}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{brand_id}", response_model=dict)
async def get_brand(
    brand_id: str = Path(..., description="Brand ID"),
    service: BrandService = Depends(get_brand_service)
) -> dict:
    brand = await service.get_brand(brand_id)
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")
    return normalize_id(brand)

@router.get("/user/{user_id}", response_model=dict)
async def get_brand_by_user(
    user_id: str = Path(..., description="User ID"),
    service: BrandService = Depends(get_brand_service)
) -> dict:
    brand = await service.collection.find_one({"user_id": user_id})
    if not brand:
        raise HTTPException(status_code=404, detail="Brand profile not found")
    return normalize_id(brand)

@router.put("/{brand_id}", response_model=dict)
async def update_brand(
    brand_id: str = Path(..., description="Brand ID"),
    update: BrandUpdate = None,
    service: BrandService = Depends(get_brand_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    if current_user.get("role") != "brand":
        raise HTTPException(status_code=403, detail="Only brands can update profiles")
    brand = await service.get_brand(brand_id)
    if not brand or brand.get("user_id") != current_user.get("id"):
        raise HTTPException(status_code=403, detail="Not authorized")
    success = await service.update_brand(brand_id, update)
    if not success:
        raise HTTPException(status_code=404, detail="Brand not found")
    return {"message": "Brand updated", "status": "success"}
