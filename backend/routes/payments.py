import os
import stripe
from fastapi import APIRouter, HTTPException, Depends, Request
from pydantic import BaseModel
from typing import Optional
from database import get_database
from security import get_current_user
from motor.motor_asyncio import AsyncIOMotorDatabase

router = APIRouter(prefix="/payments", tags=["payments"])

# Load Stripe API key from environment
stripe.api_key = os.getenv("STRIPE_SECRET_KEY", "sk_test_51P...") # Use test key by default

class CreatePaymentIntentRequest(BaseModel):
    amount: int  # in cents
    currency: str = "usd"
    plan_id: Optional[str] = None

class PaymentIntentResponse(BaseModel):
    client_secret: str
    publishable_key: str

@router.post("/create-payment-intent", response_model=PaymentIntentResponse)
async def create_payment_intent(
    payload: CreatePaymentIntentRequest,
    current_user: dict = Depends(get_current_user)
):
    try:
        # Create a PaymentIntent with the order amount and currency
        intent = stripe.PaymentIntent.create(
            amount=payload.amount,
            currency=payload.currency,
            automatic_payment_methods={
                'enabled': True,
            },
            metadata={
                "user_id": current_user.get("id"),
                "plan_id": payload.plan_id or "unknown"
            }
        )
        
        return {
            "client_secret": intent.client_secret,
            "publishable_key": os.getenv("STRIPE_PUBLISHABLE_KEY", "pk_test_51P...")
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.post("/webhook")
async def stripe_webhook(request: Request, db: AsyncIOMotorDatabase = Depends(get_database)):
    payload = await request.body()
    sig_header = request.headers.get("stripe-signature")
    endpoint_secret = os.getenv("STRIPE_WEBHOOK_SECRET")

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, endpoint_secret
        )
    except ValueError as e:
        # Invalid payload
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.error.SignatureVerificationError as e:
        # Invalid signature
        raise HTTPException(status_code=400, detail="Invalid signature")

    # Handle the event
    if event['type'] == 'payment_intent.succeeded':
        payment_intent = event['data']['object']
        user_id = payment_intent['metadata'].get('user_id')
        plan_id = payment_intent['metadata'].get('plan_id')
        
        if user_id:
            # Update user subscription in database
            await db.users.update_one(
                {"_id": user_id}, # Note: in real app, might need ObjectId conversion
                {"$set": {"subscription_tier": plan_id or "pro", "is_premium": True}}
            )
            print(f"💰 Payment succeeded for user {user_id}")

    return {"status": "success"}
