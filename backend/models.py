"""
Pydantic models for User, Creator, Brand, Campaign, and related schemas
"""
from pydantic import BaseModel, Field, EmailStr, validator
from typing import List, Optional, Enum
from datetime import datetime
from enum import Enum as PyEnum
from bson import ObjectId


class PyObjectId(ObjectId):
    """Custom type for MongoDB ObjectId"""
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError(f"Invalid ObjectId: {v}")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")


class UserRole(str, PyEnum):
    """User role enumeration"""
    CREATOR = "creator"
    BRAND = "brand"


class PlatformType(str, PyEnum):
    """Social media platform types"""
    INSTAGRAM = "instagram"
    YOUTUBE = "youtube"
    TIKTOK = "tiktok"
    TWITTER = "twitter"
    LINKEDIN = "linkedin"
    BLOG = "blog"
    PODCAST = "podcast"


class NicheType(str, PyEnum):
    """Content niches"""
    REAL_ESTATE = "real_estate"
    TECH = "tech"
    FITNESS = "fitness"
    BEAUTY = "beauty"
    FINANCE = "finance"
    TRAVEL = "travel"
    EDUCATION = "education"
    FOOD = "food"
    LIFESTYLE = "lifestyle"
    GAMING = "gaming"
    FASHION = "fashion"


class CampaignStatus(str, PyEnum):
    """Campaign status"""
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    CLOSED = "closed"


class ApplicationStatus(str, PyEnum):
    """Application status"""
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
    COMPLETED = "completed"


# ==================== USER MODELS ====================

class UserBase(BaseModel):
    """Base user model"""
    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    role: UserRole
    location: str = Field(..., min_length=1, max_length=100)
    created_at: Optional[datetime] = Field(default_factory=datetime.utcnow)


class UserCreate(UserBase):
    """User creation request model"""
    password: str = Field(..., min_length=8)

    @validator('password')
    def validate_password(cls, v):
        if not any(char.isdigit() for char in v):
            raise ValueError('Password must contain at least one digit')
        if not any(char.isupper() for char in v):
            raise ValueError('Password must contain at least one uppercase letter')
        return v


class UserResponse(UserBase):
    """User response model"""
    id: PyObjectId = Field(alias="_id")
    updated_at: Optional[datetime] = None

    class Config:
        populate_by_name = True
        json_encoders = {ObjectId: str}


# ==================== CREATOR MODELS ====================

class SocialPlatform(BaseModel):
    """Creator's social media platform details"""
    platform: PlatformType
    handle: str = Field(..., min_length=1, max_length=100)
    followers: int = Field(..., ge=0)
    engagement_rate: Optional[float] = Field(None, ge=0, le=100)  # percentage


class CreatorBase(BaseModel):
    """Base creator model"""
    niche: NicheType
    bio: str = Field(..., max_length=500)
    pricing_per_post: float = Field(..., ge=0)
    portfolio_url: Optional[str] = None
    social_platforms: List[SocialPlatform]


class CreatorProfileCreate(CreatorBase):
    """Creator profile creation request"""
    pass


class CreatorProfileResponse(CreatorBase):
    """Creator profile response model"""
    id: PyObjectId = Field(alias="_id")
    user_id: PyObjectId
    subscription_tier: str = Field(default="free")  # free, pro, premium
    total_earnings: float = Field(default=0)
    rating: Optional[float] = Field(None, ge=0, le=5)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        populate_by_name = True
        json_encoders = {ObjectId: str}


# ==================== BRAND MODELS ====================

class BrandProfileBase(BaseModel):
    """Base brand model"""
    company_name: str = Field(..., min_length=1, max_length=200)
    industry: str = Field(..., min_length=1, max_length=100)
    company_website: Optional[str] = None
    company_description: str = Field(..., max_length=1000)


class BrandProfileCreate(BrandProfileBase):
    """Brand profile creation request"""
    pass


class BrandProfileResponse(BrandProfileBase):
    """Brand profile response model"""
    id: PyObjectId = Field(alias="_id")
    user_id: PyObjectId
    verified: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        populate_by_name = True
        json_encoders = {ObjectId: str}


# ==================== CAMPAIGN MODELS ====================

class CampaignBase(BaseModel):
    """Base campaign model"""
    title: str = Field(..., min_length=5, max_length=200)
    description: str = Field(..., min_length=10, max_length=2000)
    niche: NicheType
    budget: float = Field(..., ge=0)
    location: str = Field(..., min_length=1, max_length=100)
    required_followers: int = Field(default=0, ge=0)
    deliverables: str = Field(..., max_length=1000)
    deadline: datetime


class CampaignCreate(CampaignBase):
    """Campaign creation request"""
    pass


class CampaignResponse(CampaignBase):
    """Campaign response model"""
    id: PyObjectId = Field(alias="_id")
    brand_id: PyObjectId
    status: CampaignStatus = Field(default=CampaignStatus.OPEN)
    applications_count: int = Field(default=0)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: Optional[datetime] = None

    class Config:
        populate_by_name = True
        json_encoders = {ObjectId: str}


class CampaignSearchParams(BaseModel):
    """Campaign search and filter parameters"""
    niche: Optional[NicheType] = None
    location: Optional[str] = None
    min_budget: Optional[float] = None
    max_budget: Optional[float] = None
    status: Optional[CampaignStatus] = None
    skip: int = Field(default=0, ge=0)
    limit: int = Field(default=20, ge=1, le=100)


# ==================== APPLICATION MODELS ====================

class ApplicationCreate(BaseModel):
    """Application submission request"""
    campaign_id: PyObjectId
    creator_id: PyObjectId
    proposal: str = Field(..., min_length=10, max_length=2000)


class ApplicationResponse(BaseModel):
    """Application response model"""
    id: PyObjectId = Field(alias="_id")
    campaign_id: PyObjectId
    creator_id: PyObjectId
    proposal: str
    status: ApplicationStatus = Field(default=ApplicationStatus.PENDING)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        populate_by_name = True
        json_encoders = {ObjectId: str}


# ==================== SEARCH RESPONSE MODELS ====================

class CreatorSearchResponse(BaseModel):
    """Creator search result response"""
    creators: List[CreatorProfileResponse]
    total: int
    skip: int
    limit: int


class CampaignSearchResponse(BaseModel):
    """Campaign search result response"""
    campaigns: List[CampaignResponse]
    total: int
    skip: int
    limit: int
