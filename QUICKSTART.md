# QUICKSTART GUIDE

## 5-Minute Setup

### Backend Setup
```bash
# 1. Navigate to backend
cd creator_bridge/backend

# 2. Create Python environment
python -m venv venv
source venv/Scripts/activate  # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Start MongoDB (separate terminal)
mongod

# 5. Run FastAPI server
python main.py
```

**Backend Ready:** `http://localhost:8000` ✅

### iOS App Setup

1. **Open in Xcode:**
   - File → Add Files to Project
   - Select `frontend` folder
   - Or copy Models.swift, APIService.swift, ViewModels.swift, CampaignViews.swift, CreatorViews.swift into your Xcode project

2. **Configure API Connection:**
   ```swift
   // In your main app view
   let apiService = APIService(baseURL: "http://localhost:8000")
   ```

3. **Run in Simulator:**
   - Build and run in Xcode (Cmd + R)

**App Ready:** Campaigns and Creators search working ✅

---

## Test the Complete Flow

### 1. Create a Campaign (via API)
```bash
curl -X POST http://localhost:8000/api/v1/campaigns \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Instagram Promotion",
    "description": "Promote our new fitness app on Instagram",
    "niche": "fitness",
    "budget": 500,
    "location": "San Francisco",
    "required_followers": 5000,
    "deliverables": "2 Instagram posts + 10 stories",
    "deadline": "2024-12-31T23:59:59Z"
  }'
```

### 2. Search Campaigns in iOS
```swift
@Published var campaigns: [Campaign] = []

Task {
    let response = try await apiService.searchCampaigns(
        niche: .fitness,
        location: "San Francisco",
        skip: 0,
        limit: 20
    )
    self.campaigns = response.campaigns
}
```

### 3. Search Creators by Location
```swift
let creators = try await apiService.getCreatorsByLocation(
    location: "New York",
    niche: .tech
)
```

---

## API Responses Examples

### Campaign Response
```json
{
  "_id": "65a4b2c3d4e5f6g7h8i9j0k1",
  "brand_id": "65a4b2c3d4e5f6g7h8i9j0k2",
  "title": "Instagram Promotion",
  "description": "Promote our new fitness app on Instagram",
  "niche": "fitness",
  "budget": 500,
  "location": "San Francisco",
  "required_followers": 5000,
  "deliverables": "2 Instagram posts + 10 stories",
  "deadline": "2024-12-31T23:59:59.000Z",
  "status": "open",
  "applications_count": 2,
  "created_at": "2024-03-08T10:30:00.000Z",
  "updated_at": null
}
```

### Creator Response
```json
{
  "_id": "65a4b2c3d4e5f6g7h8i9j0k3",
  "user_id": "65a4b2c3d4e5f6g7h8i9j0k4",
  "niche": "fitness",
  "bio": "Fitness influencer with 50k followers",
  "pricing_per_post": 200,
  "portfolio_url": "https://example.com/portfolio",
  "social_platforms": [
    {
      "platform": "instagram",
      "handle": "fitnessguru",
      "followers": 50000,
      "engagement_rate": 8.5
    }
  ],
  "subscription_tier": "pro",
  "total_earnings": 5000,
  "rating": 4.8,
  "created_at": "2024-02-15T08:00:00.000Z"
}
```

---

## Key Code Snippets

### Create Campaign in Swift
```swift
let campaign = CampaignCreateRequest(
    title: "Fitness App Promotion",
    description: "Promote our iOS fitness tracking app",
    niche: .fitness,
    budget: 1000,
    location: "Los Angeles",
    requiredFollowers: 10000,
    deliverables": "3 TikTok videos",
    deadline: Date().addingTimeInterval(30 * 24 * 3600)
)

let created = try await apiService.createCampaign(campaign)
```

### Search with Filters
```swift
let campaigns = try await apiService.searchCampaigns(
    niche: .tech,
    location: "San Francisco",
    minBudget: 500,
    maxBudget: 5000,
    status: .open,
    skip: 0,
    limit: 20
)

print("Found \(campaigns.total) campaigns")
print("Page has \(campaigns.campaigns.count) items")
print("Has more: \(campaigns.hasMore)")
```

### Handle Errors
```swift
do {
    let creators = try await apiService.searchCreators()
} catch let error as NetworkError {
    switch error {
    case .unauthorized:
        print("Login required")
    case .notFound:
        print("No creators found")
    case .serverError(let code, let message):
        print("Server error \(code): \(message)")
    default:
        print("Error: \(error.errorDescription ?? "Unknown")")
    }
}
```

---

## Environment Configuration

### Backend .env
```env
MONGO_URL=mongodb://localhost:27017
DATABASE_NAME=creator_bridge
ENV=development
PORT=8000
SECRET_KEY=your-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### Swift Configuration
```swift
let isDevelopment = true
let apiBaseURL = isDevelopment 
    ? "http://localhost:8000" 
    : "https://api.creatorbridge.com"
```

---

## Debugging

### View API Docs
```
http://localhost:8000/docs
```

### Enable Verbose Logging (Backend)
```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

### Network Debugging (Swift)
```swift
// Add to Scheme → Run → Arguments Passed On Launch
-com.apple.CoreFoundation.Logging DEBUG_LEVEL=4
```

### Check Database
```bash
mongosh
use creator_bridge
db.campaigns.find().pretty()
db.creators.find().pretty()
```

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| MongoDB connection refused | Make sure `mongod` is running |
| Port 8000 already in use | Kill process: `lsof -i :8000` or change PORT in .env |
| Swift build fails | Clean build: `Cmd+Shift+K` then rebuild |
| API returns 404 | Check MongoDB collection has documents |
| Async/await errors in Swift | Ensure iOS 13+ deployment target |
| CORS errors | Check CORS_ORIGINS in .env |

---

## Next Steps

1. ✅ **MVP Complete** - Campaigns & Creators search working
2. 🔗 **Add Authentication** - Implement JWT login
3. 💬 **Add Messaging** - Real-time chat between users
4. 💳 **Add Payments** - Stripe integration
5. 📊 **Add Analytics** - Track views and engagement
6. 🤖 **Add AI Matching** - Recommend creators to brands

---

## Support

- Check `/backend/main.py` for all available endpoints
- Review `/frontend/APIService.swift` for API patterns
- See README.md for detailed documentation

