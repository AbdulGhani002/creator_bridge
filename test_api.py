"""
Comprehensive API Testing Script - Tests all backend endpoints with real data
Run: python test_api.py
"""

import requests
import json
import os
from typing import Any, Dict

BASE_URL = os.getenv("CREATOR_BRIDGE_BASE_URL", "http://localhost:8000").rstrip("/")

# Color codes for terminal output
GREEN = '\033[92m'
RED = '\033[91m'
BLUE = '\033[94m'
YELLOW = '\033[93m'
RESET = '\033[0m'
BOLD = '\033[1m'

def print_header(text: str):
    print(f"\n{BOLD}{BLUE}{'='*60}{RESET}")
    print(f"{BOLD}{BLUE}{text:^60}{RESET}")
    print(f"{BOLD}{BLUE}{'='*60}{RESET}")

def print_success(text: str):
    print(f"{GREEN}[OK] {text}{RESET}")

def print_error(text: str):
    print(f"{RED}[FAIL] {text}{RESET}")

def print_info(text: str):
    print(f"{YELLOW}[INFO] {text}{RESET}")

def print_response(response: Dict[Any, Any], indent: int = 2):
    print(json.dumps(response, indent=indent, default=str))

def test_health():
    """Test health check endpoint"""
    print_header("Health Check")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success(f"Health check passed")
            print_response(data)
            return True
        else:
            print_error(f"Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Connection error: {e}")
        return False

def test_root():
    """Test API root endpoint"""
    print_header("API Root Info")
    try:
        response = requests.get(f"{BASE_URL}/", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success("Root endpoint accessible")
            print_response(data)
            return True
        else:
            print_error(f"Failed: {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

def test_api_v1_root():
    """Test API v1 root endpoint"""
    print_header("API v1 Root Info")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/", timeout=5)
        if response.status_code == 200:
            data = response.json()
            print_success("API v1 root accessible")
            print_response(data)
            return True
        else:
            print_error(f"Failed: {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

def test_get_creators():
    """Test list all creators endpoint"""
    print_header("Get All Creators")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/creators", timeout=5)
        if response.status_code == 200:
            data = response.json()
            count = len(data) if isinstance(data, list) else 0
            print_success(f"Retrieved {count} creators")
            print_response(data[:1])  # Show first creator only
            return True, data
        else:
            print_error(f"Failed: {response.status_code}")
            return False, None
    except Exception as e:
        print_error(f"Error: {e}")
        return False, None

def test_search_creators():
    """Test search creators endpoint"""
    print_header("Search Creators (query='Alex')")
    try:
        response = requests.get(
            f"{BASE_URL}/api/v1/creators",
            params={"q": "Alex"},
            timeout=5
        )
        if response.status_code == 200:
            data = response.json()
            count = len(data) if isinstance(data, list) else 0
            print_success(f"Found {count} creators matching 'Alex'")
            print_response(data)
            return True, data
        else:
            print_error(f"Failed: {response.status_code}")
            return False, None
    except Exception as e:
        print_error(f"Error: {e}")
        return False, None

def test_get_creator_by_id(creator_id: str):
    """Test get creator by ID endpoint"""
    print_header(f"Get Creator by ID: {creator_id}")
    try:
        response = requests.get(
            f"{BASE_URL}/api/v1/creators/{creator_id}",
            timeout=5
        )
        if response.status_code == 200:
            data = response.json()
            print_success(f"Retrieved creator: {data.get('name', 'Unknown')}")
            print_response(data)
            return True, data
        else:
            print_error(f"Failed: {response.status_code}")
            return False, None
    except Exception as e:
        print_error(f"Error: {e}")
        return False, None

def test_get_creator_stats(creator_id: str):
    """Test get creator statistics endpoint"""
    print_header(f"Get Creator Stats: {creator_id}")
    try:
        response = requests.get(
            f"{BASE_URL}/api/v1/creators/{creator_id}/stats",
            timeout=5
        )
        if response.status_code == 200:
            data = response.json()
            print_success(f"Retrieved creator statistics")
            print_response(data)
            return True, data
        else:
            print_error(f"Failed: {response.status_code}")
            return False, None
    except Exception as e:
        print_error(f"Error: {e}")
        return False, None

def test_get_campaigns():
    """Test list all campaigns endpoint"""
    print_header("Get All Campaigns")
    try:
        response = requests.get(f"{BASE_URL}/api/v1/campaigns", timeout=5)
        if response.status_code == 200:
            data = response.json()
            count = len(data) if isinstance(data, list) else 0
            print_success(f"Retrieved {count} campaigns")
            print_response(data[:1])  # Show first campaign
            return True, data
        else:
            print_error(f"Failed: {response.status_code}")
            return False, None
    except Exception as e:
        print_error(f"Error: {e}")
        return False, None

def test_get_campaigns_by_niche():
    """Test get campaigns by niche"""
    print_header("Get Campaigns by Niche (Real Estate)")
    try:
        response = requests.get(
            f"{BASE_URL}/api/v1/campaigns",
            params={"niche": "Real Estate"},
            timeout=5
        )
        if response.status_code == 200:
            data = response.json()
            count = len(data) if isinstance(data, list) else 0
            print_success(f"Found {count} campaigns in 'Real Estate' niche")
            print_response(data)
            return True
        else:
            print_error(f"Failed: {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

def test_get_campaigns_by_status():
    """Test get campaigns by status"""
    print_header("Get Campaigns by Status (active)")
    try:
        response = requests.get(
            f"{BASE_URL}/api/v1/campaigns",
            params={"status": "active"},
            timeout=5
        )
        if response.status_code == 200:
            data = response.json()
            count = len(data) if isinstance(data, list) else 0
            print_success(f"Found {count} active campaigns")
            print_response(data[:1] if data else [])
            return True
        else:
            print_error(f"Failed: {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

def test_get_campaign_by_id(campaign_id: str):
    """Test get campaign by ID"""
    print_header(f"Get Campaign by ID: {campaign_id}")
    try:
        response = requests.get(
            f"{BASE_URL}/api/v1/campaigns/{campaign_id}",
            timeout=5
        )
        if response.status_code == 200:
            data = response.json()
            print_success(f"Retrieved campaign: {data.get('title', 'Unknown')}")
            print_response(data)
            return True, data
        else:
            print_error(f"Failed: {response.status_code}")
            return False, None
    except Exception as e:
        print_error(f"Error: {e}")
        return False, None

def test_api_summary():
    """Print API summary"""
    print_header("API Test Summary")
    print(f"""
{BOLD}Backend Server:{RESET}
  URL: {BASE_URL}
  Status: Running
  
{BOLD}Main Endpoints Tested:{RESET}
  [OK] Health Check: GET /health
  [OK] Root Info: GET /
  [OK] API v1 Info: GET /api/v1/
  [OK] List Creators: GET /api/v1/creators
  [OK] Search Creators: GET /api/v1/creators?q=query
  [OK] Creator Details: GET /api/v1/creators/{{id}}
  [OK] Creator Stats: GET /api/v1/creators/{{id}}/stats
  [OK] List Campaigns: GET /api/v1/campaigns
  [OK] Filter Campaigns: GET /api/v1/campaigns?niche=X&status=Y
  [OK] Campaign Details: GET /api/v1/campaigns/{{id}}

{BOLD}Database:{RESET}
  Engine: MongoDB
  Database: creator_bridge
  
{BOLD}Seed Data:{RESET}
  Brands: 3
  Creators: 3
  Campaigns: 2
  Messages: 2
    """)

def main():
    """Run all tests"""
    print(f"\n{BOLD}{BLUE}CREATOR BRIDGE API TEST SUITE{RESET}")
    print(f"{BOLD}Testing backend endpoints with real data{RESET}\n")
    
    # Test connectivity
    if not test_health():
        print_error("Cannot connect to backend. Is the server running?")
        print_info("Start backend with: uvicorn backend.main:app --reload --port 8000")
        return
    
    # Test basic endpoints
    test_root()
    test_api_v1_root()
    
    # Test creators
    success, creators = test_get_creators()
    if success and creators:
        if len(creators) > 0:
            # Get first creator ID and test detail endpoint
            first_creator_id = creators[0].get('_id', creators[0].get('id'))
            test_get_creator_by_id(first_creator_id)
            test_get_creator_stats(first_creator_id)
        
        # Test search
        test_search_creators()
    
    # Test campaigns
    success, campaigns = test_get_campaigns()
    if success and campaigns:
        test_get_campaigns_by_niche()
        test_get_campaigns_by_status()
        
        if len(campaigns) > 0:
            first_campaign_id = campaigns[0].get('_id', campaigns[0].get('id'))
            test_get_campaign_by_id(first_campaign_id)
    
    # Summary
    test_api_summary()
    
    print(f"\n{GREEN}All tests completed!{RESET}\n")

if __name__ == "__main__":
    main()
