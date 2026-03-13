# API Reference & Testing Guide

## Complete API Endpoints

### Base URL
```
Development: http://localhost:8000
Production: https://api.creatorbridge.com
```

---

## Campaign Endpoints

### 1. Create Campaign
**POST** `/api/v1/campaigns`

**Authentication:** Bearer Token (required in production)

**Request Body:**
```json
{
  "title": "Instagram Post for Tech Product",
  "description": "We need a creator to promote our AI tool on Instagram",
  "niche": "tech",
  "budget": 500.00,
  "location": "San Francisco",
  "required_followers": 10000,
  "deliverables": "1 Instagram post + 5 stories + 3 Reels",
  "deadline": "2024-04-30T23:59:59Z"
}
```

**Response:** `201 Created`
```json
{
  "_id": "65a4b2c3d4e5f6g7h8i9j0k1",
  "brand_id": "65a4b2c3d4e5f6g7h8i9j0k2",
  "title": "Instagram Post for Tech Product",
  "description": "We need a creator to promote our AI tool on Instagram",
  "niche": "tech",
  "budget": 500,
  "location": "San Francisco",
  "required_followers": 10000,
  "deliverables": "1 Instagram post + 5 stories + 3 Reels",
  "deadline": "2024-04-30T23:59:59.000Z",
  "status": "open",
  "applications_count": 0,
  "created_at": "2024-03-08T10:30:00.000Z",
  "updated_at": null
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8000/api/v1/campaigns \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Promote Tech App",
    "description": "Instagram promotion needed",
    "niche": "tech",
    "budget": 1000,
    "location": "New York",
    "required_followers": 5000,
    "deliverables": "5 posts",
    "deadline": "2024-12-31T23:59:59Z"
  }'
```

---

### 2. Search Campaigns
**GET** `/api/v1/campaigns/search`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| niche | string | No | Content niche (e.g., "tech", "fitness") |
| location | string | No | Geographic location |
| min_budget | number | No | Minimum budget in USD |
| max_budget | number | No | Maximum budget in USD |
| status | string | No | "open", "in_progress", or "closed" (default: "open") |
| skip | integer | No | Pagination offset (default: 0) |
| limit | integer | No | Results per page (default: 20, max: 100) |

**Response:** `200 OK`
```json
{
  "campaigns": [
    {
      "_id": "65a4b2c3d4e5f6g7h8i9j0k1",
      "brand_id": "65a4b2c3d4e5f6g7h8i9j0k2",
      "title": "Instagram Post for Tech Product",
      "description": "...",
      "niche": "tech",
      "budget": 500,
      "location": "San Francisco",
      "required_followers": 10000,
      "deliverables": "1 Instagram post + 5 stories + 3 Reels",
      "deadline": "2024-04-30T23:59:59.000Z",
      "status": "open",
      "applications_count": 2,
      "created_at": "2024-03-08T10:30:00.000Z",
      "updated_at": null
    }
  ],
  "total": 45,
  "skip": 0,
  "limit": 20
}
```

**cURL Examples:**

Search all tech campaigns in San Francisco:
```bash
curl "http://localhost:8000/api/v1/campaigns/search?niche=tech&location=San%20Francisco"
```

Search by budget range:
```bash
curl "http://localhost:8000/api/v1/campaigns/search?min_budget=500&max_budget=5000&status=open"
```

Paginated search:
```bash
curl "http://localhost:8000/api/v1/campaigns/search?skip=20&limit=20"
```

---

### 3. Get Campaign Detail
**GET** `/api/v1/campaigns/{campaign_id}`

**Parameters:**
- `campaign_id` (path): MongoDB ObjectId

**Response:** `200 OK`
```json
{
  "_id": "65a4b2c3d4e5f6g7h8i9j0k1",
  "brand_id": "65a4b2c3d4e5f6g7h8i9j0k2",
  "title": "Instagram Post for Tech Product",
  "description": "We need a creator to promote our AI tool on Instagram",
  "niche": "tech",
  "budget": 500,
  "location": "San Francisco",
  "required_followers": 10000,
  "deliverables": "1 Instagram post + 5 stories + 3 Reels",
  "deadline": "2024-04-30T23:59:59.000Z",
  "status": "open",
  "applications_count": 2,
  "created_at": "2024-03-08T10:30:00.000Z",
  "updated_at": null
}
```

**cURL Example:**
```bash
curl http://localhost:8000/api/v1/campaigns/65a4b2c3d4e5f6g7h8i9j0k1
```

---

## Creator Endpoints

### 1. Search Creators
**GET** `/api/v1/creators/search`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| niche | string | No | Content niche |
| location | string | No | Creator's location |
| min_followers | integer | No | Minimum total followers |
| max_followers | integer | No | Maximum total followers |
| subscription_tier | string | No | "free", "pro", or "premium" |
| min_rating | number | No | Minimum rating (0-5) |
| skip | integer | No | Pagination offset |
| limit | integer | No | Results per page |

**Response:** `200 OK`
```json
{
  "creators": [
    {
      "_id": "65a4b2c3d4e5f6g7h8i9j0k3",
      "user_id": "65a4b2c3d4e5f6g7h8i9j0k4",
      "niche": "fitness",
      "bio": "Fitness influencer helping people achieve their goals",
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
  ],
  "total": 127,
  "skip": 0,
  "limit": 20
}
```

**cURL Examples:**

Search fitness creators with high followers:
```bash
curl "http://localhost:8000/api/v1/creators/search?niche=fitness&min_followers=10000"
```

Search premium creators with high ratings:
```bash
curl "http://localhost:8000/api/v1/creators/search?subscription_tier=premium&min_rating=4.5"
```

Paginated search:
```bash
curl "http://localhost:8000/api/v1/creators/search?skip=40&limit=20"
```

---

### 2. Search Creators by Location (Competitive Advantage)
**GET** `/api/v1/creators/by-location/{location}`

**Parameters:**
- `location` (path): City or region name (URL encoded)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| niche | string | No | Filter by niche |
| skip | integer | No | Pagination offset |
| limit | integer | No | Results per page |

**Response:** `200 OK`
```json
{
  "creators": [
    {
      "_id": "65a4b2c3d4e5f6g7h8i9j0k3",
      "user_id": "65a4b2c3d4e5f6g7h8i9j0k4",
      "niche": "real_estate",
      "bio": "Real estate agent and content creator",
      "pricing_per_post": 300,
      "portfolio_url": "https://example.com",
      "social_platforms": [
        {
          "platform": "instagram",
          "handle": "re_agent_nyc",
          "followers": 25000,
          "engagement_rate": 6.2
        }
      ],
      "subscription_tier": "pro",
      "total_earnings": 3000,
      "rating": 4.6,
      "created_at": "2024-01-10T12:00:00.000Z"
    }
  ],
  "total": 15,
  "skip": 0,
  "limit": 20
}
```

**cURL Examples:**

Find all creators in New York:
```bash
curl "http://localhost:8000/api/v1/creators/by-location/New%20York"
```

Find tech creators in San Francisco:
```bash
curl "http://localhost:8000/api/v1/creators/by-location/San%20Francisco?niche=tech"
```

Paginated location search:
```bash
curl "http://localhost:8000/api/v1/creators/by-location/Los%20Angeles?skip=20&limit=20"
```

---

## Health Check

### System Health
**GET** `/health`

**Response:** `200 OK`
```json
{
  "status": "healthy",
  "service": "Creator Bridge API",
  "version": "1.0.0"
}
```

**cURL Example:**
```bash
curl http://localhost:8000/health
```

---

## Error Responses

### Error Response Format
```json
{
  "detail": "Error message describing what went wrong"
}
```

### Common HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | GET request successful |
| 201 | Created | POST request created resource |
| 400 | Bad Request | Invalid query parameters |
| 401 | Unauthorized | Missing/invalid auth token |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Database connection failed |

### Error Examples

**Invalid Niche:**
```bash
curl "http://localhost:8000/api/v1/campaigns/search?niche=invalid_niche"
```
Response: `400 Bad Request`
```json
{
  "detail": "value is not a valid enumeration member; permitted: 'real_estate', 'tech', 'fitness', 'beauty', 'finance', 'travel', 'education', 'food', 'lifestyle', 'gaming', 'fashion'"
}
```

**Campaign Not Found:**
```bash
curl "http://localhost:8000/api/v1/campaigns/invalid_id"
```
Response: `400 Bad Request`
```json
{
  "detail": "Invalid campaign ID format"
}
```

---

## Testing with Postman

### Import Collection

1. Open Postman
2. Click "Import"
3. Copy this collection JSON:

```json
{
  "info": {
    "name": "Creator Bridge API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Campaigns",
      "item": [
        {
          "name": "Search Campaigns",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{baseUrl}}/api/v1/campaigns/search?niche=tech&location=SF&skip=0&limit=20",
              "host": ["localhost"],
              "port": "8000",
              "path": ["api", "v1", "campaigns", "search"],
              "query": [
                {"key": "niche", "value": "tech"},
                {"key": "location", "value": "SF"},
                {"key": "skip", "value": "0"},
                {"key": "limit", "value": "20"}
              ]
            }
          }
        },
        {
          "name": "Create Campaign",
          "request": {
            "method": "POST",
            "url": "{{baseUrl}}/api/v1/campaigns",
            "body": {
              "mode": "raw",
              "raw": "{\"title\": \"...\", \"niche\": \"tech\", ...}"
            }
          }
        }
      ]
    },
    {
      "name": "Creators",
      "item": [
        {
          "name": "Search Creators",
          "request": {
            "method": "GET",
            "url": "{{baseUrl}}/api/v1/creators/search?skip=0&limit=20"
          }
        },
        {
          "name": "Search by Location",
          "request": {
            "method": "GET",
            "url": "{{baseUrl}}/api/v1/creators/by-location/San%20Francisco"
          }
        }
      ]
    }
  ]
}
```

### Environment Variables

Create a Postman environment with:
```
baseUrl: http://localhost:8000
token: your-jwt-token
```

---

## Swift Integration Examples

### Fetch and Display Campaigns

```swift
@MainActor
class CampaignVM: ObservableObject {
    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    
    private let api = APIService()
    
    func loadCampaigns() {
        Task {
            do {
                isLoading = true
                let response = try await api.searchCampaigns(
                    niche: .tech,
                    location: "San Francisco"
                )
                campaigns = response.campaigns
                isLoading = false
            } catch {
                print("Error: \(error)")
                isLoading = false
            }
        }
    }
}
```

### Handle Pagination

```swift
func loadMore() {
    Task {
        do {
            let response = try await api.searchCampaigns(
                skip: currentPage * 20,
                limit: 20
            )
            campaigns.append(contentsOf: response.campaigns)
            currentPage += 1
        } catch {
            print("Pagination error: \(error)")
        }
    }
}
```

### Search Creators by Location

```swift
func findCreatorsInCity(_ cityName: String) {
    Task {
        do {
            isLoading = true
            let response = try await api.getCreatorsByLocation(
                location: cityName,
                niche: .fitness
            )
            creators = response.creators
            isLoading = false
        } catch {
            showError(error)
        }
    }
}
```

---

## Performance Benchmarks

### Expected Response Times
- Campaign search: < 200ms
- Creator search: < 300ms
- Location-based search: < 250ms

### Database Query Performance
- With proper indexes: O(log n) complexity
- Aggregation pipeline: Optimized on MongoDB server

### Recommendations
- Cache popular searches (Redis)
- Implement CDN for static content
- Use connection pooling
- Monitor slow queries

---

## Rate Limiting (Future)

```
Rate Limit Headers:
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1615000000

Too Many Requests:
429 Too Many Requests
Retry-After: 60
```

---

## API Versioning

Current Version: **v1**

All endpoints follow `/api/v1/` pattern.

Future: `/api/v2/`, `/api/v3/`, etc. with backward compatibility.

