<div align="center">
  <img src="https://raw.githubusercontent.com/bekovrafik/ButaAI/main/app/assets/images/buta_logo.png" width="100" alt="ButaAI Logo" onerror="this.style.display='none'"/>
  <h1>🔥 ButaAI</h1>
  <h3>Autonomous On-Device Engineering Squad & Decentralized Swarm LoRA Engine</h3>
  <p><b>100% Local • Apple Silicon Metal GPU-Accelerated • Zero Cloud Dependency • Federated Weight Merging</b></p>

  <p>
    <a href="https://github.com/bekovrafik/ButaAI/actions"><img src="https://img.shields.io/badge/CI-Passing-brightgreen?style=flat-square&logo=githubactions&logoColor=white" /></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache--2.0-blue?style=flat-square" /></a>
    <a href="#"><img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Apple%20Silicon%20(M1--M4)-black?style=flat-square&logo=apple" /></a>
    <a href="#"><img src="https://img.shields.io/badge/Acceleration-Metal%20GPU%20(MPS)-orange?style=flat-square" /></a>
    <a href="#"><img src="https://img.shields.io/badge/Inference-Ollama%20%2F%20GGUF-purple?style=flat-square" /></a>
    <a href="https://github.com/bekovrafik/ButaAI/stargazers"><img src="https://img.shields.io/github/stars/bekovrafik/ButaAI?style=flat-square&color=yellow" /></a>
    <a href="https://github.com/bekovrafik/ButaAI/network/members"><img src="https://img.shields.io/github/forks/bekovrafik/ButaAI?style=flat-square&color=lightgrey" /></a>
    <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square" /></a>
  </p>
</div>

---

## ⚡ What is ButaAI?

**ButaAI** is an on-device autonomous software engineering studio that operates **100% locally on your machine**. Instead of sending your private code, database schemas, and intellectual property to cloud AI APIs (OpenAI, Anthropic, Google), ButaAI turns your Mac into a full software development agency powered by a **6-specialist autonomous engineering squad**.

Furthermore, through **Decentralized Swarm LoRA**, millions of ButaAI developers collectively improve one unified open-weights model by training lightweight parameter delta adapters from validated unit tests without sharing any proprietary code.

---

## 🥊 ButaAI vs. Cloud Frontier Models

Why is an on-device specialized squad superior to monolithic cloud LLMs for software development?

| Feature | Cloud Monoliths (Claude 3.5 Sonnet / GPT-4o) | ButaAI Autonomous Studio |
| :--- | :--- | :--- |
| **Data Privacy** | ❌ Code and schemas sent to remote cloud data centers | ✅ **100% On-Device**. Unified GPU RAM execution, zero telemetry |
| **Running Cost** | ❌ \$15 – \$30 per 1M tokens (\$100s/mo in API bills) | ✅ **\$0.00 Forever**. Free local Metal GPU computation |
| **Cognitive Architecture** | ❌ Single generalist prompt approves its own code | ✅ **6 Isolated Specialists** with strict adversarial QA veto |
| **Offline Operation** | ❌ Zero functionality without internet | ✅ **100% Offline**. Code on planes, trains, and air-gapped setups |
| **Model Evolution** | ❌ Static proprietary weights updated twice a year | ✅ **Decentralized Swarm LoRA**. Collective weights merge continuously |
| **Deliverables** | ❌ Disjointed markdown blocks | ✅ **Instant Deliverables**. PRD, SQLite, UI tokens & full .ZIP export |

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

## 🐝 Decentralized Swarm LoRA: Million-User Federated Intelligence

Traditional AI training requires hundreds of millions of dollars in centralized compute. ButaAI introduces **Decentralized Swarm Weight Merging**:

```
[Developer A: MacBook M2] ─── Verified 100% Tests ───> [Adapter ΔWA] ──┐
[Developer B: MacBook M3] ─── Verified 100% Tests ───> [Adapter ΔWB] ──┼─> [TIES Swarm Merger] ──> [Master ButaAI Model]
[Developer C: MacBook M4] ─── Verified 100% Tests ───> [Adapter ΔWC] ──┘
```

1. **Local Gradient Generation**: When you build an application and the QA Verifier confirms a **100% green test pass**, your local engine calculates a lightweight rank-16 LoRA adapter in under 60 seconds on Apple Silicon Metal.
2. **Zero Privacy Leakage**: Only mathematical delta weights ($\Delta W$) and test-pass assertions are synchronized; your proprietary code never leaves your Mac.
3. **TIES Weight Merging**: The Swarm Hub combines adapters using **Task-Informed Weight Trimming (TIES)** and **Spherical Linear Interpolation (SLERP)**, resolving parameter interference and upgrading the collective intelligence for all developers.

> Read the scientific methodology: [docs/AI_ARCHITECTURE_AND_TRAINING.md](docs/AI_ARCHITECTURE_AND_TRAINING.md)

---

## 🚀 Quickstart

### 1-Line Automated Install

```bash
curl -fsSL https://raw.githubusercontent.com/bekovrafik/ButaAI/main/install.sh | bash
```

### Manual Setup

```bash
# 1. Clone the repository
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
│   ├── lib/widgets/            # Specialist Avatars, Deliverables Drawer & Instincts
│   └── lib/services/           # Local Gateway & Metal GPU Connectors
├── src/                        # High-Performance Node.js / TypeScript Gateway
│   ├── agents/specialists.ts   # 6 Autonomous Specialist Prompts & Personas
│   ├── core/engine.ts          # Multi-Turn Tool Calling & Execution Loop
│   └── swarm_hub.ts            # Decentralized LoRA Consensus & Adapter Sync
├── training/                   # Local ML Training & Swarm LoRA Tooling
│   ├── data/                   # Verified JSONL Instruction & DPO Datasets
│   ├── generate_dataset.py     # High-Purity Synthetic Dataset Synthesizer
│   ├── train.py                # Apple Silicon Metal GPU QLoRA Trainer
│   └── swarm_merger.py         # TIES & SLERP Multi-Adapter Weight Merger
├── docs/                       # Architecture & Training Manifestos
│   └── AI_ARCHITECTURE_AND_TRAINING.md
├── install.sh                  # 1-Click Automated Installer
└── Start ButaAI.command        # macOS 1-Click Double-Click Launcher
```

---

## 🧪 Local Training & Dataset Synthesis

To generate fresh training data or train a local domain adapter:

```bash
# Synthesize 5,000 verified reasoning examples
python3 training/generate_dataset.py --samples 5000 --output training/data/train.jsonl

# Train a specialized LoRA adapter on Apple Silicon Metal GPU
python3 training/train.py --role system_architect --steps 100

# Test merging multiple swarm adapters
python3 training/swarm_merger.py --adapters training/adapters/ --output Modelfile
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
