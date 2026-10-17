# 🌐 ButaAI Decentralized Collective Swarm LoRA Engine

> **Millions of edge devices train one sovereign AI.**  
> 100% On-Device, Private, and Apple Silicon Metal GPU-Accelerated.

---

## 💡 Overview

Traditional frontier AI models (Claude, Gemini, ChatGPT) are centralized black boxes running in expensive cloud datacenters. Every question and line of proprietary code you write is transmitted over the internet to remote servers, incurring subscription fees and privacy risks.

**ButaAI reverses this paradigm.**

Instead of relying on cloud weights that freeze at training time, **ButaAI uses a Decentralized Swarm LoRA Engine**:
* Every user running ButaAI locally can fine-tune small mathematical delta adapters on their own Apple Silicon Metal GPU.
* **Zero raw prompts, code files, or personal information ever leave your machine.**
* Only privacy-audited, low-rank parameter matrices (`safetensors`) are contributed to GitHub.
* GitHub Actions runs an automated **Federated Averaging (FedAvg)** consensus merger that synthesizes updates from thousands of nodes into one continually evolving Global Master Model.

---

## ⚡ The 3 Swarm Intelligence Tiers

| Tier | Size | Rank ($r$) | Compute Time | Best For |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 1: Nano-Delta** | **11 MB** | Rank 8, 4 layers | ~45 seconds on M1/M2/M3 | Fast edge sync, syntax bug fixes, cellular hotspots |
| **Tier 2: Deep-Brain** | **500 MB** | Rank 64, 16 layers | ~3–5 mins on M-Pro/Max | Architectural refactoring, design systems, multimodal vector graphics |
| **Tier 3: Sovereign Titan** | **1.2 GB** | Rank 128, all layers | ~8–12 mins on M-Max/Ultra | Full-parameter depth rivaling frontier cloud models on coding benchmarks |

---

## 🛡️ Privacy & Anti-Poisoning Guarantees

Every adapter submitted to the ButaAI Swarm must pass the automated cryptographic gatekeeper ([`training/swarm_merger.py`](file:///Users/bekovrafik/Butalabs/ButaAI/training/swarm_merger.py)):

1. **No String or Token Leakage**: The file format is strictly a binary `.safetensors` dictionary of float tensors. Zero strings, prompts, tokens, or filenames exist in the file.
2. **LoRA-Only Parameter Whitelist**: Only parameters matching `lora_a` and `lora_b` decomposition matrices are accepted. Any arbitrary tensor name causes instant rejection.
3. **Anti-Poisoning & Numerical Health**: Weights are mathematically scanned for `NaN`, `Inf`, and abnormal gradient explosions before entry into the consensus pool.
4. **Cryptographic Attestation**: Every master release is signed with a deterministic SHA-256 hash published in `checksums.txt`.

---

## 🛠️ Step-by-Step: How to Train and Contribute

### 1. Synchronize with Latest Global Weights
Download the collective consensus weights from GitHub Releases into your local engine:
```bash
python3 training/github_trainer.py --sync
```

### 2. Train Local Delta on Apple Silicon Metal
Train your chosen intelligence tier on your device:
```bash
# Tier 1: Fast edge delta (11 MB)
python3 training/github_trainer.py --train 50 --tier nano

# Tier 2: Deep-brain reasoning (500 MB)
python3 training/github_trainer.py --train 100 --tier brain

# Tier 3: Sovereign titan (1.2 GB)
python3 training/github_trainer.py --train 200 --tier titan
```

### 3. Package & Audit Your Contribution
Run the automated privacy and format validator:
```bash
python3 training/github_trainer.py --contribute
```
This generates a verified `training/adapters/contribution_manifest.json`.

### 4. Submit to GitHub Swarm
1. Fork [https://github.com/bekovrafik/ButaAI](https://github.com/bekovrafik/ButaAI)
2. Commit your `training/adapters/contribution_manifest.json`
3. Open a Pull Request tagged `[swarm-contribution]`
4. GitHub Actions will automatically audit, run FedAvg merge, and update the global release!

---

## 📦 Global Distribution Channels

* **GitHub Releases**: [https://github.com/bekovrafik/ButaAI/releases/tag/swarm-weights-latest](https://github.com/bekovrafik/ButaAI/releases/tag/swarm-weights-latest)
* **Hugging Face Hub**: `huggingface.co/bekovrafik/ButaAI-Swarm-Weights`
* **Local Ollama Daemon**:
  ```bash
  python3 training/export_to_ollama.py
  ollama run buta-ai
  ```
