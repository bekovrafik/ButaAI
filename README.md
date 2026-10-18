<div align="center">
  <img src="https://raw.githubusercontent.com/bekovrafik/ButaAI/main/app/assets/images/buta_logo.png" width="100" alt="ButaAI Logo" onerror="this.style.display='none'"/>
  <h1>🔥 ButaAI</h1>
  <h3>Autonomous On-Device Engineering Squad & Decentralized Swarm LoRA Engine</h3>
  <p><b>100% Local • Apple Silicon Metal GPU-Accelerated • Zero Cloud Dependency • Federated Weight Merging</b></p>

  <p>
    <a href="https://github.com/bekovrafik/ButaAI/actions"><img src="https://img.shields.io/badge/CI-Passing-brightgreen?style=flat-square&logo=githubactions&logoColor=white" /></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache--2.0-blue?style=flat-square" /></a>
    <a href="https://github.com/bekovrafik/ButaAI/actions"><img src="https://img.shields.io/badge/CI-Passing-brightgreen?style=flat-square&logo=githubactions&logoColor=white" /></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache--2.0-blue?style=flat-square" /></a>
    <a href="#"><img src="https://img.shields.io/badge/Platform-Windows%2010%2F11%20%7C%20macOS%20Apple%20Silicon%20%7C%20Linux-black?style=flat-square&logo=windows" /></a>
    <a href="#"><img src="https://img.shields.io/badge/Hardware-NVIDIA%20CUDA%20%7C%20Apple%20Metal%20%7C%20DirectML-orange?style=flat-square" /></a>
    <a href="#"><img src="https://img.shields.io/badge/Inference-Ollama%20%2F%204--Bit%20GGUF-purple?style=flat-square" /></a>
    <a href="https://github.com/bekovrafik/ButaAI/stargazers"><img src="https://img.shields.io/github/stars/bekovrafik/ButaAI?style=flat-square&color=yellow" /></a>
    <a href="https://github.com/bekovrafik/ButaAI/network/members"><img src="https://img.shields.io/github/forks/bekovrafik/ButaAI?style=flat-square&color=lightgrey" /></a>
    <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square" /></a>
  </p>
</div>

---

## ⚡ What is ButaAI?

**ButaAI** is an on-device autonomous software engineering studio that operates **100% locally on your machine** across **Windows 10/11, macOS (Apple Silicon), and Linux**. Instead of sending your private code, database schemas, and intellectual property to cloud AI APIs (OpenAI, Anthropic, Google), ButaAI turns your workstation into a full software development agency powered by a **6-specialist autonomous engineering squad**.

Furthermore, through **Decentralized Swarm LoRA & P2P 16MB Chunk Distribution**, millions of ButaAI developers collectively improve one unified open-weights model by training lightweight parameter delta adapters from validated unit tests without sharing any proprietary code.

---

## 🖥️ Cross-Platform Hardware Acceleration Matrix

ButaAI auto-detects your platform and dynamically switches acceleration backends:

| OS / Platform | Hardware Acceleration | Training Engine | Fuser & Quantizer Backend |
| :--- | :--- | :--- | :--- |
| **macOS (M1–M4)** | Apple Silicon Metal GPU (MPS) | Apple MLX / Metal MPS | MLX Fast-Fuse + 4-Bit Unified Memory |
| **Windows 10/11** | NVIDIA GeForce RTX (CUDA 12.x+) | PyTorch + CUDA Wheels | PyTorch PEFT + BitsAndBytes 4-bit / GGUF Q4_K_M |
| **Windows 10/11** | AMD Radeon / Intel Arc | DirectML (`torch-directml`) | FP16 DirectML Merge |
| **Windows / Linux** | Multi-Core x86_64 CPU | AVX-512 / OpenMP PyTorch | CPU GGUF Quantization |

---

## 🥊 ButaAI vs. Cloud Frontier Models

Why is an on-device specialized squad superior to monolithic cloud LLMs for software development?

| Feature | Cloud Monoliths (Claude 3.5 Sonnet / GPT-4o) | ButaAI Autonomous Studio |
| :--- | :--- | :--- |
| **Data Privacy** | ❌ Code and schemas sent to remote cloud data centers | ✅ **100% On-Device**. Local GPU RAM execution, zero telemetry |
| **Running Cost** | ❌ \$15 – \$30 per 1M tokens (\$100s/mo in API bills) | ✅ **\$0.00 Forever**. Free local GPU computation |
| **Cognitive Architecture** | ❌ Single generalist prompt approves its own code | ✅ **6 Isolated Specialists** with strict adversarial QA veto |
| **Offline Operation** | ❌ Zero functionality without internet | ✅ **100% Offline**. Code on planes, trains, and air-gapped setups |
| **Model Evolution** | ❌ Static proprietary weights updated twice a year | ✅ **Decentralized Swarm LoRA**. Collective weights merge continuously |
| **P2P Distribution** | ❌ Giant multi-gigabyte cloud bottlenecks | ✅ **16 MB P2P Chunks**. Merkle-verified BitTorrent / peer LAN sync |
| **Deliverables & Live Canvas**| ❌ Disjointed markdown blocks | ✅ **Interactive Live Canvas**. Mobile/Tablet frames, code copy & .ZIP export |
| **Multimodal Assets** | ❌ Cloud token fees for images & video | ✅ **Native On-Device Creation**. Vector SVGs, Flutter animations, 18s kinetic launch video storyboards |

---

## 🎨 Multimodal Creation Engine (Zero Cloud Token Fees)

ButaAI includes native on-device tools to craft complete creative and engineering assets:

- **🖼️ Procedural Vector SVGs (`generate_image`)**: Generates crisp, infinite-resolution app icons, badges, UI mocks, and architecture diagrams directly on disk with specular lighting, concentric beveled borders, and instant web previews.
- **✨ 60 FPS Motion & Physics (`generate_animation`)**: Synthesizes production-ready Flutter `CustomPainter` widgets with `AnimationController` and hardware-accelerated CSS keyframe animations.
- **🎬 18-Second Launch Video Storyboards (`generate_video_storyboard`)**: Produces high-retention launch video blueprinted into 5 cinematic acts (Hook, Problem, Reveal, Proof, CTA) with JSON timeline data, interactive HTML5 web player, and automated FFmpeg render scripts.
- **📱 Live Multi-Agent Interactive Canvas**: Live interactive preview workspace directly inside the Cockpit featuring mobile (340x640), tablet (460x600), and fluid desktop frames with responsive reactive state testing and code inspection.

---

## 👥 The 6 Autonomous Specialists

When you pitch a feature or complete app concept, ButaAI orchestrates 6 dedicated engineering specialists who debate requirements and self-verify before writing production code:

1. **🎩 Buta CEO**: Executive scoping, milestone planning, and release roadmaps.
2. **📋 Product Architect**: Rigorous PRDs, user stories, edge cases, and acceptance criteria.
3. **📐 System Architect**: Clean Architecture, SQLite entity relational schemas, and state management patterns.
4. **🎨 Lead Frontend Engineer**: Modern design systems, liquid glass styling tokens, responsive layouts, and zero-leak controllers.
5. **⚙️ Lead Backend Engineer**: High-performance SQLite repositories, batch transactions, and data pipeline caching.
6. **🛡️ QA & Security Verifier**: Automated unit test suites, mock generation, memory leak audits, and vulnerability guardrails.

---

## 🐝 Decentralized Swarm LoRA & P2P Chunk Distribution

Traditional AI training requires hundreds of millions of dollars in centralized compute. ButaAI introduces **Decentralized Swarm Weight Merging via GitHub Actions & P2P Swarm**:

```
[Developer A: Windows RTX 4090] ── Verified 100% Tests ──> [Adapter ΔWA] ──┐
[Developer B: MacBook M3 Max]   ── Verified 100% Tests ──> [Adapter ΔWB] ──┼─> [P2P 16MB Chunk Swarm] ──> [Master Model]
[Developer C: Linux Titan GPU]  ── Verified 100% Tests ──> [Adapter ΔWC] ──┘
```

1. **Local Gradient Generation**: When you build an application and the QA Verifier confirms a **100% green test pass**, your local engine calculates a lightweight rank-16 LoRA adapter in under 60 seconds on Apple Silicon Metal or Windows NVIDIA CUDA.
2. **16 MB BitTorrent / P2P Swarm Chunks**: Large 35 GB–40 GB adapters are sliced into 16 MB content-addressed blocks with cryptographic SHA-256 Merkle root verification, enabling zero-cloud LAN/peer sync.
3. **4-Bit Model Fuser**: Locally merges adapters into the base Ollama model and exports a quantized GGUF (`buta-ai:colossus-fused`) for lightning-fast memory-efficient inference.
4. **Zero Privacy Leakage**: Only mathematical delta weights ($\Delta W$) and test-pass assertions are synchronized; your proprietary code never leaves your machine.

---

## 🚀 Quickstart

### 🪟 Windows 10/11 Installation

**Option A: 1-Line PowerShell Bootstrap (Run as Administrator or User):**
```powershell
iwr -useb https://raw.githubusercontent.com/bekovrafik/ButaAI/main/install.ps1 | iex
```

**Option B: Double-Click Batch Installer:**
1. Clone the repo: `git clone https://github.com/bekovrafik/ButaAI.git`
2. Double-click `install.bat` to automatically install dependencies and configure NVIDIA CUDA / DirectML.
3. Double-click `launch.bat` anytime to launch the Gateway and open the Cockpit!

---

### 🍏 macOS (Apple Silicon M1–M4) & Linux

**Option A: 1-Line Automated Install:**
```bash
curl -fsSL https://raw.githubusercontent.com/bekovrafik/ButaAI/main/install.sh | bash
```

**Option B: Manual Setup:**
```bash
# 1. Clone repository
git clone https://github.com/bekovrafik/ButaAI.git
cd ButaAI

# 2. Install dependencies & build Gateway
npm install
npm run build

# 3. Launch with 1-click script
./Start\ ButaAI.command
```

Open your browser at **http://localhost:8080** to access the Cockpit Studio!

---

## 📦 Project Structure

```
ButaAI/
├── app/                        # Flutter Web & Desktop Cockpit Studio
│   ├── lib/screens/            # Interactive Cockpit UI & Streaming Chat
│   ├── lib/widgets/            # Live Canvas, Specialist Avatars, Deliverables & Instincts
│   └── lib/services/           # Local Gateway, Hardware & Metal/CUDA Connectors
├── src/                        # High-Performance Node.js / TypeScript Gateway
│   ├── agents/specialists.ts   # 6 Autonomous Specialist Prompts & Personas
│   ├── core/engine.ts          # Multi-Turn Tool Calling & Execution Loop
│   ├── tools/media_tools.ts    # Multimodal Generator (Vector SVGs, Flutter Animations, 18s Video)
│   ├── swarm_hub.ts            # Decentralized LoRA Consensus & Adapter Sync
│   └── swarm_p2p.ts            # P2P 16MB Chunk Distribution & Merkle Engine
├── training/                   # Cross-Platform Local ML Training & Swarm LoRA
│   ├── data/                   # Verified JSONL Instruction & Multimodal Datasets
│   ├── generate_dataset.py     # High-Purity Synthetic Dataset Synthesizer
│   ├── train.py                # Cross-Platform QLoRA Trainer (Metal MPS & NVIDIA CUDA)
│   ├── fuse_quantize.py        # 4-Bit Model Fuser (MLX & PyTorch BitsAndBytes)
│   ├── swarm_merger.py         # FedAvg Parameter-Space LoRA Merger & Safety Auditor
│   └── github_trainer.py       # GitHub Swarm Synchronizer & Delta Contributor
├── .github/workflows/          # CI and GitHub Swarm Training Release Pipeline
│   ├── ci.yml                  # Engine & Flutter Build Verification
│   └── buta_swarm_train.yml    # Decentralized Swarm LoRA Train & Release Bot
├── docs/                       # Architecture & Training Manifestos
│   └── AI_ARCHITECTURE_AND_TRAINING.md
├── install.sh                  # macOS / Linux 1-Click Installer
├── install.ps1                 # Windows 10/11 PowerShell Bootstrap Installer
├── install.bat                 # Windows Double-Click Batch Installer
├── launch.bat                  # Windows 1-Click Service Launcher
└── Start ButaAI.command        # macOS 1-Click Double-Click Launcher
```


---

## 🧪 Local Training & GitHub Swarm CLI

### 1. Synchronize Collective Master Weights from GitHub
```bash
python3 training/github_trainer.py --sync
```
Downloads the verified consensus master LoRA adapter from GitHub Releases (`swarm-weights-latest`), audits cryptographic SHA-256 integrity, and activates it on your Apple Silicon Metal GPU.

### 2. Train Local LoRA (Apple Silicon Metal & Windows NVIDIA CUDA)
```bash
# macOS (Apple Silicon Metal MPS)
python3 training/train.py 20

# Windows 10/11 (NVIDIA CUDA or CPU)
python training/train.py 20
```

### 3. Fuse & Quantize Local Weights into Ollama (4-Bit GGUF)
```bash
# Merges the 35GB-40GB collective adapter into Ollama with 4-bit quantization
python3 training/fuse_quantize.py --tier colossus --quantize 4bit

# Run the fused model immediately
ollama run buta-ai:colossus-fused
```

### 4. Contribute Verified Delta to the Collective Swarm
```bash
python3 training/github_trainer.py --contribute
```
Audits your trained weights for privacy (guaranteeing zero personal code or prompt text leakage), packages a verified `contribution_manifest.json`, and guides you to open a PR for collective FedAvg synthesis on GitHub Actions!

### 5. Synthesize Fresh Synthetic Multimodal Datasets
```bash
python3 training/generate_dataset.py
```


---

## 🤝 Contributing

We welcome contributions from engineers, researchers, and creators worldwide!
* Check out [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
* Submit issues using our [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md) or [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md) templates.
* Share your custom LoRA weights via the [LoRA Adapter Proposal](.github/ISSUE_TEMPLATE/lora_adapter_proposal.md) template.

---

## 📄 License

ButaAI is licensed under the [Apache License 2.0](LICENSE).  
Created and maintained with ❤️ by **[Rafik Bekov](https://github.com/bekovrafik)** and the **[Butalabs](https://www.butalabs.com)** team.
