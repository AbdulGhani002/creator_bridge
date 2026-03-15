from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Literal
from datetime import datetime, timedelta
from bson import ObjectId
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_database
from security import hash_password, verify_password, create_access_token, get_current_user


class CreatorProfileInput(BaseModel):
    name: str
    bio: Optional[str] = ""
    niche: Optional[str] = None
    location: str
    followers_count: int = 0
    social_links: dict = {}
    portfolio_url: Optional[str] = None
    pricing_per_post: Optional[float] = None


class BrandProfileInput(BaseModel):
    company_name: str
    industry: Optional[str] = None
    company_website: Optional[str] = None
    company_description: Optional[str] = None
    location: Optional[str] = None


class SignupRequest(BaseModel):
    name: str
    email: EmailStr
    password: str = Field(min_length=8)
    role: Literal["creator", "brand"]
    location: str
    creator_profile: Optional[CreatorProfileInput] = None
    brand_profile: Optional[BrandProfileInput] = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class AuthResponse(BaseModel):
    token: str
    user: dict


router = APIRouter(prefix="/auth", tags=["auth"])


def normalize_user(user: dict) -> dict:
    if not user:
        return user
    user["_id"] = str(user.get("_id"))
    user["id"] = user["_id"]
    user.pop("password_hash", None)
    return user


@router.post("/signup", response_model=AuthResponse)
async def signup(payload: SignupRequest, db: AsyncIOMotorDatabase = Depends(get_database)):
    existing = await db.users.find_one({"email": payload.email})
    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_doc = {
        "name": payload.name,
        "email": payload.email,
        "password_hash": hash_password(payload.password),
        "role": payload.role,
        "location": payload.location,
        "created_at": datetime.utcnow(),
        "updated_at": None,
        "is_active": True,
    }
    result = await db.users.insert_one(user_doc)
    user_id = str(result.inserted_id)

    # Optional profile creation
    if payload.role == "creator" and payload.creator_profile:
        creator_doc = payload.creator_profile.dict()
        creator_doc.update({
            "user_id": user_id,
            "subscription_tier": "free",
            "created_at": datetime.utcnow(),
            "rating": None,
            "verified": False
        })
        await db.creators.insert_one(creator_doc)
    if payload.role == "brand" and payload.brand_profile:
        brand_doc = payload.brand_profile.dict()
        brand_doc.update({
            "user_id": user_id,
            "created_at": datetime.utcnow(),
            "verified": False
        })
        await db.brands.insert_one(brand_doc)

    token = create_access_token({"sub": user_id, "role": payload.role})
    user_doc["_id"] = user_id
    return {"token": token, "user": normalize_user(user_doc)}


@router.post("/login", response_model=AuthResponse)
async def login(payload: LoginRequest, db: AsyncIOMotorDatabase = Depends(get_database)):
    user = await db.users.find_one({"email": payload.email, "is_active": True})
    if not user:
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if not verify_password(payload.password, user.get("password_hash", "")):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token({"sub": str(user.get("_id")), "role": user.get("role")})
    return {"token": token, "user": normalize_user(user)}


@router.get("/me", response_model=dict)
async def me(current_user: dict = Depends(get_current_user)):
    return normalize_user(current_user)


@router.post("/demo", response_model=AuthResponse)
async def demo_user(
    role: Literal["creator", "brand"] = "creator",
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    email = f"demo+{role}+{timestamp}@creatorbridge.com"
    password = "DemoPass1"
    user_doc = {
        "name": f"Demo {role.title()}",
        "email": email,
        "password_hash": hash_password(password),
        "role": role,
        "location": "Demo City",
        "created_at": datetime.utcnow(),
        "updated_at": None,
        "is_active": True,
    }
    result = await db.users.insert_one(user_doc)
    user_id = str(result.inserted_id)
    if role == "creator":
        await db.creators.insert_one({
            "user_id": user_id,
            "name": "Demo Creator",
            "bio": "Demo account for review/testing.",
            "niche": "tech",
            "location": "Demo City",
            "followers_count": 12000,
            "subscription_tier": "pro",
            "pricing_per_post": 250,
            "created_at": datetime.utcnow(),
            "verified": False
        })
    else:
        await db.brands.insert_one({
            "user_id": user_id,
            "company_name": "Demo Brand",
            "industry": "tech",
            "company_website": "https://example.com",
            "company_description": "Demo brand account for review/testing.",
            "location": "Demo City",
            "created_at": datetime.utcnow(),
            "verified": False
        })

    token = create_access_token({"sub": user_id, "role": role})
    user_doc["_id"] = user_id
    user_doc["demo_password"] = password
    return {"token": token, "user": normalize_user(user_doc)}


@router.delete("/account", response_model=dict)
async def delete_account(
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    user_id = current_user.get("id")
    if not user_id:
        raise HTTPException(status_code=400, detail="Invalid user")

    # Delete related data
    await db.creators.delete_many({"user_id": user_id})
    await db.brands.delete_many({"user_id": user_id})
    await db.campaigns.delete_many({"brand_id": user_id})
    await db.applications.delete_many({"creator_id": user_id})
    await db.applications.delete_many({"brand_id": user_id})
    await db.messages.delete_many({"$or": [{"from_id": user_id}, {"to_id": user_id}]})
    await db.agreements.delete_many({"$or": [{"creator_id": user_id}, {"brand_id": user_id}]})
    await db.reviews.delete_many({"$or": [{"reviewer_id": user_id}, {"reviewee_id": user_id}]})
    await db.blocks.delete_many({"$or": [{"blocker_id": user_id}, {"blocked_id": user_id}]})
    await db.reports.delete_many({"reporter_id": user_id})
    await db.subscriptions.delete_many({"user_id": user_id})

    await db.users.delete_one({"_id": ObjectId(user_id)})

    return {"status": "success", "message": "Account deleted"}

