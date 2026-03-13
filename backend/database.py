"""
MongoDB database configuration and utilities
"""
import os
from motor.motor_asyncio import AsyncClient, AsyncDatabase
from contextlib import asynccontextmanager
from typing import Optional


class Database:
    """MongoDB database connection manager"""
    
    client: Optional[AsyncClient] = None
    db: Optional[AsyncDatabase] = None

    @classmethod
    async def connect_db(cls):
        """Initialize MongoDB connection"""
        MONGO_URL = os.getenv(
            "MONGO_URL",
            "mongodb://localhost:27017"
        )
        DATABASE_NAME = os.getenv("DATABASE_NAME", "creator_bridge")
        
        cls.client = AsyncClient(MONGO_URL)
        cls.db = cls.client[DATABASE_NAME]
        
        # Create indexes
        await cls._create_indexes()
        print("✓ Connected to MongoDB")

    @classmethod
    async def close_db(cls):
        """Close MongoDB connection"""
        if cls.client:
            cls.client.close()
            print("✓ Disconnected from MongoDB")

    @classmethod
    async def _create_indexes(cls):
        """Create database indexes for better query performance"""
        
        # Users indexes
        await cls.db["users"].create_index("email", unique=True)
        await cls.db["users"].create_index("role")
        await cls.db["users"].create_index("location")
        
        # Creators indexes
        await cls.db["creators"].create_index("user_id", unique=True)
        await cls.db["creators"].create_index("niche")
        await cls.db["creators"].create_index("subscription_tier")
        await cls.db["creators"].create_index(
            [("niche", 1), ("subscription_tier", 1)]
        )
        
        # Brands indexes
        await cls.db["brands"].create_index("user_id", unique=True)
        await cls.db["brands"].create_index("verified")
        
        # Campaigns indexes
        await cls.db["campaigns"].create_index("brand_id")
        await cls.db["campaigns"].create_index("niche")
        await cls.db["campaigns"].create_index("location")
        await cls.db["campaigns"].create_index("status")
        await cls.db["campaigns"].create_index(
            [("niche", 1), ("location", 1), ("status", 1)]
        )
        await cls.db["campaigns"].create_index("deadline")
        
        # Applications indexes
        await cls.db["applications"].create_index("campaign_id")
        await cls.db["applications"].create_index("creator_id")
        await cls.db["applications"].create_index("status")
        await cls.db["applications"].create_index(
            [("campaign_id", 1), ("creator_id", 1)],
            unique=True
        )
        
        print("✓ Database indexes created")

    @classmethod
    def get_db(cls) -> AsyncDatabase:
        """Get database instance"""
        if cls.db is None:
            raise RuntimeError("Database not initialized. Call connect_db() first.")
        return cls.db


# Dependency for getting database
async def get_database() -> AsyncDatabase:
    """FastAPI dependency to get database"""
    return Database.get_db()
