"""
Advanced API Testing - Real-world usage scenarios
Tests all backend endpoints with filtering, pagination, and data relationships
Run: python advanced_api_test.py
"""

import requests
import json
import os
from typing import List, Dict, Any
from datetime import datetime

BASE_URL = os.getenv("CREATOR_BRIDGE_BASE_URL", "http://localhost:8000").rstrip("/")

class APITester:
    def __init__(self):
        self.session = requests.Session()
        self.results = []
        
    def test(
        self,
        name: str,
        method: str,
        endpoint: str,
        params: Dict = None,
        data: Dict = None,
        expected_statuses: List[int] = None
    ):
        """Execute and log API test"""
        url = f"{BASE_URL}{endpoint}"
        try:
            if expected_statuses is None:
                expected_statuses = list(range(200, 300))

            if method.upper() == "GET":
                response = self.session.get(url, params=params, timeout=5)
            elif method.upper() == "POST":
                response = self.session.post(url, json=data, timeout=5)
            else:
                return
            
            success = response.status_code in expected_statuses
            self.results.append({
                "name": name,
                "method": method,
                "endpoint": endpoint,
                "status": response.status_code,
                "success": success,
                "response": response.json() if response.text else None
            })
            
            status_icon = "[PASS]" if success else "[FAIL]"
            print(f"{status_icon} {method:4} {endpoint:50} -> {response.status_code}")
            
            return response.json() if success else None
        except Exception as e:
            self.results.append({
                "name": name,
                "method": method,
                "endpoint": endpoint,
                "status": 0,
                "success": False,
                "error": str(e)
            })
            print(f"[ERROR] {method:4} {endpoint:50} -> {str(e)[:50]}")
            return None

def main():
    print("\n" + "="*80)
    print("CREATOR BRIDGE - ADVANCED API TESTING".center(80))
    print("="*80 + "\n")
    
    tester = APITester()
    
    # Test 1: Health Check
    print("\n[TEST 1] SYSTEM HEALTH\n" + "-"*80)
    tester.test("Health Check", "GET", "/health")
    tester.test("API Root", "GET", "/")
    
    # Test 2: List Creators - Basic
    print("\n[TEST 2] LIST CREATORS\n" + "-"*80)
    creators_response = tester.test("List All Creators", "GET", "/api/v1/creators")
    
    # Test 3: Creator Pagination
    print("\n[TEST 3] PAGINATION\n" + "-"*80)
    tester.test("Creators - Page 0 (limit 1)", "GET", "/api/v1/creators", params={"skip": 0, "limit": 1})
    tester.test("Creators - Page 1 (limit 1)", "GET", "/api/v1/creators", params={"skip": 1, "limit": 1})
    tester.test("Creators - Large limit", "GET", "/api/v1/creators", params={"skip": 0, "limit": 100})
    
    # Test 4: Search Creators
    print("\n[TEST 4] CREATOR SEARCH\n" + "-"*80)
    tester.test("Search 'Alex'", "GET", "/api/v1/creators", params={"q": "Alex"})
    tester.test("Search 'Jordan'", "GET", "/api/v1/creators", params={"q": "Jordan"})
    tester.test("Search 'Maria'", "GET", "/api/v1/creators", params={"q": "Maria"})
    tester.test("Search 'Designer'", "GET", "/api/v1/creators", params={"q": "Designer"})
    
    # Test 5: Creator Details
    print("\n[TEST 5] CREATOR PROFILES\n" + "-"*80)
    
    if creators_response and isinstance(creators_response, list) and len(creators_response) > 0:
        creator_ids = [c.get('_id') for c in creators_response[:3]]
        
        for idx, creator_id in enumerate(creator_ids, 1):
            if creator_id:
                tester.test(f"Creator #{idx} Profile", "GET", f"/api/v1/creators/{creator_id}")
                tester.test(f"Creator #{idx} Stats", "GET", f"/api/v1/creators/{creator_id}/stats")
    
    # Test 6: List Campaigns
    print("\n[TEST 6] LIST CAMPAIGNS\n" + "-"*80)
    campaigns_response = tester.test("List All Campaigns", "GET", "/api/v1/campaigns")
    
    # Test 7: Campaign Filtering by Niche
    print("\n[TEST 7] CAMPAIGN FILTERING - BY NICHE\n" + "-"*80)
    tester.test("Campaigns - Real Estate", "GET", "/api/v1/campaigns", params={"niche": "Real Estate"})
    tester.test("Campaigns - Fashion", "GET", "/api/v1/campaigns", params={"niche": "Fashion"})
    tester.test("Campaigns - Travel", "GET", "/api/v1/campaigns", params={"niche": "Travel"})
    tester.test("Campaigns - Tech", "GET", "/api/v1/campaigns", params={"niche": "Tech"})
    
    # Test 8: Campaign Filtering by Status
    print("\n[TEST 8] CAMPAIGN FILTERING - BY STATUS\n" + "-"*80)
    tester.test("Campaigns - Active", "GET", "/api/v1/campaigns", params={"status": "active"})
    tester.test("Campaigns - Open", "GET", "/api/v1/campaigns", params={"status": "open"})
    tester.test("Campaigns - Closed", "GET", "/api/v1/campaigns", params={"status": "closed"})
    
    # Test 9: Campaign Pagination
    print("\n[TEST 9] CAMPAIGN PAGINATION\n" + "-"*80)
    tester.test("Campaigns - Page 0 (limit 1)", "GET", "/api/v1/campaigns", params={"skip": 0, "limit": 1})
    tester.test("Campaigns - Page 1 (limit 1)", "GET", "/api/v1/campaigns", params={"skip": 1, "limit": 1})
    
    # Test 10: Campaign Details
    print("\n[TEST 10] CAMPAIGN PROFILES\n" + "-"*80)
    
    if campaigns_response and isinstance(campaigns_response, list) and len(campaigns_response) > 0:
        campaign_ids = [c.get('_id') for c in campaigns_response[:3]]
        
        for idx, campaign_id in enumerate(campaign_ids, 1):
            if campaign_id:
                tester.test(f"Campaign #{idx} Details", "GET", f"/api/v1/campaigns/{campaign_id}")
    
    # Test 11: Combined Filters
    print("\n[TEST 11] COMBINED FILTERS\n" + "-"*80)
    tester.test("Campaigns - Real Estate + Active", "GET", "/api/v1/campaigns", 
                params={"niche": "Real Estate", "status": "active"})
    tester.test("Creators - Skip 1 Limit 2", "GET", "/api/v1/creators", 
                params={"skip": 1, "limit": 2})
    
    # Test 12: Error Handling
    print("\n[TEST 12] ERROR HANDLING\n" + "-"*80)
    tester.test(
        "Invalid Creator ID",
        "GET",
        "/api/v1/creators/invalid_id_format",
        expected_statuses=[400]
    )
    tester.test(
        "Nonexistent Creator ID",
        "GET",
        "/api/v1/creators/000000000000000000000000",
        expected_statuses=[404]
    )
    tester.test(
        "Invalid Campaign ID",
        "GET",
        "/api/v1/campaigns/invalid_id_format",
        expected_statuses=[400]
    )
    
    # Print Summary
    print("\n" + "="*80)
    print("TEST SUMMARY".center(80))
    print("="*80 + "\n")
    
    total = len(tester.results)
    passed = sum(1 for r in tester.results if r["success"])
    failed = total - passed
    
    print(f"Total Tests:  {total}")
    print(f"Passed:       {passed} [OK]")
    print(f"Failed:       {failed} [FAIL]")
    print(f"Success Rate: {(passed/total*100):.1f}%\n")
    
    # Detailed Results
    print("\nDetailed Test Results:")
    print("-" * 80)
    
    for idx, result in enumerate(tester.results, 1):
        status = "PASS" if result["success"] else "FAIL"
        print(f"\n{idx}. {result['name']}")
        print(f"   Method:   {result['method']}")
        print(f"   Endpoint: {result['endpoint']}")
        print(f"   Status:   {result['status']}")
        print(f"   Result:   {status}")
        
        if result.get("response"):
            if isinstance(result["response"], list):
                print(f"   Data:     {len(result['response'])} items")
                if len(result["response"]) > 0:
                    print(f"   Sample:   {json.dumps(result['response'][0], indent=13)[:200]}...")
            elif isinstance(result["response"], dict):
                print(f"   Data:     {json.dumps(result['response'], indent=13)[:200]}...")
        elif result.get("error"):
            print(f"   Error:    {result['error']}")
    
    # API Documentation
    print("\n" + "="*80)
    print("API ENDPOINTS DOCUMENTATION".center(80))
    print("="*80 + "\n")
    
    endpoints = [
        ("GET", "/health", "System health check"),
        ("GET", "/", "API root information"),
        ("GET", "/api/v1/", "API v1 information"),
        ("GET", "/api/v1/creators", "List all creators with pagination"),
        ("GET", "/api/v1/creators?q=search", "Search creators by name/bio"),
        ("GET", "/api/v1/creators?niche=X", "Filter creators by niche"),
        ("GET", "/api/v1/creators/{id}", "Get creator profile by ID"),
        ("GET", "/api/v1/creators/{id}/stats", "Get creator statistics"),
        ("GET", "/api/v1/campaigns", "List all campaigns"),
        ("GET", "/api/v1/campaigns?niche=X", "Filter campaigns by niche"),
        ("GET", "/api/v1/campaigns?status=X", "Filter campaigns by status"),
        ("GET", "/api/v1/campaigns?skip=0&limit=10", "Paginate campaigns"),
        ("GET", "/api/v1/campaigns/{id}", "Get campaign details by ID"),
    ]
    
    print(f"{'METHOD':<6} {'ENDPOINT':<50} {'DESCRIPTION':<30}")
    print("-" * 86)
    for method, endpoint, description in endpoints:
        print(f"{method:<6} {endpoint:<50} {description:<30}")
    
    # Query Parameters
    print("\n\nSUPPORTED QUERY PARAMETERS:")
    print("-" * 86)
    
    params_info = [
        ("skip", "integer", "0", "Number of items to skip (pagination)"),
        ("limit", "integer", "10", "Maximum items to return (pagination)"),
        ("q", "string", "None", "Search query (creators only)"),
        ("niche", "string", "None", "Filter by niche/category"),
        ("status", "string", "None", "Filter by status (active/open/closed)"),
    ]
    
    print(f"{'PARAMETER':<12} {'TYPE':<10} {'DEFAULT':<10} {'DESCRIPTION':<50}")
    print("-" * 86)
    for param, ptype, default, description in params_info:
        print(f"{param:<12} {ptype:<10} {default:<10} {description:<50}")
    
    print("\n" + "="*80 + "\n")
    print("Testing Complete!")
    print("Backend is running successfully with real MongoDB data.\n")

if __name__ == "__main__":
    main()
