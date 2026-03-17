from fastapi import FastAPI, Request, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from motor.motor_asyncio import AsyncIOMotorDatabase
from contextlib import asynccontextmanager
import logging
from datetime import datetime
import os
from dotenv import load_dotenv
from bson import ObjectId
from bson.errors import InvalidId
from database import Database, get_database

# Import routes
from routes import campaigns, creators, brands, messages, plans
from routes import auth, applications, agreements, reviews, reports, blocks, subscriptions, analytics, payments

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# MARK: - Database Configuration (uses Database utility)

# MARK: - Application Lifespan

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application startup and shutdown"""
    # Startup event
    await Database.connect_db()
    logger.info("[STARTUP] Application started successfully")
    yield
    # Shutdown event
    await Database.close_db()
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

# get_database dependency imported from database.py

# MARK: - Route Registration

# Include modular routes with /api/v1 prefix
app.include_router(campaigns.router, prefix="/api/v1")
app.include_router(creators.router, prefix="/api/v1")
app.include_router(brands.router, prefix="/api/v1")
app.include_router(messages.router, prefix="/api/v1")
app.include_router(plans.router, prefix="/api/v1")
app.include_router(auth.router, prefix="/api/v1")
app.include_router(applications.router, prefix="/api/v1")
app.include_router(agreements.router, prefix="/api/v1")
app.include_router(reviews.router, prefix="/api/v1")
app.include_router(reports.router, prefix="/api/v1")
app.include_router(blocks.router, prefix="/api/v1")
app.include_router(subscriptions.router, prefix="/api/v1")
app.include_router(analytics.router, prefix="/api/v1")
app.include_router(payments.router, prefix="/api/v1")

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
    logger.info(f"[DB] Database: {os.getenv('DATABASE_NAME', 'creator_bridge')}")

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
