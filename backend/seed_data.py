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
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80",
    "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?auto=format&fit=crop&w=400&q=80",
    "https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=400&q=80"
]

BRAND_IMAGES = [
    "https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=400&q=80", # Watch
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=400&q=80", # Shoe
    "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=400&q=80", # Headphones
    "https://images.unsplash.com/photo-1491553895911-0055eca6402d?auto=format&fit=crop&w=400&q=80", # Sports
    "https://images.unsplash.com/photo-1526170315830-ef18a25d48a6?auto=format&fit=crop&w=400&q=80" # Camera
]

CAMPAIGN_IMAGES = [
    "https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=800&q=80", # Villa
    "https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?auto=format&fit=crop&w=800&q=80", # Fashion
    "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80", # Tech
    "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80", # Travel
    "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80"  # Fitness
]

def get_now():
    return datetime.now(timezone.utc)

def hash_password(password: str) -> str:
    pwd_bytes = password.encode('utf-8')[:72]
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')

def seed_data():
    """Populate database with realistic production-ready data"""
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
    
    # Drop collections
    collections = ["users", "campaigns", "creators", "brands", "messages", "plans", "applications", "agreements", "subscriptions", "analytics"]
    for coll in collections:
        db[coll].drop()
    print("[*] Dropped existing collections")

    # 1. Seed Subscription Plans
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
    
    # --- CREATORS ---
    creators_list = [
        {
            "name": "Alex Rivera",
            "email": "alex@creatorbridge.com",
            "bio": "Travel enthusiast, luxury lifestyle and real estate content creator based in Dubai.",
            "niche": "real_estate",
            "location": "Dubai, UAE",
            "followers": 365400,
            "image": CREATOR_IMAGES[0],
            "price": 1200,
            "earnings": 15450,
            "rating": 4.9
        },
        {
            "name": "Sarah Chen",
            "email": "sarah.c@creators.net",
            "bio": "Tech reviewer and gadget enthusiast. I break down complex tech into simple lifestyle benefits.",
            "niche": "tech",
            "location": "San Francisco, USA",
            "followers": 850000,
            "image": CREATOR_IMAGES[2],
            "price": 2500,
            "earnings": 42000,
            "rating": 5.0
        },
        {
            "name": "Marcus Thorne",
            "email": "marcus.fitness@gmail.com",
            "bio": "Certified personal trainer and nutrition coach. Helping you build a sustainable healthy lifestyle.",
            "niche": "fitness",
            "location": "London, UK",
            "followers": 120000,
            "image": CREATOR_IMAGES[1],
            "price": 800,
            "earnings": 8900,
            "rating": 4.7
        },
        {
            "name": "Elena Rossi",
            "email": "elena.style@outlook.com",
            "bio": "High fashion and sustainable living. Bridging the gap between luxury and conscious consumption.",
            "niche": "fashion",
            "location": "Milan, Italy",
            "followers": 540000,
            "image": CREATOR_IMAGES[4],
            "price": 1800,
            "earnings": 28500,
            "rating": 4.8
        },
        {
            "name": "David Park",
            "email": "david.vlogs@youtube.com",
            "bio": "Daily vlogger exploring hidden gems in Asian cities. Focus on food and local culture.",
            "niche": "travel",
            "location": "Seoul, South Korea",
            "followers": 2100000,
            "image": CREATOR_IMAGES[3],
            "price": 5000,
            "earnings": 120000,
            "rating": 4.9
        }
    ]

    creator_ids = []
    for c in creators_list:
        u_id = str(db.users.insert_one({
            "name": c["name"],
            "email": c["email"],
            "password_hash": password_hash,
            "role": "creator",
            "location": c["location"],
            "created_at": get_now(),
            "is_active": True
        }).inserted_id)
        
        db.creators.insert_one({
            "user_id": u_id,
            "name": c["name"],
            "bio": c["bio"],
            "niche": c["niche"],
            "location": c["location"],
            "followers_count": c["followers"],
            "verified": True,
            "profile_image_url": c["image"],
            "subscription_tier": "pro" if c["followers"] < 1000000 else "premium",
            "pricing_per_post": c["price"],
            "total_earnings": c["earnings"],
            "rating": c["rating"],
            "social_platforms": [
                {"platform": "instagram", "handle": c["name"].lower().replace(" ", "_"), "followers": c["followers"] // 2},
                {"platform": "tiktok", "handle": c["name"].lower().replace(" ", ""), "followers": c["followers"] // 2}
            ],
            "created_at": get_now()
        })
        creator_ids.append(u_id)

    # --- BRANDS ---
    brands_list = [
        {
            "name": "Sarah Miller",
            "email": "sarah@zenith.com",
            "company": "Zenith Agency",
            "industry": "Fashion & Lifestyle",
            "desc": "Premium lifestyle and fashion brand focused on sustainable and high-quality apparel."
        },
        {
            "name": "Tom Baker",
            "email": "tom@lumina.tech",
            "company": "Lumina Tech",
            "industry": "Consumer Electronics",
            "desc": "Innovative home automation and personal tech products for the modern professional."
        },
        {
            "name": "Jessica Low",
            "email": "jessica@fitfuel.com",
            "company": "FitFuel Nutrition",
            "industry": "Health & Wellness",
            "desc": "Science-backed supplements and organic nutrition for athletes and active individuals."
        }
    ]

    brand_ids = []
    for b in brands_list:
        u_id = str(db.users.insert_one({
            "name": b["name"],
            "email": b["email"],
            "password_hash": password_hash,
            "role": "brand",
            "location": "Various",
            "created_at": get_now(),
            "is_active": True
        }).inserted_id)
        
        db.brands.insert_one({
            "user_id": u_id,
            "company_name": b["company"],
            "industry": b["industry"],
            "company_website": f"https://{b['company'].lower().replace(' ', '')}.com",
            "company_description": b["desc"],
            "verified": True,
            "location": "Global",
            "created_at": get_now()
        })
        brand_ids.append(u_id)

    # 3. Seed Campaigns
    print("[*] Seeding campaigns...")
    campaigns_data = [
        {
            "brand_id": brand_ids[0],
            "title": "Luxury Villa Showcase 2026",
            "description": "Highlight the premium amenities of the new Azure heights project in Dubai Marina.",
            "niche": "real_estate",
            "budget": 5000,
            "image": CAMPAIGN_IMAGES[0]
        },
        {
            "brand_id": brand_ids[0],
            "title": "Sustainable Sneaker Launch",
            "description": "Create authentic unboxing and lifestyle content for our new recycled materials sneaker line.",
            "niche": "fashion",
            "budget": 3500,
            "image": CAMPAIGN_IMAGES[1]
        },
        {
            "brand_id": brand_ids[1],
            "title": "NextGen Smartphone Review",
            "description": "Unboxing and feature walkthrough for the upcoming flagship device. Focus on camera quality.",
            "niche": "tech",
            "budget": 7500,
            "image": CAMPAIGN_IMAGES[2]
        },
        {
            "brand_id": brand_ids[1],
            "title": "Smart Home Integration Series",
            "description": "Showcase how Lumina products make daily life easier and more connected.",
            "niche": "tech",
            "budget": 4200,
            "image": CAMPAIGN_IMAGES[2]
        },
        {
            "brand_id": brand_ids[2],
            "title": "Summer Fitness Challenge",
            "description": "Join our 30-day transformation challenge and promote our new electrolyte range.",
            "niche": "fitness",
            "budget": 2800,
            "image": CAMPAIGN_IMAGES[4]
        },
        {
            "brand_id": brand_ids[2],
            "title": "Hidden Gems Travel Vlog",
            "description": "We are looking for travel creators to visit our retreat centers in Bali and Costa Rica.",
            "niche": "travel",
            "budget": 6000,
            "image": CAMPAIGN_IMAGES[3]
        }
    ]
    
    for c in campaigns_data:
        db.campaigns.insert_one({
            "brand_id": c["brand_id"],
            "title": c["title"],
            "description": c["description"],
            "niche": c["niche"],
            "budget": c["budget"],
            "location": "Global",
            "required_followers": 25000,
            "deliverables": "Reels, Stories, and Grid Posts",
            "deadline": get_now() + timedelta(days=30),
            "status": "open",
            "applications_count": random.randint(3, 15),
            "image_url": c["image"],
            "created_at": get_now()
        })

    # 4. Seed Messages
    print("[*] Seeding messages...")
    db.messages.insert_one({
        "from_id": brand_ids[0],
        "to_id": creator_ids[0],
        "participants": [brand_ids[0], creator_ids[0]],
        "thread_id": f"{min(brand_ids[0], creator_ids[0])}_{max(brand_ids[0], creator_ids[0])}_general",
        "content": "Hi Alex! We loved your recent Dubai tour. Are you available for our Azure Heights campaign next month?",
        "timestamp": get_now() - timedelta(hours=2),
        "read": True,
        "read_by": [brand_ids[0], creator_ids[0]]
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
    print("\n[SUCCESS] Realistic production-ready data seeded successfully!")
    print(f"Total Creators: {len(creator_ids)}")
    print(f"Total Brands: {len(brand_ids)}")
    print(f"Total Campaigns: {len(campaigns_data)}")
    print("\nPrimary Admin Login: alex@creatorbridge.com / password123")

if __name__ == "__main__":
    seed_data()
