from fastapi import FastAPI, Request, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from contextlib import asynccontextmanager
import logging
from datetime import datetime
import os
from dotenv import load_dotenv
from bson import ObjectId
from bson.errors import InvalidId

# Import routes
try:
    from routes import campaigns, creators, brands, messages, plans
except ImportError:
    # Fallback if routes not available
    campaigns = None
    creators = None
    brands = None
    messages = None
    plans = None

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MARK: - Database Configuration

MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "creator_bridge")

mongo_client: AsyncIOMotorClient = None
db: AsyncIOMotorDatabase = None

async def connect_to_mongo():
    """Initialize MongoDB connection"""
    global mongo_client, db
    logger.info("[CONNECT] Connecting to MongoDB...")
    mongo_client = AsyncIOMotorClient(MONGODB_URL)
    db = mongo_client[DATABASE_NAME]
    
    # Create indexes
    await create_indexes()
    logger.info("[CONNECT] Connected to MongoDB successfully")

async def close_mongo_connection():
    """Close MongoDB connection"""
    global mongo_client
    logger.info("[CLOSE] Closing MongoDB connection...")
    if mongo_client:
        mongo_client.close()
    logger.info("[CLOSE] MongoDB connection closed")

async def create_indexes():
    """Create database indexes for collections"""
    try:
        # Campaigns collection indexes
        await db.campaigns.create_index([("niche", 1), ("location", 1), ("status", 1)])
        await db.campaigns.create_index([("brand_id", 1), ("created_at", -1)])
        await db.campaigns.create_index([("status", 1), ("created_at", -1)])
        
        # Creators collection indexes
        await db.creators.create_index([("niche", 1), ("verified", 1)])
        await db.creators.create_index([("user_id", 1)])
        await db.creators.create_index([("name", "text"), ("bio", "text")])
        await db.creators.create_index([("location", 1)])
        await db.creators.create_index([("subscription_tier", 1)])
        
        # Users collection indexes
        await db.users.create_index([("email", 1)], unique=True)
        await db.users.create_index([("user_type", 1)])
        
        # Brands collection indexes
        await db.brands.create_index([("company_name", 1)])
        await db.brands.create_index([("verified", 1)])

        # Messages collection indexes
        await db.messages.create_index([("campaign_id", 1)])
        await db.messages.create_index([("from_id", 1), ("to_id", 1)])

        # Plans collection indexes
        await db.plans.create_index([("name", 1)])

        # Applications collection indexes
        await db.applications.create_index([("creator_id", 1), ("status", 1)])
        await db.applications.create_index([("campaign_id", 1)])
        await db.applications.create_index([("brand_id", 1)])
        
        logger.info("[INDEXES] Database indexes created successfully")
    except Exception as e:
        logger.error(f"[ERROR] Error creating indexes: {str(e)}")

# MARK: - Application Lifespan

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application startup and shutdown"""
    # Startup event
    await connect_to_mongo()
    logger.info("[STARTUP] Application started successfully")
    yield
    # Shutdown event
    await close_mongo_connection()
    logger.info("[SHUTDOWN] Application shutdown")

# MARK: - FastAPI Application

app = FastAPI(
    title="CreatorBridge API",
    description="API for connecting creators with brands for sponsorship campaigns",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Configuration for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MARK: - Request Logging Middleware

@app.middleware("http")
async def logging_middleware(request: Request, call_next):
    """Log all requests"""
    start_time = datetime.utcnow()
    response = await call_next(request)
    duration = (datetime.utcnow() - start_time).total_seconds()
    logger.info(
        f"{request.method} {request.url.path} - "
        f"Status: {response.status_code} - Duration: {duration:.2f}s"
    )
    return response

# MARK: - Error Handlers

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    """Handle HTTP exceptions"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "status": "error",
            "message": exc.detail,
            "status_code": exc.status_code
        }
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Handle validation errors"""
    return JSONResponse(
        status_code=422,
        content={
            "status": "error",
            "message": "Validation error",
            "errors": [{"field": e["loc"][-1], "message": e["msg"]} for e in exc.errors()]
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle general exceptions"""
    logger.error(f"Unexpected error: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "status": "error",
            "message": "Internal server error"
        }
    )

# MARK: - Dependency Injection

async def get_database() -> AsyncIOMotorDatabase:
    """Dependency to inject database"""
    return db

# MARK: - Route Registration

# Include modular routes with /api/v1 prefix
if campaigns and hasattr(campaigns, 'router'):
    app.include_router(campaigns.router, prefix="/api/v1")
if creators and hasattr(creators, 'router'):
    app.include_router(creators.router, prefix="/api/v1")
if brands and hasattr(brands, 'router'):
    app.include_router(brands.router, prefix="/api/v1")
if messages and hasattr(messages, 'router'):
    app.include_router(messages.router, prefix="/api/v1")
if plans and hasattr(plans, 'router'):
    app.include_router(plans.router, prefix="/api/v1")

# Direct simple API routes (fallback if service routes fail to load)

@app.get("/api/v1/creators", tags=["creators"])
async def list_creators_simple(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    q: str = Query(None),
    niche: str = Query(None)
):
    """
    List all creators with optional search and filtering
    """
    try:
        filter_dict = {}
        if q:
            filter_dict["$or"] = [
                {"name": {"$regex": q, "$options": "i"}},
                {"bio": {"$regex": q, "$options": "i"}}
            ]
        if niche:
            filter_dict["niches"] = {"$in": [niche]}
        
        creators = await db.creators.find(filter_dict).skip(skip).limit(limit).to_list(length=limit)
        
        # Convert ObjectId to string
        for creator in creators:
            creator['_id'] = str(creator.get('_id', ''))
        
        return creators
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/creators/{creator_id}", tags=["creators"])
async def get_creator_simple(creator_id: str):
    """
    Get creator by ID
    """
    try:
        try:
            creator_object_id = ObjectId(creator_id)
        except InvalidId:
            raise HTTPException(status_code=400, detail="Invalid creator id")

        creator = await db.creators.find_one({"_id": creator_object_id})
        if not creator:
            raise HTTPException(status_code=404, detail="Creator not found")
        
        creator['_id'] = str(creator.get('_id', ''))
        return creator
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/creators/{creator_id}/stats", tags=["creators"])
async def get_creator_stats_simple(creator_id: str):
    """
    Get creator statistics
    """
    try:
        try:
            creator_object_id = ObjectId(creator_id)
        except InvalidId:
            raise HTTPException(status_code=400, detail="Invalid creator id")

        creator = await db.creators.find_one({"_id": creator_object_id})
        if not creator:
            raise HTTPException(status_code=404, detail="Creator not found")
        
        return {
            "total_views": creator.get('monthly_reach', 0),
            "total_engagements": int(creator.get('followers', 0) * (creator.get('engagement_rate', 5) / 100)),
            "campaigns_completed": len(creator.get('portfolio', [])),
            "avg_engagement_rate": creator.get('engagement_rate', 0)
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/campaigns", tags=["campaigns"])
async def list_campaigns_simple(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    niche: str = Query(None),
    status: str = Query(None)
):
    """
    List all campaigns with optional filtering
    """
    try:
        filter_dict = {}
        if niche:
            filter_dict["niche"] = niche
        if status:
            filter_dict["status"] = status
        
        campaigns = await db.campaigns.find(filter_dict).skip(skip).limit(limit).to_list(length=limit)
        
        # Convert ObjectId to string
        for campaign in campaigns:
            campaign['_id'] = str(campaign.get('_id', ''))
        
        return campaigns
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/campaigns/{campaign_id}", tags=["campaigns"])
async def get_campaign_simple(campaign_id: str):
    """
    Get campaign by ID
    """
    try:
        try:
            campaign_object_id = ObjectId(campaign_id)
        except InvalidId:
            raise HTTPException(status_code=400, detail="Invalid campaign id")

        campaign = await db.campaigns.find_one({"_id": campaign_object_id})
        if not campaign:
            raise HTTPException(status_code=404, detail="Campaign not found")
        
        campaign['_id'] = str(campaign.get('_id', ''))
        return campaign
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# MARK: - Health Check Endpoints

@app.get("/health", tags=["health"])
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "database": "connected",
        "version": "1.0.0"
    }

@app.get("/", tags=["root"])
async def root():
    """API root endpoint"""
    return {
        "name": "CreatorBridge API",
        "version": "1.0.0",
        "description": "API for connecting creators with brands for sponsorship campaigns",
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "redoc": "/redoc",
            "campaigns": "/campaigns",
            "creators": "/creators"
        }
    }

@app.get("/api/v1/", tags=["root"])
async def api_v1_root():
    """API v1 root endpoint"""
    return {
        "version": "1.0.0",
        "status": "active",
        "modules": {
            "campaigns": "Manage campaigns and opportunities",
            "creators": "Manage creator profiles and search",
            "brands": "Manage brand profiles",
            "applications": "Manage campaign applications",
            "messages": "Direct messaging system",
            "payments": "Payment processing",
            "analytics": "Analytics and reporting"
        }
    }

# MARK: - Application Startup/Shutdown Events

@app.on_event("startup")
async def startup_event():
    """Run on application startup"""
    logger.info("[STARTUP] CreatorBridge API starting up...")
    logger.info(f"[ENV] Environment: {os.getenv('ENV', 'development')}")
    logger.info(f"[DB] Database: {DATABASE_NAME}")

@app.on_event("shutdown")
async def shutdown_event():
    """Run on application shutdown"""
    logger.info("[SHUTDOWN] CreatorBridge API shutting down...")

# MARK: - Application Entry Point

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host=os.getenv("HOST", "0.0.0.0"),
        port=int(os.getenv("PORT", 8000)),
        reload=os.getenv("ENV", "development") == "development",
        log_level="info"
    )
