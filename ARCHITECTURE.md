# Architecture & Implementation Details

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        iOS App (SwiftUI)                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  SwiftUI Views                                           │   │
│  │  • CampaignListView                                      │   │
│  │  • CreatorSearchView                                     │   │
│  │  • CampaignDetailView                                    │   │
│  │  • CreatorDetailView                                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  MVVM - ViewModels                                       │   │
│  │  • CampaignListViewModel                                 │   │
│  │  • CreatorSearchViewModel                                │   │
│  │  @MainActor for thread-safe updates                     │   │
│  │  @Published for reactive state                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                              ↓                                    │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Networking Layer (APIService)                           │   │
│  │  • Generic async/await requests                          │   │
│  │  • Automatic JSON encoding/decoding                      │   │
│  │  • Error handling & retry logic                          │   │
│  │  • Bearer token authentication                           │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ↓ HTTPS
        ┌─────────────────────────────────────────────────┐
        │   FastAPI Backend (Python)                      │
        │  ┌───────────────────────────────────────────┐  │
        │  │ Routes & Endpoints                        │  │
        │  │ • POST   /api/v1/campaigns                │  │
        │  │ • GET    /api/v1/campaigns/search         │  │
        │  │ • GET    /api/v1/campaigns/{id}           │  │
        │  │ • GET    /api/v1/creators/search          │  │
        │  │ • GET    /api/v1/creators/by-location/{} │  │
        │  └───────────────────────────────────────────┘  │
        │                      ↓                           │
        │  ┌───────────────────────────────────────────┐  │
        │  │ Business Logic Layer                      │  │
        │  │ • Data validation (Pydantic)              │  │
        │  │ • Query building & filtering              │  │
        │  │ • Error handling                          │  │
        │  └───────────────────────────────────────────┘  │
        │                      ↓                           │
        │  ┌───────────────────────────────────────────┐  │
        │  │ Database Abstraction (Motor)              │  │
        │  │ • Async MongoDB operations                │  │
        │  │ • Connection pooling                      │  │
        │  │ • Aggregation pipelines                   │  │
        │  └───────────────────────────────────────────┘  │
        └─────────────────────────────────────────────────┘
                              ↓
        ┌─────────────────────────────────────────────────┐
        │   MongoDB Database                              │
        │  • campaigns (indexed on niche, location)       │
        │  • creators (indexed on subscription_tier)      │
        │  • users (indexed on role, location)            │
        │  • applications                                 │
        │  • brands                                       │
        └─────────────────────────────────────────────────┘
```

---

## Data Flow Example: Search Campaigns

```
User taps Search →
     ↓
CampaignListView triggers loadCampaigns() →
     ↓
CampaignListViewModel.loadCampaigns() →
     ↓
Creates search parameters (niche, location, budget) →
     ↓
APIService.searchCampaigns() →
     ↓
URLSession async request to:
GET /api/v1/campaigns/search?niche=tech&location=SF&... →
     ↓
FastAPI endpoint receives request →
     ↓
Build MongoDB filter query →
     ↓
Execute aggregation pipeline:
[
  { $match: { niche: "tech", location: "SF" } },
  { $skip: 0 },
  { $limit: 20 }
] →
     ↓
MongoDB returns matching documents →
     ↓
Pydantic models validate response →
     ↓
Return CampaignSearchResponse(campaigns: [...], total: 45) →
     ↓
APIService decodes JSON to Swift models →
     ↓
ViewModel publishes @Published campaigns property →
     ↓
SwiftUI automatically re-renders CampaignListView →
     ↓
User sees campaign list ✅
```

---

## Database Schema & Relationships

### Collections Overview

```javascript
// Users Collection
{
  _id: ObjectId,
  name: String,
  email: String,
  role: "creator" | "brand",
  location: String,
  created_at: Date,
  updated_at: Date
}

// Creators Collection
{
  _id: ObjectId,
  user_id: ObjectId (ref: Users),
  niche: String,
  bio: String,
  pricing_per_post: Number,
  portfolio_url: String,
  social_platforms: [
    {
      platform: String,
      handle: String,
      followers: Number,
      engagement_rate: Number
    }
  ],
  subscription_tier: "free" | "pro" | "premium",
  total_earnings: Number,
  rating: Number (0-5),
  created_at: Date
}

// Brands Collection
{
  _id: ObjectId,
  user_id: ObjectId (ref: Users),
  company_name: String,
  industry: String,
  company_website: String,
  company_description: String,
  verified: Boolean,
  created_at: Date
}

// Campaigns Collection
{
  _id: ObjectId,
  brand_id: ObjectId (ref: Brands),
  title: String,
  description: String,
  niche: String,
  budget: Number,
  location: String,
  required_followers: Number,
  deliverables: String,
  deadline: Date,
  status: "open" | "in_progress" | "closed",
  applications_count: Number,
  created_at: Date,
  updated_at: Date
}

// Applications Collection
{
  _id: ObjectId,
  campaign_id: ObjectId (ref: Campaigns),
  creator_id: ObjectId (ref: Creators),
  proposal: String,
  status: "pending" | "accepted" | "rejected" | "completed",
  created_at: Date
}
```

### Index Strategy

```python
# Compound indexes for optimal query performance
campaigns:
  - ("niche", "location", "status")  # Main search filter
  - ("brand_id",)                     # Brand's campaigns
  - ("deadline",)                     # Expiring campaigns

creators:
  - ("niche", "subscription_tier")    # Creator search
  - ("user_id",)                      # User's profile
  - ("rating",)                       # Sorting results

users:
  - ("email",)                        # Unique lookup
  - ("location", "role")              # Location search
```

---

## MVVM Implementation Deep Dive

### ViewModel State Management

```swift
@MainActor
class CampaignListViewModel: ObservableObject {
    // Published properties notify SwiftUI of changes
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var hasError = false
    
    // Filter state
    @Published var selectedNiche: NicheType?
    @Published var selectedLocation: String = ""
    @Published var minBudget: Double?
    @Published var maxBudget: Double?
    
    // Pagination state
    @Published var currentPage = 0
    
    // Private state
    private let apiService: APIService
    private var cancellables = Set<AnyCancellable>()
    private var currentTask: Task<Void, Never>?
}
```

**Key Points:**
- `@MainActor` ensures all UI updates happen on main thread
- `@Published` properties trigger SwiftUI re-renders
- Private `apiService` handles HTTP communication
- Task cancellation prevents race conditions

### View-ViewModel Binding

```swift
struct CampaignListView: View {
    @StateObject private var viewModel = CampaignListViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.campaigns) { campaign in
                CampaignRowView(campaign: campaign)
                    .onAppear {
                        if campaign == viewModel.campaigns.last && viewModel.hasMorePages {
                            viewModel.loadMoreCampaigns()
                        }
                    }
            }
        }
        .refreshable {
            viewModel.refreshCampaigns()
        }
        .onAppear {
            viewModel.loadInitialCampaigns()
        }
    }
}
```

**View Responsibilities:**
- Display published state from ViewModel
- Handle user interactions
- Trigger ViewModel methods
- No business logic in View

---

## APIService Generic Pattern

### Generic Request Method

```swift
func request<T: Decodable>(
    path: String,
    method: HTTPMethod = .get,
    body: Encodable? = nil,
    headers: [String: String]? = nil
) async throws -> T {
    // 1. Build URL
    let url = buildURL(path: path)
    
    // 2. Create request
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    // 3. Set headers
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = authToken {
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    
    // 4. Encode body
    if let body = body {
        request.httpBody = try encoder.encode(body)
    }
    
    // 5. Execute request
    let (data, response) = try await session.data(for: request)
    
    // 6. Validate response
    try validateResponse(response)
    
    // 7. Decode response
    return try decoder.decode(T.self, from: data)
}
```

**Benefits:**
- Type-safe generic allows any Decodable type
- Single method handles all HTTP operations
- Automatic JSON encoding/decoding
- Centralized error handling

### Specialized Endpoints

```swift
// Campaign Search
func searchCampaigns(...) async throws -> CampaignSearchResponse {
    // Builds query parameters
    var queryItems: [URLQueryItem] = []
    // ... add filters ...
    
    let path = buildQueryPath("/api/v1/campaigns/search", queryItems: queryItems)
    return try await request(path: path)
}

// Creator Location Search
func getCreatorsByLocation(_ location: String, ...) async throws -> CreatorSearchResponse {
    let path = buildQueryPath(
        "/api/v1/creators/by-location/\(location)",
        queryItems: queryItems
    )
    return try await request(path: path)
}
```

---

## Error Handling Strategy

### Backend Error Response

```python
# 400: Bad Request
{"detail": "Bad request: invalid niche value"}

# 401: Unauthorized
{"detail": "Unauthorized - Please login again"}

# 404: Not Found
{"detail": "Campaign not found"}

# 500: Server Error
{"detail": "Failed to search campaigns: database connection error"}
```

### Frontend Error Handling

```swift
do {
    try await viewModel.loadCampaigns()
} catch let networkError as NetworkError {
    switch networkError {
    case .unauthorized:
        // Show login screen
    case .notFound:
        // Show empty state
    case .serverError(let code, let message):
        // Log and display error
    case .networkError:
        // Show offline indicator
    default:
        break
    }
}
```

---

## Async/Await Patterns

### Concurrent Requests

```swift
// Fetch both campaigns and creators simultaneously
async let campaigns = apiService.searchCampaigns()
async let creators = apiService.searchCreators()

let (campaignData, creatorData) = try await (campaigns, creators)
```

### Sequential Operations

```swift
let campaign = try await apiService.getCampaignDetail(id: "123")
let applications = try await apiService.getApplications(campaignId: campaign.id)
```

### Task Cancellation

```swift
private var currentTask: Task<Void, Never>?

func loadCampaigns() {
    currentTask?.cancel()  // Cancel previous request
    
    currentTask = Task {
        // Load new campaigns
    }
}

deinit {
    currentTask?.cancel()  // Clean up on dealloc
}
```

---

## Performance Optimizations

### Frontend Optimizations

```swift
// 1. Pagination - Load 20 items per page
limit: Int = Query(20, ge=1, le=100)

// 2. Search Debouncing - Wait 0.5s before searching
searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false)

// 3. Task Cancellation - Cancel outdated requests
currentTask?.cancel()

// 4. MainActor - Batch UI updates
@MainActor async func loadCampaigns()
```

### Backend Optimizations

```python
# 1. Database Indexes - Fast lookups
await db["campaigns"].create_index([("niche", 1), ("location", 1)])

# 2. Aggregation Pipeline - Efficient filtering
aggregation_pipeline = [
    {"$match": {"niche": "tech", "status": "open"}},
    {"$skip": 0},
    {"$limit": 20}
]

# 3. Motor Async - Non-blocking operations
campaigns = await db["campaigns"].find(filter).to_list(length=20)

# 4. Connection Pooling - Reuse connections
AsyncClient(MONGO_URL, maxPoolSize=10)
```

---

## Security Considerations

### Current Implementation
- ✅ Input validation with Pydantic
- ✅ HTTPS ready (use in production)
- ✅ CORS configured
- ✅ Error messages don't leak sensitive info

### To Be Implemented
- [ ] JWT Authentication
- [ ] Rate limiting (slowhttptest protection)
- [ ] Input sanitization (SQL/NoSQL injection)
- [ ] HTTPS enforcement
- [ ] Request signing
- [ ] API versioning for breaking changes
- [ ] Password hashing (bcrypt)
- [ ] OAuth2 with social providers

### Recommended Implementation

```python
from fastapi.security import OAuth2PasswordBearer, HTTPBearer
from jose import JWTError, jwt
from passlib.context import CryptContext

# Protect endpoints
@app.post("/api/v1/campaigns")
async def create_campaign(
    campaign: CampaignCreate,
    current_user: User = Depends(get_current_user)
):
    # Campaign belongs to current_user
    pass
```

---

## Testing Strategy

### Backend Testing

```python
# pytest fixtures
@pytest.fixture
async def test_db():
    await Database.connect_db()
    yield
    await Database.close_db()

# Test campaign creation
@pytest.mark.asyncio
async def test_create_campaign(test_db):
    response = await client.post(
        "/api/v1/campaigns",
        json=campaign_data
    )
    assert response.status_code == 201
```

### iOS Testing

```swift
// Mock APIService for testing
class MockAPIService: APIService {
    var mockCampaigns: [Campaign] = []
    
    override func searchCampaigns(...) async throws -> CampaignSearchResponse {
        return CampaignSearchResponse(
            campaigns: mockCampaigns,
            total: mockCampaigns.count,
            skip: 0,
            limit: 20
        )
    }
}

// Test ViewModel
@MainActor
func testLoadCampaigns() async {
    let viewModel = CampaignListViewModel(apiService: MockAPIService())
    await viewModel.loadCampaigns()
    assert(viewModel.campaigns.count > 0)
}
```

---

## Deployment Considerations

### Production Checklist

**Backend:**
- [ ] Change SECRET_KEY to production value
- [ ] Set ENV=production
- [ ] Use production MongoDB Atlas connection
- [ ] Enable rate limiting
- [ ] Setup logging aggregation
- [ ] Configure CDN for static files
- [ ] Setup database backups
- [ ] Enable HTTPS/TLS
- [ ] Configure health check endpoint

**Frontend:**
- [ ] Update API base URL
- [ ] Implement proper error reporting
- [ ] Setup crash analytics
- [ ] Configure deep linking
- [ ] Test on iOS 13+
- [ ] Submit to App Store
- [ ] Setup app version tracking

---

## Future Scalability

### Horizontal Scaling
```
Load Balancer
    ├── FastAPI Server 1
    ├── FastAPI Server 2
    └── FastAPI Server 3
        ↓
    MongoDB Replica Set
        ├── Primary
        ├── Secondary 1
        └── Secondary 2
```

### Caching Layer
```python
# Redis for frequently accessed data
redis_cache.get(f"campaign:{campaign_id}")
redis_cache.set(f"creator:by-location:{location}", creators, expires=3600)
```

### Microservices (Future)
- User Service
- Campaign Service
- Creator Service
- Messaging Service
- Payment Service
- Analytics Service

