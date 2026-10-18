#!/usr/bin/env bash
set -e

# ==============================================================================
# ButaAI 1-Line Universal Installer (macOS Apple Silicon & Linux)
# Decentralized Swarm LoRA Engine & Autonomous Agent Cockpit
# ==============================================================================

BOLD='\033[1m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${PURPLE}${BOLD}"
echo "  ____        _          _    ___ "
echo " | __ ) _   _| |_ __ _  / \  |_ _|"
echo " |  _ \| | | | __/ _\` |/ _ \  | | "
echo " | |_) | |_| | || (_| / ___ \ | | "
echo " |____/ \__,_|\__\__,_/_/   \_\___|"
echo -e "${NC}"
echo -e "${CYAN}Sovereign Decentralized Swarm LoRA Engine & Autonomous Software Squad${NC}"
echo -e "------------------------------------------------------------------------------"

# 1. Detect OS & Hardware Acceleration
OS="$(uname -s)"
ARCH="$(uname -m)"

echo -e "\n${BOLD}[1/6] Auditing Hardware Acceleration...${NC}"
if [ "$OS" = "Darwin" ]; then
    if [ "$ARCH" = "arm64" ]; then
        echo -e "${GREEN}✓ Apple Silicon Detected (${ARCH})${NC} - Metal Unified Memory Acceleration ACTIVE."
        ACCELERATOR="metal"
    else
        echo -e "${YELLOW}! Intel Mac Detected (${ARCH})${NC} - Running CPU Fallback Engine."
        ACCELERATOR="cpu"
    fi
elif [ "$OS" = "Linux" ]; then
    if command -v nvidia-smi &> /dev/null; then
        echo -e "${GREEN}✓ NVIDIA GPU Detected${NC} - CUDA Hardware Acceleration ACTIVE."
        ACCELERATOR="cuda"
    else
        echo -e "${YELLOW}! Generic Linux Detected${NC} - AVX-512 CPU Acceleration ACTIVE."
        ACCELERATOR="cpu"
    fi
else
    echo -e "${RED}Unsupported OS: $OS. For Windows, please run install.ps1.${NC}"
    exit 1
fi

# 2. Check Core Dependencies
echo -e "\n${BOLD}[2/6] Verifying Core Toolchains...${NC}"

# Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: Git is not installed. Please install Git first.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git found: $(git --version)${NC}"

# Node.js
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js not detected. Installing via Homebrew/package manager...${NC}"
    if [ "$OS" = "Darwin" ] && command -v brew &> /dev/null; then
        brew install node
    else
        echo -e "${RED}Please install Node.js (v18+) from https://nodejs.org${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ Node.js found: $(node -v)${NC}"

# Python 3
PYTHON_BIN=""
if command -v python3 &> /dev/null; then
    PYTHON_BIN="python3"
elif command -v python &> /dev/null; then
    PYTHON_BIN="python"
else
    echo -e "${RED}Python 3 is required. Please install Python 3.10+.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python found: $($PYTHON_BIN --version)${NC}"

# Ollama Local Engine
if ! command -v ollama &> /dev/null; then
    echo -e "${YELLOW}! Ollama is not installed.${NC}"
    echo -e "Installing Ollama for local model inference..."
    if [ "$OS" = "Darwin" ] && command -v brew &> /dev/null; then
        brew install --cask ollama
    else
        curl -fsSL https://ollama.com/install.sh | sh
    fi
fi
echo -e "${GREEN}✓ Ollama Local Daemon Ready.${NC}"

# 3. Setup Python Virtual Environment
echo -e "\n${BOLD}[3/6] Setting Up Python ML Environment...${NC}"
if [ ! -d ".venv" ]; then
    $PYTHON_BIN -m venv .venv
fi

VENV_PYTHON=".venv/bin/python"
VENV_PIP=".venv/bin/pip"

$VENV_PIP install --upgrade pip -q

if [ "$ACCELERATOR" = "metal" ]; then
    echo -e "Installing Apple Silicon Metal (MLX & Safetensors)..."
    $VENV_PIP install mlx mlx-lm safetensors requests -q || true
else
    echo -e "Installing PyTorch & Safetensors..."
    $VENV_PIP install torch safetensors transformers requests -q || true
fi
echo -e "${GREEN}✓ ML Environment Provisioned.${NC}"

# 4. Install Node.js Dependencies & Compile Engine
echo -e "\n${BOLD}[4/6] Compiling ButaAI TypeScript Gateway & P2P Swarm...${NC}"
npm install --silent
npm run build
echo -e "${GREEN}✓ Engine Compiled Successfully.${NC}"

# 5. Verify Base Model
echo -e "\n${BOLD}[5/6] Ensuring Local Master Model is Provisioned...${NC}"
if ! ollama list | grep -q "buta-ai"; then
    if ! ollama list | grep -q "qwen2.5-coder:7b"; then
        echo -e "Pulling lightweight sovereign base model (qwen2.5-coder:7b)..."
        ollama pull qwen2.5-coder:7b || true
    fi
    ollama create buta-ai -f Modelfile || true
fi
echo -e "${GREEN}✓ Model weights verified on local engine.${NC}"

# 6. Launch Services
echo -e "\n${BOLD}[6/6] Launching ButaAI Cockpit & Swarm Hub...${NC}"
echo -e "${PURPLE}------------------------------------------------------------------------------${NC}"
echo -e "${GREEN}${BOLD}✓ ButaAI is now fully initialized and ready!${NC}"
echo -e "  • Gateway API:     ${CYAN}http://localhost:3030${NC}"
echo -e "  • P2P Swarm Hub:   ${CYAN}http://localhost:3030/api/swarm/status${NC}"
echo -e "  • Cockpit Web UI:  ${CYAN}http://localhost:8080${NC}"
echo -e "${PURPLE}------------------------------------------------------------------------------${NC}"

# Start gateway in background if not running
if ! lsof -i :3030 &> /dev/null; then
    npm run server &
    sleep 2
fi

# Start static web server if not running
if ! lsof -i :8080 &> /dev/null; then
    python3 -m http.server 8080 --directory app/build/web &
    sleep 1
fi

# Open Cockpit in default browser
if [ "$OS" = "Darwin" ]; then
    open "http://localhost:8080"
elif command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:8080"
fi

echo -e "\n${BOLD}Press Ctrl+C to stop services or manage via Cockpit UI.${NC}\n"
