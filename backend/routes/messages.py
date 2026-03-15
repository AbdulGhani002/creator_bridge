from fastapi import APIRouter, HTTPException, Depends, Query, Path
from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId

from database import get_database
from security import get_current_user


class MessageCreate(BaseModel):
    to_id: str
    campaign_id: Optional[str] = None
    content: str


class MessageUpdate(BaseModel):
    read: Optional[bool] = None


class MessageService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.collection = db.messages

    async def list_messages(
        self,
        thread_id: Optional[str] = None,
        skip: int = 0,
        limit: int = 50
    ) -> List[dict]:
        query = {}
        if thread_id:
            query["thread_id"] = thread_id
        return await self.collection.find(query).sort("timestamp", 1).skip(skip).limit(limit).to_list(length=limit)

    async def create_message(self, message: dict) -> str:
        result = await self.collection.insert_one(message)
        return str(result.inserted_id)


router = APIRouter(prefix="/messages", tags=["messages"])


def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc


async def get_message_service(db: AsyncIOMotorDatabase = Depends(get_database)) -> MessageService:
    return MessageService(db)


def build_thread_id(user_a: str, user_b: str, campaign_id: Optional[str] = None) -> str:
    a, b = sorted([user_a, user_b])
    suffix = campaign_id or "general"
    return f"{a}_{b}_{suffix}"


async def get_blocked_sets(db: AsyncIOMotorDatabase, user_id: str) -> tuple:
    blocked = await db.blocks.find({"blocker_id": user_id}).to_list(length=500)
    blocked_ids = {b.get("blocked_id") for b in blocked}
    blocked_by = await db.blocks.find({"blocked_id": user_id}).to_list(length=500)
    blocked_by_ids = {b.get("blocker_id") for b in blocked_by}
    return blocked_ids, blocked_by_ids


@router.get("/", response_model=dict)
async def list_messages(
    thread_id: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    service: MessageService = Depends(get_message_service),
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
) -> dict:
    try:
        blocked_ids, blocked_by_ids = await get_blocked_sets(db, current_user.get("id"))
        messages = await service.list_messages(thread_id, skip, limit)
        filtered = []
        for m in messages:
            if m.get("from_id") in blocked_ids or m.get("to_id") in blocked_ids:
                continue
            if m.get("from_id") in blocked_by_ids or m.get("to_id") in blocked_by_ids:
                continue
            filtered.append(normalize_id(m))
        return {"messages": filtered, "count": len(filtered)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/", response_model=dict)
async def create_message(
    message: MessageCreate,
    service: MessageService = Depends(get_message_service),
    current_user: dict = Depends(get_current_user)
) -> dict:
    try:
        thread_id = build_thread_id(current_user.get("id"), message.to_id, message.campaign_id)
        data = message.dict()
        data.update({
            "from_id": current_user.get("id"),
            "thread_id": thread_id,
            "participants": [current_user.get("id"), message.to_id],
            "read_by": [current_user.get("id")],
            "timestamp": datetime.utcnow(),
            "read": False
        })
        message_id = await service.create_message(data)
        return {"id": message_id, "message": "Message sent", "status": "success"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/threads", response_model=dict)
async def list_threads(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
) -> dict:
    user_id = current_user.get("id")
    blocked_ids, blocked_by_ids = await get_blocked_sets(db, user_id)

    pipeline = [
        {"$match": {"participants": user_id}},
        {"$sort": {"timestamp": -1}},
        {"$group": {"_id": "$thread_id", "message": {"$first": "$$ROOT"}}},
        {"$sort": {"message.timestamp": -1}},
        {"$skip": skip},
        {"$limit": limit}
    ]
    threads = await db.messages.aggregate(pipeline).to_list(length=limit)

    cleaned = []
    for t in threads:
        msg = t.get("message", {})
        if msg.get("from_id") in blocked_ids or msg.get("to_id") in blocked_ids:
            continue
        if msg.get("from_id") in blocked_by_ids or msg.get("to_id") in blocked_by_ids:
            continue
        msg = normalize_id(msg)
        cleaned.append({"thread_id": t.get("_id"), "last_message": msg})
    return {"threads": cleaned, "count": len(cleaned)}


@router.put("/{message_id}/read", response_model=dict)
async def mark_message_read(
    message_id: str = Path(..., description="Message ID"),
    current_user: dict = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
) -> dict:
    try:
        msg_obj_id = ObjectId(message_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid message id")

    await db.messages.update_one(
        {"_id": msg_obj_id},
        {"$addToSet": {"read_by": current_user.get("id")}, "$set": {"read": True}}
    )
    return {"status": "success", "message": "Marked as read"}

