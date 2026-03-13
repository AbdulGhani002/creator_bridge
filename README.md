# Creator Bridge - MVP Implementation Guide

## 📋 Project Overview

**Creator-Brand Sponsorship Marketplace** - An Upwork-style platform connecting content creators with brands for sponsorship opportunities.

**Tech Stack:**
- **Backend:** Python FastAPI + Motor (async MongoDB)
- **Frontend:** Swift (SwiftUI) with MVVM architecture
- **Database:** MongoDB
- **Mobile Architecture:** MVVM with async/await

---

## 🚀 Phase 1: Backend Setup (FastAPI & MongoDB)

### Prerequisites
```bash
python 3.10+
MongoDB 5.0+
pip
```

### Installation

1. **Navigate to backend directory:**
```bash
cd creator_bridge/backend
```

2. **Create virtual environment:**
```bash
python -m venv venv
source venv/Scripts/activate  # Windows
source venv/bin/activate      # macOS/Linux
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Setup environment variables:**
```bash
cp .env.example .env
```

5. **Update .env with your MongoDB connection:**
```env
MONGO_URL=mongodb://localhost:27017
DATABASE_NAME=creator_bridge
ENV=development
PORT=8000
```

### Running the Backend

```bash
python main.py
```

The API will be available at `http://localhost:8000`

Access API documentation at: `http://localhost:8000/docs`

### Database Indexes

Indexes are automatically created on startup. They include:
- Users: `email`, `role`, `location`
- Creators: `niche`, `subscription_tier`, combined indices
- Campaigns: `niche`, `location`, `status`, combined indices
- Applications: `campaign_id`, `creator_id`, unique constraint

---

## 📱 Phase 2: Swift Models & Networking

### File Structure
```
frontend/
├── Models.swift          # All Codable models
├── APIService.swift      # Generic HTTP layer
├── ViewModels.swift      # MVVM state management
├── CampaignViews.swift   # Campaign UI components
└── CreatorViews.swift    # Creator UI components
```

### Key Classes

#### **APIService - Generic HTTP Client**

Features:
- Async/await pattern for modern Swift concurrency
- Generic request method handling any Decodable type
- Automatic JSON encoding/decoding with ISO8601 dates
- Error handling with detailed NetworkError enum
- Built-in query parameter handling
- Bearer token authentication support

Usage:
```swift
let apiService = APIService(baseURL: "http://localhost:8000")

// Campaign endpoints
let campaigns = try await apiService.searchCampaigns(
    niche: .tech,
    location: "New York",
    skip: 0,
    limit: 20
)

// Creator endpoints
let creators = try await apiService.searchCreators(
    location: "San Francisco",
    minFollowers: 10000
)
```

#### **Models - Type-Safe Data**

All models implement `Codable` and use `CodingKeys` for JSON mapping:
- `Campaign` - Campaign data with computed properties
- `CreatorProfile` - Creator info with total followers calculation
- `User`, `BrandProfile` - Supporting models
- Search response models with pagination info

---

## 🏗️ Phase 3: SwiftUI & MVVM

### Architecture Pattern

```
View (SwiftUI)
    ↓
ViewModel (@MainActor, ObservableObject)
    ↓
APIService (URLSession + async/await)
    ↓
FastAPI Backend
    ↓
MongoDB
```

### CampaignListViewModel

**State Management:**
- `@Published` properties for UI updates
- Filter state: `selectedNiche`, `selectedLocation`, budget range
- Pagination: `currentPage`, page size, total count
- Loading states: `isLoading`, `error`, `hasError`

**Key Methods:**
```swift
// Load campaigns with filtering
func loadCampaigns()

// Initial load
func loadInitialCampaigns()

// Pagination
func loadMoreCampaigns()

// Filtering
func filterByNiche(_:)
func filterByLocation(_:)
func filterByBudget(min:max:)

// Error handling
func dismissError()
```

**Debouncing:**
- Search operations are debounced to prevent excessive API calls
- 0.5 second debounce timer for filter changes

### CreatorSearchViewModel

**Features:**
- Location-based search (competitive advantage)
- Advanced filtering options
- Pagination support
- Rating and follower range filters

**Specialized Method:**
```swift
func searchCreatorsByLocation(_ location: String, niche: NicheType? = nil)
```

---

## 📊 API Endpoints Reference

### Campaign Endpoints

**Create Campaign:**
```
POST /api/v1/campaigns
Content-Type: application/json

{
  "title": "Instagram Post for Tech Product",
  "description": "We need a creator to promote our AI tool...",
  "niche": "tech",
  "budget": 500,
  "location": "New York",
  "required_followers": 10000,
  "deliverables": "1x Instagram post + 5x stories",
  "deadline": "2024-03-31T23:59:59.000Z"
}

Response: Campaign object with ID
```

**Search Campaigns:**
```
GET /api/v1/campaigns/search?niche=tech&location=SF&status=open&skip=0&limit=20

Query Parameters:
- niche: (optional) Content niche
- location: (optional) Geographic location
- min_budget: (optional) Minimum budget
- max_budget: (optional) Maximum budget
- status: Campaign status (default: "open")
- skip: Pagination offset
- limit: Results per page
```

**Get Campaign Detail:**
```
GET /api/v1/campaigns/{campaign_id}
```

### Creator Endpoints

**Search Creators:**
```
GET /api/v1/creators/search?niche=fitness&min_followers=5000&limit=20

Query Parameters:
- niche: (optional) Content niche
- location: (optional) Creator location
- min_followers: (optional) Minimum followers
- max_followers: (optional) Maximum followers
- subscription_tier: (optional) free|pro|premium
- min_rating: (optional) Minimum rating (0-5)
- skip: Pagination offset
- limit: Results per page
```

**Search by Location (Competitive Advantage):**
```
GET /api/v1/creators/by-location/{location}?niche=beauty&skip=0&limit=20

This endpoint is optimized for finding creators in specific cities/regions
```

---

## 🔌 Integration Steps

### Backend to Frontend Integration

1. **Update API Base URL in Swift:**
```swift
let apiService = APIService(baseURL: ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:8000")
```

2. **Add Bearer Token for Authentication:**
```swift
apiService.authToken = "your_jwt_token_here"
```

3. **Dependency Injection in SwiftUI:**
```swift
@main
struct CreatorBridgeApp: App {
    @StateObject private var apiService = APIService()
    
    var body: some Scene {
        WindowGroup {
            CampaignListView()
                .environment(\.apiService, apiService)
        }
    }
}
```

### Testing the Integration

**1. Start MongoDB locally:**
```bash
mongod
```

**2. Start FastAPI backend:**
```bash
cd backend
python main.py
```

**3. In Xcode, set scheme environment variables:**
- Search for "Scheme" → Edit Scheme → Arguments
- Add: `PYTHONPATH=/path/to/backend`

**4. Test endpoints using curl:**
```bash
# Create a campaign
curl -X POST http://localhost:8000/api/v1/campaigns \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Promote our fitness app",
    "description": "We need 5 Instagram posts",
    "niche": "fitness",
    "budget": 1000,
    "location": "Los Angeles",
    "required_followers": 5000,
    "deliverables": "5 Instagram posts",
    "deadline": "2024-04-30T23:59:59Z"
  }'

# Search campaigns
curl "http://localhost:8000/api/v1/campaigns/search?niche=fitness&location=LA"

# Search creators by location
curl "http://localhost:8000/api/v1/creators/by-location/New%20York?niche=tech"
```

---

## 🔒 Error Handling

### Backend Error Responses
```
400 Bad Request - Invalid parameters
401 Unauthorized - Invalid/missing auth token
404 Not Found - Resource doesn't exist
500 Internal Server Error - Server error
```

### Frontend Error Handling
```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError(Error)
    case serverError(Int, String)
    case networkError(Error)
    case unauthorized
    case notFound
    case badRequest(String)
    case unknown
}
```

Handle errors in ViewModel:
```swift
do {
    try await fetchCampaigns()
} catch let error as NetworkError {
    self.error = error
    self.hasError = true
}
```

---

## 🎯 MVP Features Documentation

### 1. Creator Profiles
- ✅ Niche selection
- ✅ Social platform integration (followers, engagement)
- ✅ Subscription tiers (free, pro, premium)
- ✅ Rating system
- ✅ Portfolio URL

### 2. Brand Profiles
- ✅ Company information
- ✅ Industry classification
- ✅ Verification status

### 3. Campaign Management
- ✅ Campaign creation by brands
- ✅ Campaign status tracking
- ✅ Deadline management
- ✅ Budget specification

### 4. Creator Search & Discovery
- ✅ Search by niche
- ✅ **Location-based search (competitive advantage)**
- ✅ Filter by followers
- ✅ Filter by rating
- ✅ Subscription tier filtering
- ✅ Pagination support

### 5. Campaign Discovery
- ✅ Browse all open campaigns
- ✅ Filter by niche, location, budget
- ✅ Status-based filtering
- ✅ Pagination

---

## 📈 Performance Optimizations

### Database
- Compound indexes on frequently filtered fields
- Aggregation pipeline for complex queries
- Connection pooling via Motor

### Frontend
- `@MainActor` for thread-safe UI updates
- Debounced search queries
- Pagination for lazy loading
- Task cancellation for outdated requests
- Memory-efficient image loading (future)

### Backend
- Async operations throughout
- Query optimization with geospatial indices (future)
- Caching layer (Redis - future enhancement)

---

## 🚀 Deployment Checklist

### Backend Deployment (AWS Lambda / Railway / Heroku)
- [ ] Update MongoDB connection string to cloud instance
- [ ] Set production environment variables
- [ ] Enable HTTPS/TLS
- [ ] Setup CI/CD pipeline
- [ ] Configure CORS properly
- [ ] Add rate limiting
- [ ] Setup logging/monitoring

### iOS App Deployment
- [ ] Update API base URL to production
- [ ] Implement proper authentication flow
- [ ] Setup crash reporting (Sentry)
- [ ] Configure privacy policies
- [ ] Test on multiple iOS versions
- [ ] Submit to App Store

---

## 📚 Future Enhancements

### Phase 2 Features
- [ ] AI-powered creator recommendations
- [ ] Messaging system
- [ ] Deal agreements & contracts
- [ ] Payment integration (Stripe)
- [ ] Analytics dashboard
- [ ] Creator portfolio showcase

### Phase 3+ Features
- [ ] Video streaming for creator portfolios
- [ ] Automated creator-brand matching
- [ ] Performance scoring algorithm
- [ ] Advanced search with ML recommendations
- [ ] Social login (Google, Instagram)
- [ ] Push notifications
- [ ] In-app messaging with real-time updates

---

## 🆘 Troubleshooting

### MongoDB Connection Issues
```bash
# Check if MongoDB is running
mongosh

# Reset MongoDB
mongod --reset
```

### FastAPI Not Starting
```bash
# Check for port conflicts
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Verify dependencies
pip install -r requirements.txt --upgrade
```

### Swift Build Errors
- Clean build folder: `Cmd + Shift + K`
- Delete derived data: `~/Library/Developer/Xcode/DerivedData`
- Verify iOS deployment target matches project settings

### API Connection Issues
- Check `APIService` base URL configuration
- Verify network requests in Xcode Network Link Conditioner
- Test with curl to isolate frontend/backend issues

---

## 📞 Support & Resources

- **FastAPI Docs:** https://fastapi.tiangolo.com/
- **Motor Documentation:** https://motor.readthedocs.io/
- **SwiftUI Tutorials:** https://developer.apple.com/tutorials/swiftui
- **MongoDB Docs:** https://docs.mongodb.com/

---

## 📝 License

Proprietary - Creator Bridge © 2024

