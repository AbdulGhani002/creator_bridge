import pymongo
from pymongo import MongoClient
from datetime import datetime, timedelta, timezone
import os
import random
import bcrypt
from dotenv import load_dotenv

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "creator_bridge")

# High Quality Sample Images
CREATOR_IMAGES = [
    "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=400&q=80",
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80",
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80"
]

BRAND_IMAGES = [
    "https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=400&q=80", # Watch
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=400&q=80", # Shoe
    "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=400&q=80", # Headphones
]

CAMPAIGN_IMAGES = [
    "https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=800&q=80", # Villa
    "https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?auto=format&fit=crop&w=800&q=80", # Fashion
    "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80", # Tech
]

def get_now():
    return datetime.now(timezone.utc)

def hash_password(password: str) -> str:
    pwd_bytes = password.encode('utf-8')[:72]
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')

def seed_data():
    """Populate database with realistic data"""
    password_hash = hash_password("password123")
    
    try:
        client = MongoClient(MONGODB_URL, serverSelectionTimeoutMS=5000)
        client.server_info()
        db = client[DATABASE_NAME]
        print(f"[OK] Connected to MongoDB at {MONGODB_URL}")
    except Exception as e:
        print(f"[ERROR] Failed to connect to MongoDB: {e}")
        return

    print("[*] Starting data seeding...")
    
    # Drop collections to clear documents AND indexes
    collections = ["users", "campaigns", "creators", "brands", "messages", "plans", "applications", "agreements", "subscriptions"]
    for coll in collections:
        db[coll].drop()
    print("[*] Dropped existing collections (cleared data & indexes)")

    # 1. Seed Subscription Plans (Crucial for App Logic)
    print("[*] Seeding subscription plans...")
    plans_data = [
        {
            "name": "Basic",
            "price": 0,
            "period": "mo",
            "description": "Perfect for hobbyists just starting out.",
            "features": ["Standard Profile Page", "Basic Analytics", "Search Visibility"],
            "highlighted": False,
            "created_at": get_now()
        },
        {
            "name": "Pro",
            "price": 19,
            "period": "mo",
            "description": "Get discovered by brands and followers.",
            "features": ["Everything in Basic", "Appear in Search Results", "Advanced Audience Insights", "Custom Profile URL"],
            "highlighted": True,
            "created_at": get_now()
        },
        {
            "name": "Premium",
            "price": 49,
            "period": "mo",
            "description": "Maximum exposure for top creators.",
            "features": ["Everything in Pro", "Featured Listing (Top 1%)", "Ad-free Profile for Fans", "Priority Support 24/7"],
            "highlighted": False,
            "created_at": get_now()
        }
    ]
    db.plans.insert_many(plans_data)

    # 2. Seed Users & Profiles
    print("[*] Seeding users, creators, and brands...")
    
    # Demo Creator: Alex Rivera
    alex_user = {
        "name": "Alex Rivera",
        "email": "alex@creatorbridge.com",
        "password_hash": password_hash,
        "role": "creator",
        "location": "Dubai, UAE",
        "created_at": get_now(),
        "is_active": True
    }
    alex_id = str(db.users.insert_one(alex_user).inserted_id)
    
    db.creators.insert_one({
        "user_id": alex_id,
        "name": "Alex Rivera",
        "bio": "Travel enthusiast, luxury lifestyle and real estate content creator based in Dubai. Passionate about showcasing the finest properties and extraordinary experiences.",
        "niche": "real_estate",
        "location": "Dubai, UAE",
        "followers_count": 365400,
        "verified": True,
        "profile_image_url": "https://lh3.googleusercontent.com/aida-public/AB6AXuCNAa9YiUXjQFIETGCjd7Pr1DvWbIT8jBxV8rIrBvKE-X86nTfyoZ9vZ-GVd8Owy4RuA-xy1jLH-MihBjC3qjZhRMXl9e4QvDP_MouuFb6Ey9kyBLH4gENd9JETThw-0CLBtwL9f6aq5dwMuZ-FGhobrTwiMqBdnfZRnCjlUT7CTV-WnkWXCLsgVuwSiew28ypbEIVgUa7ngSLezg_lG8tUhIuwd0-i-ccTuvxVMhyXo7ed3rdQPFftQLx3reJzKeTosWKFITirQgk",
        "portfolio_url": "https://creatorbridge.com/alex-rivera",
        "subscription_tier": "pro",
        "pricing_per_post": 1200,
        "total_earnings": 15450.0,
        "rating": 4.9,
        "social_platforms": [
            {"platform": "instagram", "handle": "alex_rivera", "followers": 125000, "engagement_rate": 8.5},
            {"platform": "tiktok", "handle": "alex_rivera_vlogs", "followers": 240400, "engagement_rate": 12.2}
        ],
        "created_at": get_now()
    })

    # Demo Brand: Zenith Agency
    zenith_user = {
        "name": "Sarah Miller",
        "email": "sarah@zenith.com",
        "password_hash": password_hash,
        "role": "brand",
        "location": "New York, USA",
        "created_at": get_now(),
        "is_active": True
    }
    zenith_user_id = str(db.users.insert_one(zenith_user).inserted_id)
    
    db.brands.insert_one({
        "user_id": zenith_user_id,
        "company_name": "Zenith Agency",
        "industry": "Fashion & Lifestyle",
        "company_website": "https://zenith.com",
        "company_description": "Zenith is a premium lifestyle and fashion brand focused on sustainable and high-quality apparel. We collaborate with creators who share our vision of modern elegance and conscious living.",
        "verified": True,
        "location": "New York, USA",
        "created_at": get_now()
    })

    # 3. Seed Campaigns
    print("[*] Seeding campaigns...")
    campaigns = [
        {
            "brand_id": zenith_user_id,
            "title": "Luxury Villa Showcase 2026",
            "description": "Highlight the premium amenities and breathtaking views of the new Azure heights project in Dubai Marina.",
            "niche": "real_estate",
            "budget": 5000,
            "location": "Dubai, UAE",
            "required_followers": 50000,
            "deliverables": "3 Reels, 5 Stories, 1 Grid Post",
            "deadline": get_now() + timedelta(days=20),
            "status": "open",
            "applications_count": 12,
            "image_url": CAMPAIGN_IMAGES[0],
            "created_at": get_now()
        },
        {
            "brand_id": zenith_user_id,
            "title": "Sustainable Sneaker Launch",
            "description": "Create authentic unboxing and lifestyle content for our new recycled materials sneaker line.",
            "niche": "fashion",
            "budget": 3500,
            "location": "Global",
            "required_followers": 25000,
            "deliverables": "2 Reels, 1 YouTube Short",
            "deadline": get_now() + timedelta(days=15),
            "status": "open",
            "applications_count": 8,
            "image_url": CAMPAIGN_IMAGES[1],
            "created_at": get_now()
        },
        {
            "brand_id": zenith_user_id,
            "title": "NextGen Smartphone Review",
            "description": "Unboxing and feature walkthrough for the upcoming flagship device. Focus on camera quality.",
            "niche": "tech",
            "budget": 7500,
            "location": "USA / Europe",
            "required_followers": 100000,
            "deliverables": "1 Long-form Video, 3 Shorts",
            "deadline": get_now() + timedelta(days=10),
            "status": "open",
            "applications_count": 5,
            "image_url": CAMPAIGN_IMAGES[2],
            "created_at": get_now()
        }
    ]
    db.campaigns.insert_many(campaigns)

    # 4. Seed Messages
    print("[*] Seeding messages...")
    db.messages.insert_one({
        "from_id": zenith_user_id,
        "to_id": alex_id,
        "participants": [zenith_user_id, alex_id],
        "thread_id": f"{min(zenith_user_id, alex_id)}_{max(zenith_user_id, alex_id)}_general",
        "content": "Hi Alex! We loved your recent Dubai tour. Are you available for our Azure Heights campaign next month?",
        "timestamp": get_now() - timedelta(hours=2),
        "read": True,
        "read_by": [zenith_user_id, alex_id]
    })
    
    db.messages.insert_one({
        "from_id": alex_id,
        "to_id": zenith_user_id,
        "participants": [zenith_user_id, alex_id],
        "thread_id": f"{min(zenith_user_id, alex_id)}_{max(zenith_user_id, alex_id)}_general",
        "content": "The draft looks perfect! We're ready to proceed with the second phase of the campaign.",
        "timestamp": get_now() - timedelta(minutes=2),
        "read": False,
        "read_by": [alex_id]
    })

    # 5. Create Indexes
    print("[*] Ensuring indexes...")
    db.users.create_index("email", unique=True)
    db.creators.create_index("user_id", unique=True)
    db.brands.create_index("user_id", unique=True)
    db.campaigns.create_index("status")
    db.messages.create_index("participants")
    db.messages.create_index("thread_id")
    
    client.close()
    print("\n[SUCCESS] Production-ready data seeded successfully!")
    print("User: alex@creatorbridge.com / password123")
    print("User: sarah@zenith.com / password123")

if __name__ == "__main__":
    seed_data()
