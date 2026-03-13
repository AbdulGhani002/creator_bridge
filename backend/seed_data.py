"""
Seed script to populate MongoDB with demo data for CreatorBridge
Run: python seed_data.py
Uses synchronous pymongo instead of async motor for simplicity
"""

import pymongo
from pymongo import MongoClient
from datetime import datetime, timedelta
import os
from dotenv import load_dotenv

load_dotenv()

MONGODB_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "creator_bridge")

def seed_data():
    """Populate database with demo data"""
    
    # Connect to MongoDB
    try:
        client = MongoClient(MONGODB_URL, serverSelectionTimeoutMS=5000)
        # Check connection
        client.server_info()
        db = client[DATABASE_NAME]
        print("[OK] Connected to MongoDB")
    except Exception as e:
        print(f"[ERROR] Failed to connect to MongoDB: {e}")
        print("Make sure MongoDB is running on:", MONGODB_URL)
        return
    
    print("[*] Starting data seeding...")
    
    # Clear existing collections
    print("[*] Clearing existing data...")
    db.campaigns.delete_many({})
    db.creators.delete_many({})
    db.brands.delete_many({})
    db.messages.delete_many({})
    db.plans.delete_many({})
    
    # Seed Brands
    print("[*] Seeding brands...")
    brands_data = [
        {
            "user_id": "user_brand_1",
            "company_name": "DubaiLuxuryHomes",
            "industry": "Real Estate",
            "company_website": "https://dubailuxuryhomes.com",
            "company_description": "Curating the finest residential properties in the Middle East.",
            "verified": True,
            "followers": 45200,
            "location": "Dubai, UAE",
            # legacy fields for older clients
            "name": "DubaiLuxuryHomes",
            "category": "Real Estate",
            "description": "Curating the finest residential properties in the Middle East.",
            "avatar": "https://example.com/brand1.jpg",
            "created_at": datetime.utcnow(),
            "stats": {
                "properties": 120,
                "deals_closed": 310,
                "campaigns": 15
            }
        },
        {
            "user_id": "user_brand_2",
            "company_name": "Zenith",
            "industry": "Fashion & Lifestyle",
            "company_website": "https://zenith.com",
            "company_description": "Premium lifestyle and fashion brand.",
            "verified": True,
            "followers": 125000,
            "location": "New York, USA",
            "name": "Zenith",
            "category": "Fashion & Lifestyle",
            "description": "Premium lifestyle and fashion brand.",
            "avatar": "https://example.com/brand2.jpg",
            "created_at": datetime.utcnow(),
            "stats": {
                "properties": 0,
                "deals_closed": 250,
                "campaigns": 25
            }
        },
        {
            "user_id": "user_brand_3",
            "company_name": "TravelGo",
            "industry": "Travel & Tourism",
            "company_website": "https://travelgo.com",
            "company_description": "Discover the world with us.",
            "verified": False,
            "followers": 78900,
            "location": "Bangkok, Thailand",
            "name": "TravelGo",
            "category": "Travel & Tourism",
            "description": "Discover the world with us.",
            "avatar": "https://example.com/brand3.jpg",
            "created_at": datetime.utcnow(),
            "stats": {
                "properties": 0,
                "deals_closed": 180,
                "campaigns": 18
            }
        }
    ]
    
    result = db.brands.insert_many(brands_data)
    print(f"[OK] Seeded {len(brands_data)} brands")
    
    # Seed Creators
    print("[*] Seeding creators...")
    creators_data = [
        {
            "user_id": "user_creator_1",
            "name": "Alex Luxury",
            "bio": "Travel enthusiast, luxury lifestyle and real estate content creator.",
            "niche": "real_estate",
            "location": "Dubai, UAE",
            "followers_count": 85400,
            "verified": True,
            "profile_image_url": "https://example.com/creator1.jpg",
            "portfolio_url": "https://example.com/alex/portfolio",
            "subscription_tier": "pro",
            "pricing_per_post": 500,
            "total_earnings": 4250.0,
            "rating": 4.8,
            "social_platforms": [
                {
                    "platform": "instagram",
                    "handle": "alexluxury",
                    "followers": 85400,
                    "engagement_rate": 8.5
                }
            ],
            # legacy fields for older clients
            "specialization": "Real Estate & Luxury Lifestyle",
            "avatar": "https://example.com/creator1.jpg",
            "followers": 85400,
            "engagement_rate": 8.5,
            "monthly_reach": 250000,
            "email": "alex@example.com",
            "niches": ["Real Estate", "Luxury", "Travel", "Lifestyle"],
            "average_post_price": 500,
            "post_frequency": "3x per week",
            "min_followers": 50000,
            "avg_engagements": 7250,
            "status": "active",
            "created_at": datetime.utcnow(),
            "portfolio": [
                {
                    "title": "Zenith Summer Campaign",
                    "brand": "Zenith",
                    "views": 125000,
                    "engagements": 8500
                }
            ]
        },
        {
            "user_id": "user_creator_2",
            "name": "Jordan Smith",
            "bio": "Investment insights and property market analysis.",
            "niche": "finance",
            "location": "Dubai, UAE",
            "followers_count": 62300,
            "verified": True,
            "profile_image_url": "https://example.com/creator2.jpg",
            "portfolio_url": "https://example.com/jordan/portfolio",
            "subscription_tier": "pro",
            "pricing_per_post": 350,
            "total_earnings": 3100.0,
            "rating": 4.6,
            "social_platforms": [
                {
                    "platform": "instagram",
                    "handle": "jordansmith",
                    "followers": 62300,
                    "engagement_rate": 6.2
                }
            ],
            "specialization": "Property Investor",
            "avatar": "https://example.com/creator2.jpg",
            "followers": 62300,
            "engagement_rate": 6.2,
            "monthly_reach": 180000,
            "email": "jordan@example.com",
            "niches": ["Real Estate", "Investment", "Finance"],
            "average_post_price": 350,
            "post_frequency": "2x per week",
            "min_followers": 40000,
            "avg_engagements": 3860,
            "status": "active",
            "created_at": datetime.utcnow(),
            "portfolio": []
        },
        {
            "user_id": "user_creator_3",
            "name": "Maria Garcia",
            "bio": "Architectural designs and interior inspiration.",
            "niche": "lifestyle",
            "location": "Dubai, UAE",
            "followers_count": 44100,
            "verified": False,
            "profile_image_url": "https://example.com/creator3.jpg",
            "portfolio_url": "https://example.com/maria/portfolio",
            "subscription_tier": "free",
            "pricing_per_post": 400,
            "total_earnings": 1500.0,
            "rating": 4.4,
            "social_platforms": [
                {
                    "platform": "instagram",
                    "handle": "mariagarcia",
                    "followers": 44100,
                    "engagement_rate": 9.1
                }
            ],
            "specialization": "Architecture & Design",
            "avatar": "https://example.com/creator3.jpg",
            "followers": 44100,
            "engagement_rate": 9.1,
            "monthly_reach": 120000,
            "email": "maria@example.com",
            "niches": ["Architecture", "Design", "Lifestyle"],
            "average_post_price": 400,
            "post_frequency": "4x per week",
            "min_followers": 30000,
            "avg_engagements": 10920,
            "status": "active",
            "created_at": datetime.utcnow(),
            "portfolio": []
        }
    ]
    
    creators_result = db.creators.insert_many(creators_data)
    print(f"[OK] Seeded {len(creators_data)} creators")
    
    # Seed Campaigns
    print("[*] Seeding campaigns...")
    campaigns_data = [
        {
            "brand_id": str(result.inserted_ids[0]) if len(result.inserted_ids) > 0 else "brand_1",
            "title": "Luxury Villa Showcase 2024",
            "description": "Promote our new collection of luxury villas to high-net-worth individuals.",
            "niche": "real_estate",
            "budget": 5000,
            "location": "Dubai, UAE",
            "required_followers": 50000,
            "deliverables": "3 reels, 5 stories, 1 photo post",
            "deadline": datetime.utcnow() + timedelta(days=14),
            "status": "open",
            "applications_count": 3,
            "created_at": datetime.utcnow(),
            # legacy fields
            "requirements": "Dubai-based, Real Estate niche, 50k+ followers, high engagement",
            "budget_per_creator": 500,
            "num_creators": 10,
            "applications": 3,
            "accepted_creators": 2
        },
        {
            "brand_id": str(result.inserted_ids[1]) if len(result.inserted_ids) > 1 else "brand_2",
            "title": "Summer Fashion Campaign",
            "description": "Showcase our summer collection with authentic content.",
            "niche": "fashion",
            "budget": 8000,
            "location": "New York, USA",
            "required_followers": 50000,
            "deliverables": "5 posts, 3 reels",
            "deadline": datetime.utcnow() + timedelta(days=21),
            "status": "open",
            "applications_count": 8,
            "created_at": datetime.utcnow(),
            "requirements": "Fashion niche, 50k+ followers, aesthetic style",
            "budget_per_creator": 800,
            "num_creators": 10,
            "applications": 8,
            "accepted_creators": 5
        }
    ]
    
    campaigns_result = db.campaigns.insert_many(campaigns_data)
    print(f"[OK] Seeded {len(campaigns_data)} campaigns")
    
    # Seed Messages
    print("[*] Seeding messages...")
    messages_data = [
        {
            "from_id": "brand_2",
            "to_id": "creator_1",
            "campaign_id": "campaign_2",
            "content": "Hi Alex! We loved your recent content. Are you available for our Summer Campaign?",
            "timestamp": datetime.utcnow() - timedelta(hours=2),
            "read": True
        },
        {
            "from_id": "creator_1",
            "to_id": "brand_2",
            "campaign_id": "campaign_2",
            "content": "Absolutely! I'm very interested. Let's discuss the details.",
            "timestamp": datetime.utcnow() - timedelta(hours=1),
            "read": True
        }
    ]
    
    messages_result = db.messages.insert_many(messages_data)
    print(f"[OK] Seeded {len(messages_data)} messages")

    # Seed Plans
    print("[*] Seeding plans...")
    plans_data = [
        {
            "name": "Basic",
            "price": 0,
            "period": "mo",
            "description": "Perfect for hobbyists just starting out.",
            "features": ["Standard Profile Page", "Basic Analytics", "Search Visibility"],
            "highlighted": False,
            "created_at": datetime.utcnow()
        },
        {
            "name": "Pro",
            "price": 19,
            "period": "mo",
            "description": "Get discovered by brands and followers.",
            "features": ["Everything in Basic", "Appear in Search Results", "Advanced Audience Insights", "Custom Profile URL"],
            "highlighted": True,
            "created_at": datetime.utcnow()
        },
        {
            "name": "Premium",
            "price": 49,
            "period": "mo",
            "description": "Maximum exposure for top creators.",
            "features": ["Everything in Pro", "Featured Listing (Top 1%)", "Ad-free Profile for Fans", "Priority Support 24/7"],
            "highlighted": False,
            "created_at": datetime.utcnow()
        }
    ]
    plans_result = db.plans.insert_many(plans_data)
    print(f"[OK] Seeded {len(plans_data)} plans")
    
    # Create indexes
    print("[*] Creating indexes...")
    db.brands.create_index("name")
    db.brands.create_index("verified")
    db.creators.create_index("name")
    db.creators.create_index("verified")
    db.creators.create_index("niches")
    db.campaigns.create_index("brand_id")
    db.campaigns.create_index("status")
    db.campaigns.create_index("niche")
    db.messages.create_index("from_id")
    db.messages.create_index("to_id")
    db.plans.create_index("name")
    print("[OK] Indexes created")
    
    client.close()
    print("\n[SUCCESS] Data seeding completed successfully!")

if __name__ == "__main__":
    seed_data()

