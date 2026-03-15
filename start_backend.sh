#!/bin/bash
echo "Starting CreatorBridge Backend Environment..."
cd backend
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi
source venv/bin/activate
echo "Installing requirements..."
pip install -r requirements.txt
echo "Starting server..."
uvicorn main:app --reload --port 8000
