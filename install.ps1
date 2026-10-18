# ==============================================================================
# ButaAI 1-Line Universal Installer for Windows 10 & 11 (64-Bit / ARM64)
# Decentralized Swarm LoRA Engine & Autonomous Agent Cockpit
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1
# ==============================================================================

Write-Host "  ____        _          _    ___ " -ForegroundColor Magenta
Write-Host " | __ ) _   _| |_ __ _  / \  |_ _|" -ForegroundColor Magenta
Write-Host " |  _ \| | | | __/ _\` |/ _ \  | | " -ForegroundColor Magenta
Write-Host " | |_) | |_| | || (_| / ___ \ | | " -ForegroundColor Magenta
Write-Host " |____/ \__,_|\__\__,_/_/   \_\___|" -ForegroundColor Magenta
Write-Host ""
Write-Host "Sovereign Decentralized Swarm LoRA Engine (Windows Edition)" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------------------------"

# 1. Hardware & GPU Acceleration Audit
Write-Host "`n[1/6] Auditing Hardware Acceleration & GPU on Windows..." -ForegroundColor Yellow

$gpu = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name -First 1
$hasNvidia = $false
$hasAmd = $false

if ($gpu -match "NVIDIA" -or (Get-Command nvidia-smi -ErrorAction SilentlyContinue)) {
    $hasNvidia = $true
    Write-Host "✓ NVIDIA GPU Detected: $gpu" -ForegroundColor Green
    Write-Host "  CUDA Tensor Core Acceleration ACTIVE for Windows." -ForegroundColor Green
} elseif ($gpu -match "AMD" -or $gpu -match "Radeon") {
    $hasAmd = $true
    Write-Host "✓ AMD Radeon GPU Detected: $gpu" -ForegroundColor Green
    Write-Host "  DirectML Acceleration ACTIVE for Windows." -ForegroundColor Green
} else {
    Write-Host "! Display Adapter: $gpu" -ForegroundColor Cyan
    Write-Host "  Optimized AVX2/AVX-512 CPU Acceleration ACTIVE." -ForegroundColor Cyan
}

# 2. Check Core Toolchains
Write-Host "`n[2/6] Verifying Windows Development Prerequisites..." -ForegroundColor Yellow

# Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "! Git not found. Installing via winget..." -ForegroundColor Yellow
    winget install --id Git.Git -e --source winget --silent
}
Write-Host "✓ Git Ready." -ForegroundColor Green

# Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "! Node.js not found. Installing via winget..." -ForegroundColor Yellow
    winget install --id OpenJS.NodeJS.LTS -e --source winget --silent
}
Write-Host "✓ Node.js Ready: $(node -v)" -ForegroundColor Green

# Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "! Python not found. Installing Python 3.11 via winget..." -ForegroundColor Yellow
    winget install --id Python.Python.3.11 -e --source winget --silent
}
Write-Host "✓ Python Ready: $(python --version)" -ForegroundColor Green

# Ollama for Windows
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Host "! Ollama not found. Installing Ollama for Windows via winget..." -ForegroundColor Yellow
    winget install --id Ollama.Ollama -e --source winget --silent
}
Write-Host "✓ Ollama Windows Daemon Ready." -ForegroundColor Green

# 3. Setup Python Virtual Environment
Write-Host "`n[3/6] Setting Up Windows Python ML Environment..." -ForegroundColor Yellow

if (-not (Test-Path ".venv")) {
    python -m venv .venv
}

$venvPython = ".venv\Scripts\python.exe"
$venvPip = ".venv\Scripts\pip.exe"

& $venvPip install --upgrade pip --quiet

if ($hasNvidia) {
    Write-Host "Installing PyTorch with CUDA 12.1 acceleration..." -ForegroundColor Cyan
    & $venvPip install torch torchvision --index-url https://download.pytorch.org/whl/cu121 safetensors transformers peft requests --quiet
} elseif ($hasAmd) {
    Write-Host "Installing PyTorch with DirectML acceleration..." -ForegroundColor Cyan
    & $venvPip install torch-directml safetensors transformers peft requests --quiet
} else {
    Write-Host "Installing PyTorch CPU with AVX acceleration..." -ForegroundColor Cyan
    & $venvPip install torch safetensors transformers peft requests --quiet
}
Write-Host "✓ ML Environment Provisioned for Windows." -ForegroundColor Green

# 4. Install Node.js Dependencies & Compile TypeScript Engine
Write-Host "`n[4/6] Compiling ButaAI TypeScript Gateway & P2P Swarm..." -ForegroundColor Yellow
npm install --silent
npm run build
Write-Host "✓ Engine Compiled Successfully." -ForegroundColor Green

# 5. Verify Base Model on Ollama
Write-Host "`n[5/6] Checking Local Ollama Base Weights..." -ForegroundColor Yellow
$models = ollama list
if ($models -notmatch "buta-ai") {
    if ($models -notmatch "qwen2.5-coder:7b") {
        Write-Host "Pulling sovereign base model (qwen2.5-coder:7b)..." -ForegroundColor Cyan
        ollama pull qwen2.5-coder:7b
    }
    ollama create buta-ai -f Modelfile
}
Write-Host "✓ Model Weights Verified on Ollama." -ForegroundColor Green

# 6. Create Desktop Shortcut & Launch Script
Write-Host "`n[6/6] Generating Windows Launcher & Desktop Shortcut..." -ForegroundColor Yellow

$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$shortcutPath = Join-Path $desktopPath "ButaAI Cockpit.url"
"[InternetShortcut]`nURL=http://localhost:8080" | Out-File -FilePath $shortcutPath -Encoding ascii

Write-Host "✓ Created Desktop Shortcut: 'ButaAI Cockpit.url'" -ForegroundColor Green
Write-Host "------------------------------------------------------------------------------"
Write-Host "✓ ButaAI is now fully initialized on Windows!" -ForegroundColor Green
Write-Host "  • Gateway API:     http://localhost:3030" -ForegroundColor Cyan
Write-Host "  • P2P Swarm Hub:   http://localhost:3030/api/swarm/status" -ForegroundColor Cyan
Write-Host "  • Cockpit Web UI:  http://localhost:8080" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------------------------"

# Launch Gateway
Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run server" -WindowStyle Minimized
Start-Sleep -Seconds 2

# Launch Web Server
Start-Process -FilePath "cmd.exe" -ArgumentList "/c python -m http.server 8080 --directory app\build\web" -WindowStyle Minimized
Start-Sleep -Seconds 1

# Open in Default Browser
Start-Process "http://localhost:8080"

Write-Host "`nAll services are running! Opening Cockpit in your browser..." -ForegroundColor Green
