from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv
from pydantic import BaseModel, EmailStr
from typing import List, Optional
from auth_utils import hash_password, verify_password, create_access_token
from bson import ObjectId
from datetime import datetime
import stripe # Top par lazmi hona chahiye
from fastapi import Request

load_dotenv()

app = FastAPI()

# 🚀 2. Stripe API Key ko explicitly set karein
# os.getenv aapki .env file se key uthayega
STRIPE_KEY = os.getenv("STRIPE_SECRET_KEY")
if not STRIPE_KEY:
    print("❌ ERROR: Stripe Key nahi mili! Check karein .env file.")
else:
    stripe.api_key = STRIPE_KEY
    print("✅ Stripe Key successfully load ho gayi!")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MONGODB_URL = os.getenv("MONGODB_URL")
DATABASE_NAME = os.getenv("DATABASE_NAME")
client = AsyncIOMotorClient(MONGODB_URL)
db = client[DATABASE_NAME]

# --- Pydantic Models ---

class UserSignup(BaseModel):
    name: str
    email: EmailStr
    password: str
    role: str 
    location: str

# 1. Model update karein
class CampaignCreate(BaseModel):
    title: str
    description: str
    budget: str
    location: str
    niche: str
    brand_id: str
    brand_name: Optional[str] = "Brand"
    platform: Optional[str] = "Instagram"
    status: Optional[str] = "active" # active/closed


class ApplicationCreate(BaseModel):
    campaign_id: str
    creator_id: str
    creator_name: str
    proposal: str
    status: str = "pending"

# UPDATED: Added portfolio field to match Flutter data
# main.py mein model update karein
class CreatorUpdate(BaseModel):
    name: str  # <--- Yeh line lazmi add karein
    niche: str
    followers: int
    pricing: str
    bio: Optional[str] = ""
    portfolio: Optional[str] = ""

class UserUpdatePlan(BaseModel):
    user_id: str
    plan_type: str  # "Free", "Pro", "Premium"

# 🚀 Yeh hai aapka missing schema
class MessageSchema(BaseModel):
    sender_id: str
    receiver_id: str
    text: str
    timestamp: Optional[datetime] = None

class StatusUpdate(BaseModel):
    status: str
# --- API Endpoints ---

@app.get("/")
async def health_check():
    return {"status": "Online", "port": os.getenv("PORT"), "env": os.getenv("ENV")}

@app.post("/api/signup")
async def signup(user: UserSignup):
    existing_user = await db["users"].find_one({"email": user.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already exists")
    
    user_data = user.dict()
    user_data["password"] = hash_password(user.password)
    result = await db["users"].insert_one(user_data)
    
    if user.role == "creator":
        await db["creators"].insert_one({
            "user_id": str(result.inserted_id),
            "niche": "General",
            "followers": 0,
            "pricing": "$0",
            "bio": "",
            "portfolio": ""
        })
    else:
        await db["brands"].insert_one({
            "user_id": str(result.inserted_id), 
            "company_name": user.name
        })
    return {"message": "User registered", "id": str(result.inserted_id)}

@app.post("/api/login")
async def login(credentials: dict):
    user = await db["users"].find_one({"email": credentials["email"]})
    if not user or not verify_password(credentials["password"], user["password"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    token = create_access_token({"sub": user["email"], "role": user["role"]})
    return {
        "access_token": token, 
        "token_type": "bearer",
        "role": user["role"],
        "name": user["name"],
        "user_id": str(user["_id"])
    }

@app.get("/api/creators")
async def get_all_creators():
    pipeline = [
        {"$addFields": {"user_id_obj": {"$toObjectId": "$user_id"}}},
        {
            "$lookup": {
                "from": "users",
                "localField": "user_id_obj",
                "foreignField": "_id",
                "as": "user_info"
            }
        },
        {"$unwind": "$user_info"}
    ]
    creators = await db["creators"].aggregate(pipeline).to_list(100)
    formatted = []
    for c in creators:
        user_data = c.get("user_info", {})
        formatted.append({
            "_id": str(c["_id"]),
            "user_id": str(c.get("user_id", c["_id"])), 
            "full_name": user_data.get("name", "Unknown"),
            "niche": c.get("niche", "General"),
            "followers": c.get("followers", 0),
            "rate": c.get("pricing", "$0/post"), 
            "location": user_data.get("location", "Pakistan"),
            "platform": "Instagram" 
        })
    return formatted

# UPDATED: More robust update logic
@app.put("/api/creators/{user_id}")
async def update_creator_profile(user_id: str, data: CreatorUpdate):
    try:
        # 1. Users collection mein display name update karein
        await db["users"].update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {"name": data.name}}
        )

        # 2. Creators collection mein baqi stats update karein
        # .dict() use karke stats nikalen lekin 'name' ko exclude kar dein agar stats mein nahi chahiye
        creator_stats = data.dict()
        del creator_stats['name'] 

        await db["creators"].update_one(
            {"user_id": user_id},
            {"$set": creator_stats},
            upsert=True
        )
        
        return {"status": "success", "message": "Profile and Name updated"}
    except Exception as e:
        print(f"Update Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/messages/send")
async def send_message(msg: dict):
    try:
        message_data = {
            "sender_id": msg["sender_id"],
            "receiver_id": msg["receiver_id"],
            "text": msg["text"],
            "timestamp": datetime.utcnow()
        }
        result = await db["messages"].insert_one(message_data)
        return {"status": "success", "id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/messages/{user1_id}/{user2_id}")
async def get_chat_history(user1_id: str, user2_id: str):
    query = {"$or": [{"sender_id": user1_id, "receiver_id": user2_id}, {"sender_id": user2_id, "receiver_id": user1_id}]}
    messages = await db["messages"].find(query).sort("timestamp", 1).to_list(100)
    for m in messages:
        m["_id"] = str(m["_id"])
        if "timestamp" in m:
            m["timestamp"] = m["timestamp"].isoformat()
    return messages

@app.get("/api/chat-list/{user_id}")
async def get_chat_list(user_id: str):
    pipeline = [
        {"$match": {"$or": [{"sender_id": user_id}, {"receiver_id": user_id}]}},
        {"$sort": {"timestamp": -1}},
        {
            "$group": {
                "_id": {
                    "$cond": [{"$eq": ["$sender_id", user_id]}, "$receiver_id", "$sender_id"]
                },
                "last_message": {"$first": "$text"},
                "timestamp": {"$first": "$timestamp"}
            }
        },
        {"$addFields": {"other_user_obj_id": {"$toObjectId": "$_id"}}},
        {
            "$lookup": {
                "from": "users",
                "localField": "other_user_obj_id",
                "foreignField": "_id",
                "as": "user_details"
            }
        },
        {"$unwind": "$user_details"}
    ]
    results = await db["messages"].aggregate(pipeline).to_list(100)
    formatted_list = []
    for r in results:
        formatted_list.append({
            "other_user_id": str(r["_id"]),
            "other_user_name": r["user_details"].get("name", "Unknown"),
            "last_message": r["last_message"],
            "timestamp": r["timestamp"].isoformat() if r["timestamp"] else ""
        })
    return formatted_list

# 2. POST Endpoint: Campaign save karne ke liye
@app.post("/api/campaigns")
async def create_campaign(campaign: CampaignCreate):
    try:
        campaign_dict = campaign.dict()
        campaign_dict["created_at"] = datetime.utcnow()
        
        result = await db["campaigns"].insert_one(campaign_dict)
        return {"status": "success", "id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 3. GET Endpoint: Saari campaigns fetch karne ke liye (For Creators)
@app.get("/api/campaigns")
async def get_campaigns(creator_id: Optional[str] = None): # 👈 Optional creator_id add kiya
    try:
        cursor = db.campaigns.find().sort("_id", -1) # Latest campaigns pehle
        campaigns = await cursor.to_list(length=100)
        
        for c in campaigns:
            c["_id"] = str(c["_id"])
            c["application_status"] = None # Default value (yani apply nahi kiya)
            
            # Agar Flutter ne creator_id bheja hai, toh uska status check karo
            if creator_id:
                application = await db.applications.find_one({
                    "campaign_id": c["_id"],
                    "creator_id": creator_id
                })
                if application:
                    c["application_status"] = application.get("status") # pending, accepted, ya declined
                    
        return campaigns
    except Exception as e:
        return {"error": str(e)}

from bson import ObjectId

# 1. GET: Brand apni campaign ki saari applications dekhega
@app.get("/api/applications/campaign/{campaign_id}")
async def get_applications_by_campaign(campaign_id: str):
    try:
        cursor = db["applications"].find({"campaign_id": campaign_id})
        apps = await cursor.to_list(100)
        for a in apps:
            a["_id"] = str(a["_id"])  # ID ko string mein convert karna zaroori hai
        return apps
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# 2. PUT: Brand application ko Accept ya Reject karega
@app.put("/api/applications/{app_id}/status")
async def update_application_status(app_id: str, payload: StatusUpdate):
    try:
        # MongoDB mein document find karo aur status update karo
        result = await db.applications.update_one(
            {"_id": ObjectId(app_id)},
            {"$set": {"status": payload.status}}
        )
        
        if result.modified_count == 1:
            return {"message": f"Application {payload.status} successfully"}
        return {"error": "Application not found or status already set"}
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/creators/search")
async def search_creators(niche: str = None, location: str = None):
    query = {"role": "creator"} # Sirf creators ko dhoondna hai
    
    if niche and niche != "All":
        query["niche"] = niche
    if location:
        # Case-insensitive search ke liye regex use kar rahe hain
        query["location"] = {"$regex": location, "$options": "i"}
        
    cursor = db["users"].find(query)
    creators = await cursor.to_list(100)
    for c in creators:
        c["_id"] = str(c["_id"])
    return creators

@app.put("/api/users/upgrade-plan")
async def upgrade_plan(data: dict):
    user_id = data.get("user_id")
    plan_type = data.get("plan_type")
    
    result = await db["users"].update_one(
        {"_id": ObjectId(user_id)},
        {"$set": {"plan": plan_type, "is_premium": plan_type != "Free"}}
    )
    
    if result.modified_count > 0:
        return {"status": "success"}
    return {"status": "error", "message": "User not found or plan already set"}

@app.post("/api/applications")
async def create_application(app_data: ApplicationCreate):
    try:
        # 1. Check karein ke kya pehle se apply kiya hua hai?
        existing = await db["applications"].find_one({
            "campaign_id": app_data.campaign_id,
            "creator_id": app_data.creator_id
        })
        
        # 2. AGAR ALREADY APPLIED HAI, TOU IGNORE KAREIN (SUCCESS RETURN KAREIN)
        if existing:
            print(f"User {app_data.creator_id} already applied. Ignoring and returning success.")
            return {
                "status": "success", 
                "message": "Already applied, request ignored", 
                "id": str(existing["_id"])
            }

        # 3. Agar naya hai, toh insert karein
        application_dict = app_data.dict()
        application_dict["applied_at"] = datetime.utcnow()
        
        result = await db["applications"].insert_one(application_dict)
        return {"status": "success", "id": str(result.inserted_id)}
        
    except Exception as e:
        print(f"CRITICAL ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
    
@app.post("/api/create-checkout-session")
async def create_checkout_session(data: dict):
    try:
        prices = {"Pro": 1900, "Premium": 4900}
        
        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price_data': {
                    'currency': 'usd',
                    'product_data': {'name': f"{data['plan_type']} Plan"},
                    'unit_amount': prices.get(data['plan_type'], 0),
                },
                'quantity': 1,
            }],
            mode='payment',
            # Success/Cancel URLs (Flutter Web ke liye)
            success_url="http://localhost:57237/#/home/creator?payment=success",
            cancel_url="http://localhost:57237/#/subscriptions?payment=cancel",
            metadata={
                "user_id": data['user_id'],
                "plan_type": data['plan_type']
            }
        )
        return {"url": session.url}
    except Exception as e:
        print(f"Stripe Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
# 1. MESSAGE BHEJNA (POST)
@app.post("/api/send-message")
async def send_message(msg: MessageSchema):
    new_message = {
        "sender_id": msg.sender_id,
        "receiver_id": msg.receiver_id,
        "text": msg.text,
        "timestamp": datetime.utcnow()
    }
    await db.messages.insert_one(new_message)
    return {"status": "sent"}

# 2. CHAT HISTORY LENA (GET)
@app.get("/api/chat-history/{user1}/{user2}")
async def get_chat_history(user1: str, user2: str):
    # Dono sides ke messages uthane ke liye OR query
    query = {
        "$or": [
            {"sender_id": user1, "receiver_id": user2},
            {"sender_id": user2, "receiver_id": user1}
        ]
    }
    
    # Time ke hisaab se sort karein (Oldest first)
    cursor = db.messages.find(query).sort("timestamp", 1)
    messages = await cursor.to_list(length=100)
    
    # MongoDB ki _id aur datetime ko JSON compatible banayein
    for msg in messages:
        msg["_id"] = str(msg["_id"])
        if isinstance(msg["timestamp"], datetime):
            msg["timestamp"] = msg["timestamp"].isoformat()
            
    return messages

@app.get("/api/creator-dashboard/{user_id}")
async def get_creator_dashboard(user_id: str):
    try:
        # 1. Pending Invites Count (Kitni applications abhi pending hain)
        pending_count = await db.applications.count_documents({
            "creator_id": user_id, 
            "status": "pending"
        })

        # 2. Active Campaigns fetch karna (Jo accept ho chuki hain)
        cursor = db.applications.find({
            "creator_id": user_id,
            "status": {"$in": ["accepted", "In Progress"]} # Accepted wali uthayega
        })
        active_apps = await cursor.to_list(length=100)

        active_campaigns_list = []
        for app in active_apps:
            # Har application ke liye uski asli campaign ka data nikalein
            # (Taake Dashboard par Campaign ka Title aur Brand Name show ho)
            campaign = await db.campaigns.find_one({"_id": ObjectId(app["campaign_id"])})
            
            if campaign:
                active_campaigns_list.append({
                    "brand_name": campaign.get("niche", "Brand"), # Abhi niche dikha dete hain agar brand name nahi hai
                    "title": campaign.get("title", "Campaign"),
                    "status": app.get("status", "accepted").title(),
                    "deadline": campaign.get("deadline", "Open")
                })

        # 3. Final Dashboard Data Structure (Jo Flutter expect kar raha hai)
        dashboard_data = {
            "total_earnings": 0,    # Isay baad mein payment system se link karenge
            "profile_views": 150,   # Abhi ke liye dummy profile views
            "pending_invites": pending_count, # 🚀 REAL COUNT
            "active_campaigns": active_campaigns_list # 🚀 REAL CAMPAIGNS
        }
        
        return dashboard_data

    except Exception as e:
        print(f"Dashboard Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/api/search-creators")
async def search_creators(
    niche: Optional[str] = None, 
    location: Optional[str] = None,
    name: Optional[str] = None # 🚀 Name parameter yahan handle karein
):
    query = {"role": "creator"}
    
    if niche and niche != "All":
        query["niche"] = niche
    if location:
        # Case-insensitive search for location
        query["location"] = {"$regex": location, "$options": "i"}
    if name:
        # 🚀 Name ke liye regex search (taake partial name bhi dhoond sakay)
        query["name"] = {"$regex": name, "$options": "i"}

    cursor = db.users.find(query)
    creators = await cursor.to_list(length=100)
    
    # ObjectIDs ko string mein badalna
    for c in creators:
        c["_id"] = str(c["_id"])
        del c["password"] # Security ke liye password remove karein
        
    return creators