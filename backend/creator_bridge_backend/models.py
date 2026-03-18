from pydantic import BaseModel, EmailStr
from typing import Optional, List

class UserSignup(BaseModel):
    name: str
    email: EmailStr
    password: str
    role: str  # 'creator' or 'brand'
    location: str

class CampaignCreate(BaseModel):
    brand_id: str
    title: str
    description: str
    budget: str
    location: str
    niche: str