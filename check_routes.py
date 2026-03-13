"""Check what routes are actually registered in the app"""
import sys
sys.path.insert(0, '.')
from backend.main import app

print("Registered routes:")
for route in app.routes:
    print(f"  {route.path}")
