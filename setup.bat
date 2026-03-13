@echo off
REM Creator Bridge Setup Script for Windows
REM This script sets up the entire project for development

setlocal enabledelayedexpansion

echo.
echo 🚀 Creator Bridge - Setup Script (Windows)
echo ==========================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python not found. Please install Python 3.10+
    exit /b 1
)

echo ✓ Python found
echo.

REM Setup Backend
echo 📦 Setting up Backend...

cd backend

REM Check if venv exists
if not exist "venv" (
    echo   Creating Python virtual environment...
    python -m venv venv
)

REM Activate venv
call venv\Scripts\activate.bat

REM Install dependencies
echo   Installing Python dependencies...
pip install -q -r requirements.txt

REM Create .env if not exists
if not exist ".env" (
    echo   Creating .env file...
    copy .env.example .env
    echo   ⚠️  Remember to update .env with your MongoDB URL
)

echo ✓ Backend setup complete
echo.

cd ..

REM Setup Frontend
echo 📱 Frontend files ready
echo ✓ Copy to your Xcode project:
echo   - Models.swift
echo   - APIService.swift
echo   - ViewModels.swift
echo   - CampaignViews.swift
echo   - CreatorViews.swift
echo.

REM Summary
echo ==========================================
echo ✅ Setup Complete!
echo ==========================================
echo.

echo Next steps:
echo.
echo 1. Backend:
echo    cd backend
echo    venv\Scripts\activate.bat
echo    python main.py
echo.
echo 2. Make sure MongoDB is running:
echo    mongod
echo.
echo 3. Frontend:
echo    Copy Swift files to your Xcode project
echo.
echo 📖 Read QUICKSTART.md for more details!
echo.

pause
