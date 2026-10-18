@echo off
title ButaAI Cockpit & Swarm Engine
echo Starting ButaAI Local Gateway on http://localhost:3030...
start /min cmd /c npm run server
timeout /t 2 /nobreak >nul

echo Starting ButaAI Cockpit Web on http://localhost:8080...
start /min cmd /c python -m http.server 8080 --directory app\build\web
timeout /t 1 /nobreak >nul

echo Opening ButaAI Cockpit in default browser...
start http://localhost:8080

echo ButaAI is running! Keep this window open or minimize it.
echo Press any key to stop all services...
pause >nul
taskkill /F /IM node.exe >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq ButaAI*" >nul 2>&1
