"""
Modular project structure for Creator Bridge Backend
Routes are organized by feature domain
"""

# backend/
# ├── main.py                    # Application entry point
# ├── config.py                  # Configuration management
# ├── database.py                # Database connection
# ├── models.py                  # Pydantic data models
# │
# ├── routes/                    # API route modules
# │   ├── __init__.py
# │   ├── campaigns.py           # Campaign endpoints
# │   ├── creators.py            # Creator endpoints
# │   ├── brands.py              # Brand endpoints
# │   ├── messages.py            # Messaging endpoints
# │   ├── applications.py        # Application endpoints
# │   ├── auth.py                # Authentication endpoints
# │   ├── payments.py            # Payment endpoints
# │   └── analytics.py           # Analytics endpoints
# │
# ├── services/                  # Business logic
# │   ├── __init__.py
# │   ├── campaign_service.py    # Campaign business logic
# │   ├── creator_service.py     # Creator business logic
# │   ├── email_service.py       # Email notifications
# │   ├── payment_service.py     # Payment processing
# │   └── analytics_service.py   # Analytics tracking
# │
# ├── middleware/                # Custom middleware
# │   ├── __init__.py
# │   ├── auth.py                # JWT authentication
# │   ├── rate_limit.py          # Rate limiting
# │   ├── logging.py             # Request logging
# │   └── error_handler.py       # Error handling
# │
# ├── schemas/                   # Pydantic schemas
# │   ├── __init__.py
# │   ├── campaign_schema.py
# │   ├── creator_schema.py
# │   ├── user_schema.py
# │   └── message_schema.py
# │
# ├── utils/                     # Utility functions
# │   ├── __init__.py
# │   ├── validators.py          # Input validation
# │   ├── formatters.py          # Data formatting
# │   ├── constants.py           # App constants
# │   └── helpers.py             # Helper functions
# │
# ├── requirements.txt           # Dependencies
# └── .env.example               # Config template

print("Backend modular structure ready")
