from fastapi import APIRouter, HTTPException, Depends, Path
from pydantic import BaseModel
from datetime import datetime
from motor.motor_asyncio import AsyncIOMotorDatabase

from database import get_database
from security import get_current_user


class BlockCreate(BaseModel):
    blocked_id: str


router = APIRouter(prefix="/blocks", tags=["blocks"])


def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc


@router.post("/", response_model=dict)
async def block_user(
    payload: BlockCreate,
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    if payload.blocked_id == current_user.get("id"):
        raise HTTPException(status_code=400, detail="You cannot block yourself")

    existing = await db.blocks.find_one({
        "blocker_id": current_user.get("id"),
        "blocked_id": payload.blocked_id
    })
    if existing:
        raise HTTPException(status_code=400, detail="User already blocked")

    block_doc = {
        "blocker_id": current_user.get("id"),
        "blocked_id": payload.blocked_id,
        "created_at": datetime.utcnow()
    }
    result = await db.blocks.insert_one(block_doc)
    return {"id": str(result.inserted_id), "status": "success", "message": "User blocked"}


@router.get("/", response_model=dict)
async def list_blocks(
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    items = await db.blocks.find({"blocker_id": current_user.get("id")}).to_list(length=200)
    items = [normalize_id(b) for b in items]
    return {"blocks": items, "count": len(items)}


@router.delete("/{block_id}", response_model=dict)
async def unblock_user(
    block_id: str = Path(..., description="Block ID"),
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    try:
        from bson import ObjectId
        result = await db.blocks.delete_one({"_id": ObjectId(block_id), "blocker_id": current_user.get("id")})
    except Exception:
        result = await db.blocks.delete_one({"_id": block_id, "blocker_id": current_user.get("id")})
    return {"status": "success", "message": "User unblocked"}
