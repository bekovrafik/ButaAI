#!/usr/bin/env bash
# ==============================================================================
# ButaAI - 1-Click Autonomous Engineering Studio Installer
# 100% On-Device • Apple Silicon Metal Accelerated • Zero Cloud Dependency
# ==============================================================================

set -e

echo ""
echo "=================================================================="
echo "  🚀 Installing ButaAI: Autonomous On-Device Engineering Studio  "
echo "  Apple Silicon Metal GPU • 6 Autonomous Specialists • Swarm LoRA "
echo "=================================================================="
echo ""

# Check OS
OS="$(uname -s)"
if [ "$OS" != "Darwin" ]; then
  echo "⚠️ Warning: ButaAI Metal GPU acceleration is calibrated for macOS Apple Silicon."
  echo "Proceeding with universal CPU/CUDA fallback..."
fi

# Check Node.js
if ! command -v node >/dev/null 2>&1; then
  echo "❌ Node.js is required (v18+). Please install Node.js from https://nodejs.org or via brew install node"
  exit 1
fi
echo "✅ Node.js $(node -v) detected"

# Check Flutter (Optional for Cockpit UI)
if command -v flutter >/dev/null 2>&1; then
  echo "✅ Flutter $(flutter --version | head -n 1) detected"
else
  echo "ℹ️ Flutter not in PATH. Cockpit can run via web browser or prebuilt binary."
fi

# Check Ollama
if command -v ollama >/dev/null 2>&1; then
  echo "✅ Ollama detected"
  # Check if model exists, if not pull base coder
  if ! ollama list | grep -q "buta-ai"; then
    echo "📦 Initializing local base model (qwen2.5-coder:7b)..."
    ollama pull qwen2.5-coder:7b || true
  fi
else
  echo "⚠️ Ollama not detected. We recommend installing Ollama from https://ollama.ai for local GPU inference."
fi

# Install dependencies
echo "📦 Installing Gateway & Engine dependencies..."
npm install

echo "🔨 Building TypeScript Gateway..."
npm run build

echo ""
echo "=================================================================="
echo "  🎉 ButaAI successfully installed and configured!              "
echo "=================================================================="
echo ""
echo "To start the Cockpit Studio, run:"
echo "   ./Start\ ButaAI.command"
echo "Or start the local Gateway server manually:"
echo "   npm run server"
echo ""
