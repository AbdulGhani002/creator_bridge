import requests
import json
import sys
import os

# Default to production if environment variable or argument is not set
BASE_URL = os.getenv("API_URL", "https://creator-bridge.apex-logic.net/api/v1")

# If 'local' is passed as argument, use localhost:8003
if len(sys.argv) > 1 and sys.argv[1] == 'local':
    BASE_URL = "http://localhost:8003/api/v1"

def test_endpoint(name, method, path, data=None, headers=None):
    url = f"{BASE_URL}{path}"
    print(f"Testing {name:20} ({method} {url})...", end=" ", flush=True)
    try:
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=10)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers, timeout=10)
        
        if response.status_code < 400:
            print("✅ SUCCESS")
            return response.json()
        else:
            print(f"❌ FAILED ({response.status_code})")
            print(f"   Response: {response.text[:200]}...")
            return None
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return None

def run_tests():
    print(f"🚀 Starting Backend API Tests on: {BASE_URL}")
    print("-" * 60)
    
    # 1. Health Check
    test_endpoint("Health Check", "GET", "/health")
    
    # 2. Auth: Signup
    test_email = f"test_prod_{os.getpid()}@apex-logic.net"
    signup_data = {
        "name": "Test User",
        "email": test_email,
        "password": "password123",
        "role": "creator",
        "location": "Test City"
    }
    test_endpoint("Signup", "POST", "/auth/signup", signup_data)
    
    # 3. Auth: Login
    login_data = {
        "email": test_email,
        "password": "password123"
    }
    login_res = test_endpoint("Login", "POST", "/auth/login", login_data)
    
    token = None
    if login_res:
        token = login_res.get("token")
    
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    
    # 4. Campaigns
    test_endpoint("Get Campaigns", "GET", "/campaigns", headers=headers)
    
    # 5. Plans
    test_endpoint("Get Plans", "GET", "/plans")
    
    # 6. Analytics
    test_endpoint("Dashboard Stats", "GET", "/analytics/dashboard", headers=headers)
    test_endpoint("Creator Analytics", "GET", "/analytics/creator/me", headers=headers)

    print("-" * 60)
    print("🏁 Tests Completed.")

if __name__ == "__main__":
    run_tests()
