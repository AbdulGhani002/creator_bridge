# Modular Backend Setup Guide

## Prerequisites

- Python 3.8+
- MongoDB installed and running locally or connection string to remote DB
- pip package manager

## Environment Setup

### Step 1: Create Virtual Environment

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate
```

### Step 2: Install Dependencies

```bash
pip install fastapi uvicorn motor pymongo python-dotenv pydantic-settings
```

### Step 3: Create .env File

Create `backend/.env`:

```env
# Database
MONGODB_URL=mongodb://localhost:27017
DATABASE_NAME=creator_bridge
ENV=development

# API
HOST=0.0.0.0
PORT=8000

# CORS (restrict in production)
CORS_ORIGINS=http://localhost:3000,http://localhost:8000
```

### Step 4: Backend Folder Structure

```
backend/
├── main.py              # Core FastAPI app
├── routes/
│   ├── __init__.py      # Package marker
│   ├── campaigns.py     # Campaign routes & service
│   └── creators.py      # Creator routes & service
├── .env                 # Environment variables
├── requirements.txt     # Dependencies
└── README.md
```

## Database Setup

### Start MongoDB

**Option 1: Local MongoDB**
```bash
# Windows (if installed as service)
mongod

# Or start service
net start MongoDB

# Mac with Homebrew
brew services start mongodb-community
```

**Option 2: Docker**
```bash
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

**Option 3: MongoDB Atlas (Cloud)**
```
# Update .env with your connection string
MONGODB_URL=mongodb+srv://user:password@cluster.mongodb.net
```

## Running the Application

### Development Mode (with auto-reload)

```bash
cd backend
python main.py
```

Or using uvicorn directly:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Production Mode

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

## API Documentation

Once running, access:

- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc
- **Health Check:** http://localhost:8000/health
- **API Root:** http://localhost:8000

## Testing Endpoints

### Campaign Routes

```bash
# Create campaign
curl -X POST http://localhost:8000/campaigns \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Summer Campaign",
    "description": "Promote summer collection",
    "budget": 2500,
    "niche": "Fashion",
    "location": "New York",
    "duration_days": 30,
    "deliverables": "5 posts + 2 videos",
    "brand_id": "507f1f77bcf86cd799439011"
  }'

# List campaigns
curl http://localhost:8000/campaigns?skip=0&limit=10

# Get campaign
curl http://localhost:8000/campaigns/{campaign_id}

# Search campaigns
curl "http://localhost:8000/campaigns?niche=Fashion&status=active"
```

### Creator Routes

```bash
# Create creator profile
curl -X POST http://localhost:8000/creators \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "507f1f77bcf86cd799439011",
    "name": "Sarah James",
    "bio": "Fashion content creator",
    "niche": "Fashion",
    "location": "New York",
    "followers_count": 125000
  }'

# List creators
curl http://localhost:8000/creators?skip=0&limit=10

# Search creators
curl "http://localhost:8000/creators/search?q=Sarah&niche=Fashion"

# Get creator
curl http://localhost:8000/creators/{creator_id}

# Get creator stats
curl http://localhost:8000/creators/{creator_id}/stats
```

## Project Structure Explanation

### main.py
- FastAPI application factory
- Middleware configuration (CORS, logging)
- Database lifecycle management
- Route registration
- Error handlers
- Health check endpoints

### routes/campaigns.py
- **Models:** Campaign, CampaignUpdate, CampaignResponse
- **Service:** CampaignService with business logic
- **Endpoints:** CRUD operations + filtering
- **Dependencies:** get_campaign_service for injection

### routes/creators.py
- **Models:** CreatorProfile, CreatorUpdate, CreatorResponse, CreatorStats
- **Service:** CreatorService with business logic
- **Endpoints:** CRUD operations + search + filtering
- **Dependencies:** get_creator_service for injection

## Adding New Routes

### 1. Create New Route File

`backend/routes/brands.py`:

```python
from fastapi import APIRouter, Depends
from motor.motor_asyncio import AsyncIOMotorDatabase
from pydantic import BaseModel

class Brand(BaseModel):
    name: str
    description: str
    industry: str

router = APIRouter(prefix="/brands", tags=["brands"])

class BrandService:
    def __init__(self, db: AsyncIOMotorDatabase):
        self.db = db
    
    async def create_brand(self, brand: Brand) -> str:
        result = await self.db.brands.insert_one(brand.dict())
        return str(result.inserted_id)

async def get_brand_service(db: AsyncIOMotorDatabase) -> BrandService:
    return BrandService(db)

@router.post("/")
async def create_brand(
    brand: Brand,
    service: BrandService = Depends(get_brand_service)
):
    brand_id = await service.create_brand(brand)
    return {"id": brand_id, "status": "success"}
```

### 2. Register in main.py

```python
from routes import brands

# In FastAPI lifespan or app setup
app.include_router(brands.router)
```

### 3. Now Available at

```
POST /brands
GET /brands
etc.
```

## Logging

The application logs all requests with duration:

```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     GET /health - Status: 200 - Duration: 0.01s
INFO:     POST /campaigns - Status: 201 - Duration: 0.12s
```

Check logs in console output.

## Troubleshooting

### MongoDB Connection Error
```
Error: connect ECONNREFUSED 127.0.0.1:27017
```
**Solution:** Make sure MongoDB is running:
- Check if mongod process is running
- If using Docker, verify container is running
- Update MONGODB_URL in .env if using remote

### Import Error: Cannot find 'routes' module
```
ModuleNotFoundError: No module named 'routes'
```
**Solution:** 
- Ensure you're running from `backend` directory
- Make sure `routes/__init__.py` exists (empty file is fine)
- Python must find routes in PYTHONPATH

### Port Already in Use
```
ERROR: [Errno 48] Address already in use
```
**Solution:** Change port in .env or kill process:
```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Mac/Linux
lsof -i :8000
kill -9 <PID>
```

### Validation Error on Request
```
422 Unprocessable Entity
```
**Solution:** Check request JSON matches model:
- All required fields present
- Correct data types
- Use `/docs` Swagger UI to verify

## Next Steps

1. **Add Authentication:** Create `routes/auth.py` with JWT
2. **Add Payments:** Create `routes/payments.py` for Stripe
3. **Add Messages:** Create `routes/messages.py` for chat
4. **Add Applications:** Create `routes/applications.py` for campaign apps
5. **Add Middleware:** Create middleware for auth, rate limiting
6. **Add Utils:** Create utils for validators, formatters
7. **Add Tests:** Create tests/ folder with pytest

## Performance Tips

1. **Database Indexing:**
   - Indexes automatically created on startup
   - Add compound indexes for common queries

2. **Caching:**
   - Consider Redis for session/cache layer
   - Cache creator/campaign searches

3. **Pagination:**
   - Always use skip/limit for list endpoints
   - Default limit to reasonable number (20)

4. **Connection Pooling:**
   - Motor handles pooling automatically
   - Adjust pool size if needed

## Monitoring in Production

```python
# Add to main.py for production
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FastApiIntegration()]
)
```

## Documentation

View API docs at:
- **Swagger UI:** `/docs`
- **ReDoc:** `/redoc`

All endpoints have docstrings that appear in documentation.

---

**Status:** Ready for development ✅
