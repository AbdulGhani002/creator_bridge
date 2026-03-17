import os
from datetime import datetime, timedelta, timezone
from typing import Optional, Dict, Any
import bcrypt

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from motor.motor_asyncio import AsyncIOMotorDatabase
from bson import ObjectId

from database import get_database

# We use the bcrypt library directly for maximum compatibility and to avoid Passlib's 72-byte check crash
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def hash_password(password: str) -> str:
    # Truncate to 72 bytes as per bcrypt specification
    pwd_bytes = password.encode('utf-8')[:72]
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(
            plain_password.encode('utf-8')[:72],
            hashed_password.encode('utf-8')
        )
    except Exception:
        return False


def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (expires_delta or timedelta(minutes=1440))
    to_encode.update({"exp": expire})
    secret_key = os.getenv("SECRET_KEY", "change-me")
    algorithm = os.getenv("ALGORITHM", "HS256")
    return jwt.encode(to_encode, secret_key, algorithm=algorithm)



async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncIOMotorDatabase = Depends(get_database)
) -> dict:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid authentication credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        secret_key = os.getenv("SECRET_KEY", "change-me")
        algorithm = os.getenv("ALGORITHM", "HS256")
        payload = jwt.decode(token, secret_key, algorithms=[algorithm])
        user_id: Optional[str] = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    try:
        user = await db.users.find_one({"_id": ObjectId(user_id), "is_active": True})
    except Exception:
        raise credentials_exception

    if not user:
        raise credentials_exception

    user["_id"] = str(user.get("_id"))
    user["id"] = user["_id"]
    return user

