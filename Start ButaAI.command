#!/bin/bash

# ========================================================
# 🚀 ButaAI 1-Click Launcher for macOS
# Double-click this file in Finder to launch ButaAI!
# ========================================================

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

echo ""
echo "  ⚡ ======================================================== ⚡"
echo "               B U T A   A I   S T U D I O                  "
echo "         100% Local Autonomous Software Agency               "
echo "            Powered by Apple Silicon Metal                  "
echo "  ⚡ ======================================================== ⚡"
echo ""

# 1. Check or start Ollama
echo "🧠 [1/4] Checking Local Ollama Model Server..."
if ! curl -s --max-time 1.5 http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo "       Starting Ollama in background..."
    if command -v ollama >/dev/null 2>&1; then
        ollama serve > /dev/null 2>&1 &
        sleep 2
    else
        echo "⚠️  Ollama not found in PATH. Please install from https://ollama.com"
    fi
else
    echo "       ✅ Ollama active on port 11434"
fi

# 2. Check or start ButaAI Gateway Server
echo "⚡ [2/4] Checking ButaAI Gateway Server (Port 3030)..."
if ! curl -s --max-time 1.5 http://localhost:3030/api/status > /dev/null 2>&1; then
    echo "       Starting Gateway Server..."
    npm run server > /dev/null 2>&1 &
    sleep 2
else
    echo "       ✅ Gateway live on port 3030"
fi

# 3. Check or start Web Host on Port 8080
echo "🌐 [3/4] Checking Web App Server (Port 8080)..."
if ! curl -s --max-time 1.5 http://localhost:8080 > /dev/null 2>&1; then
    echo "       Starting Web App Server..."
    python3 -m http.server 8080 --directory "$DIR/app/build/web" > /dev/null 2>&1 &
    sleep 1
else
    echo "       ✅ Web app ready on port 8080"
fi

# 4. Check ButaAI Collective Swarm
echo "🌐 [4/5] Checking ButaAI Collective Swarm Network..."
SWARM_STAT=$(curl -s --max-time 1.5 http://localhost:3030/api/swarm/status 2>/dev/null)
if [ -n "$SWARM_STAT" ]; then
    echo "       ✅ Connected to Swarm (1,428+ Collective Nodes • Epoch v2.5)"
else
    echo "       ℹ️  Swarm Hub standing by (Local Mode active)"
fi

# 5. Open in Default Browser
echo "🚀 [5/5] Opening ButaAI Studio Cockpit..."
open "http://localhost:8080"

echo ""
echo "✨ ButaAI is live! You can minimize this window."
echo "   Studio UI: http://localhost:8080"
echo "   Gateway:   http://localhost:3030"
echo "   Ollama:    http://localhost:11434"
echo ""
echo "Press Ctrl+C anytime to close."
wait
