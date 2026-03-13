from fastapi import APIRouter, HTTPException, Depends, Query
from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId

class MessageCreate(BaseModel):
    from_id: str
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
        campaign_id: Optional[str] = None,
        from_id: Optional[str] = None,
        to_id: Optional[str] = None,
        skip: int = 0,
        limit: int = 50
    ) -> List[dict]:
        query = {}
        if campaign_id:
            query["campaign_id"] = campaign_id
        if from_id:
            query["from_id"] = from_id
        if to_id:
            query["to_id"] = to_id
        return await self.collection.find(query).skip(skip).limit(limit).to_list(length=limit)

    async def create_message(self, message: MessageCreate) -> str:
        data = message.dict()
        data["timestamp"] = datetime.utcnow()
        data["read"] = False
        result = await self.collection.insert_one(data)
        return str(result.inserted_id)

# Router
router = APIRouter(prefix="/messages", tags=["messages"])

def normalize_id(doc: dict) -> dict:
    if not doc:
        return doc
    doc["_id"] = str(doc.get("_id", ""))
    doc["id"] = doc["_id"]
    return doc

async def get_message_service(db: AsyncIOMotorDatabase) -> MessageService:
    return MessageService(db)

@router.get("/", response_model=dict)
async def list_messages(
    campaign_id: Optional[str] = None,
    from_id: Optional[str] = None,
    to_id: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    service: MessageService = Depends(get_message_service)
) -> dict:
    try:
        messages = await service.list_messages(campaign_id, from_id, to_id, skip, limit)
        messages = [normalize_id(m) for m in messages]
        return {"messages": messages, "count": len(messages)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=dict)
async def create_message(
    message: MessageCreate,
    service: MessageService = Depends(get_message_service)
) -> dict:
    try:
        message_id = await service.create_message(message)
        return {"id": message_id, "message": "Message sent", "status": "success"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
