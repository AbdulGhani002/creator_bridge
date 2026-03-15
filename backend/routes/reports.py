from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import Literal, Optional
from datetime import datetime
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_database
from security import get_current_user


ReportTargetType = Literal["message", "user", "campaign", "review", "agreement"]


class ReportCreate(BaseModel):
    target_type: ReportTargetType
    target_id: str
    reason: str = Field(..., min_length=3, max_length=200)
    details: Optional[str] = Field(default=None, max_length=2000)


router = APIRouter(prefix="/reports", tags=["reports"])


@router.post("/", response_model=dict)
async def create_report(
    payload: ReportCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    report_doc = payload.dict()
    report_doc.update({
        "reporter_id": current_user.get("id"),
        "status": "open",
        "created_at": datetime.utcnow()
    })
    result = await db.reports.insert_one(report_doc)
    return {"id": str(result.inserted_id), "status": "success", "message": "Report submitted"}

