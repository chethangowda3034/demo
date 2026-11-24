@echo off
cd /d "%~dp0"
title MARPOL-SAFE Shipping Demo
if not exist ".venv\Scripts\python.exe" (
    echo Project environment not found. Follow the setup steps in README.md first.
    pause
    exit /b 1
)
set "APP_ENV=demo"
set "ENABLE_DEMO_ACCOUNTS=true"
".venv\Scripts\python.exe" -m streamlit run app.py --server.address 127.0.0.1
pause
