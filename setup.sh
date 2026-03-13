#!/bin/bash
# Creator Bridge Setup Script
# This script sets up the entire project for development

set -e

echo "🚀 Creator Bridge - Setup Script"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.10+"
    exit 1
fi

if ! command -v mongod &> /dev/null; then
    echo "⚠️  MongoDB not found in PATH"
    echo "   Make sure MongoDB is installed and running on localhost:27017"
fi

echo -e "${GREEN}✓ Prerequisites checked${NC}\n"

# Setup Backend
echo -e "${BLUE}Setting up Backend...${NC}"

cd backend

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "  Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate venv
source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null || true

# Install dependencies
echo "  Installing Python dependencies..."
pip install -q -r requirements.txt

# Create .env if not exists
if [ ! -f ".env" ]; then
    echo "  Creating .env file..."
    cp .env.example .env
    echo "  ⚠️  Remember to update .env with your MongoDB URL"
fi

echo -e "${GREEN}✓ Backend setup complete${NC}\n"

cd ..

# Setup Frontend
echo -e "${BLUE}Setting up Frontend...${NC}"
echo -e "${GREEN}✓ Frontend files ready (copy to Xcode project)${NC}\n"

# Summary
echo -e "${GREEN}=================================="
echo "✅ Setup Complete!"
echo "=================================${NC}\n"

echo "Next steps:"
echo "1. Backend:"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   python main.py"
echo ""
echo "2. Make sure MongoDB is running:"
echo "   mongod"
echo ""
echo "3. Frontend:"
echo "   Copy these files to your Xcode project:"
echo "   - Models.swift"
echo "   - APIService.swift"
echo "   - ViewModels.swift"
echo "   - CampaignViews.swift"
echo "   - CreatorViews.swift"
echo ""
echo "📖 Read QUICKSTART.md for more details!"
