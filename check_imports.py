"""Check if routes modules import correctly"""
import sys
sys.path.insert(0, '.')

print("Attempting imports...")
try:
    from routes import campaigns
    print(f"campaigns imported: {campaigns}")
    if hasattr(campaigns, 'router'):
        print(f"campaigns.router exists: {campaigns.router}")
        print(f"campaigns.router.routes: {len(campaigns.router.routes)}")
    else:
        print("campaigns does NOT have router attribute")
except Exception as e:
    print(f"Failed to import campaigns: {e}")

try:
    from routes import creators
    print(f"creators imported: {creators}")
    if hasattr(creators, 'router'):
        print(f"creators.router exists: {creators.router}")
        print(f"creators.router.routes: {len(creators.router.routes)}")
    else:
        print("creators does NOT have router attribute")
except Exception as e:
    print(f"Failed to import creators: {e}")
