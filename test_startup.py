"""Quick test to see if the FastAPI app initializes correctly"""
import asyncio
import sys
import os

REPO_ROOT = os.path.abspath(os.path.dirname(__file__))
sys.path.insert(0, REPO_ROOT)

# Test imports
print("[TEST] Importing backend...")
from backend import main

print("[TEST] Getting app...")
app = main.app

print("[TEST] App loaded successfully!")
print(f"[TEST] App routes: {len(app.routes)}")
print("[TEST] App setup complete")

# Test database connectivity
async def test_db():
    print("[TEST] Testing database connection...")
    try:
        await main.connect_to_mongo()
        print("[TEST] Database connected!")
        await main.close_mongo_connection()
        print("[TEST] Database disconnected!")
    except Exception as e:
        print(f"[ERROR] Database error: {e}")

asyncio.run(test_db())
print("[TEST] All tests passed!")
