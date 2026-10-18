# 🌐 ButaAI Decentralized Collective Swarm LoRA Engine

> **Millions of edge devices train one sovereign AI.**  
> 100% On-Device, Private, Apple Silicon Metal & Windows NVIDIA CUDA Accelerated.

---

## 💡 Overview

Traditional frontier AI models (Claude, Gemini, ChatGPT) are centralized black boxes running in expensive cloud datacenters. Every question and line of proprietary code you write is transmitted over the internet to remote servers, incurring subscription fees and privacy risks.

**ButaAI reverses this paradigm.**

Instead of relying on cloud weights that freeze at training time, **ButaAI uses a Decentralized Swarm LoRA Engine**:
* Every user running ButaAI locally can fine-tune mathematical delta adapters on their own **Apple Silicon Metal GPU** (M1–M4) or **Windows NVIDIA GeForce RTX GPU** (CUDA 12.x+ / DirectML).
* **Zero raw prompts, code files, or personal information ever leave your machine.**
* Only privacy-audited, low-rank parameter matrices (`safetensors`) are contributed to the swarm.
* GitHub Actions & P2P Swarm run automated **Federated Averaging (FedAvg)** consensus merging that synthesizes updates from thousands of nodes into one continually evolving Global Master Model.

---

## ⚡ The 4 Swarm Intelligence Tiers

| Tier | Size | Rank ($r$) | Compute Time | Best For |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 1: Nano-Delta** | **11 MB** | Rank 8, 4 layers | ~45s (Metal / RTX 4070) | Fast edge sync, syntax bug fixes, cellular hotspots |
| **Tier 2: Deep-Brain** | **1.2 GB** | Rank 128, 16 layers | ~3–5 mins (Metal / RTX 4080) | Architectural refactoring, design systems, multimodal vector graphics |
| **Tier 3: Sovereign Titan** | **10 GB** | Rank 1024, 28 layers | ~8–15 mins (Metal / RTX 4090) | Full-parameter depth rivaling frontier cloud models on coding benchmarks |
| **Tier 4: Sovereign Colossus** | **35 GB (30-40 GB)** | Rank 4096, 32 layers | ~20–35 mins (Unified 64GB+ / Dual RTX) | Full-rank sovereign foundation consensus weight for local workstation memory |

---

## 🌐 BitTorrent & P2P 16MB Chunk Distribution

To eliminate cloud download bottlenecks when distributing 35 GB–40 GB Colossus models, ButaAI features an integrated **P2P Swarm Engine** (`src/swarm_p2p.ts`):

1. **16 MB Slicing**: Adapters are diced into 16,777,216-byte content-addressed binary chunks stored in `.buta/swarm_cache/chunks/`.
2. **Merkle Root Integrity**: Every chunk index is mapped to its SHA-256 hash. The top-level Merkle root is recorded in the swarm manifest:
   ```json
   {
     "tier": "colossus",
     "epoch": "v2.5-collective",
     "chunkSize": 16777216,
     "totalChunks": 3,
     "merkleRoot": "70d2fa3c285e64816c17f9a888c3a9f0..."
   }
   ```
3. **Peer Streaming & Swarm Sync**: Nodes advertise their available chunk bitfields. New nodes download chunks in parallel across available LAN and WAN peers via `POST /api/swarm/p2p/sync`, automatically verifying each chunk before assembling the final master adapter.

---

## 🧬 4-Bit Model Fuser & Quantization Pipeline

Once a 35 GB adapter is synchronized or trained, the local **Model Fuser** (`training/fuse_quantize.py`):
1. Loads the base model (`qwen2.5-coder:7b`) and applies the LoRA delta matrix in full parameter space.
2. Quantizes the fused tensor weights to **4-bit precision** (MLX unified memory quantization on Apple Silicon, BitsAndBytes / GGUF Q4_K_M on Windows/Linux).
3. Automatically writes a tailored `Modelfile` and registers the fused model directly into the local Ollama daemon:
   ```bash
   python3 training/fuse_quantize.py --tier colossus --quantize 4bit
   ollama run buta-ai:colossus-fused
   ```

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

### 2. Train Local Delta (Apple Silicon Metal & Windows NVIDIA CUDA)
Train your chosen intelligence tier on your device:
```bash
# Tier 1: Fast edge delta (11 MB)
python3 training/github_trainer.py --train 50 --tier nano

# Tier 2: Deep-brain reasoning (1.2 GB)
python3 training/github_trainer.py --train 100 --tier brain

# Tier 3: Sovereign titan (10 GB)
python3 training/github_trainer.py --train 200 --tier titan

# Tier 4: Sovereign colossus (35 GB)
python3 training/github_trainer.py --train 500 --tier colossus
```

### 3. Fuse & Quantize Weights Locally
```bash
python3 training/fuse_quantize.py --tier colossus --quantize 4bit
```

### 4. Package & Audit Your Contribution
Run the automated privacy and format validator:
```bash
python3 training/github_trainer.py --contribute
```
This generates a verified `training/adapters/contribution_manifest.json`.

### 5. Submit to GitHub Swarm
1. Fork [https://github.com/bekovrafik/ButaAI](https://github.com/bekovrafik/ButaAI)
2. Commit your `training/adapters/contribution_manifest.json`
3. Open a Pull Request tagged `[swarm-contribution]`
4. GitHub Actions will automatically audit, run FedAvg merge, and update the global release!

---

## 📦 Global Distribution Channels

* **GitHub Releases**: [https://github.com/bekovrafik/ButaAI/releases/tag/swarm-weights-latest](https://github.com/bekovrafik/ButaAI/releases/tag/swarm-weights-latest)
* **P2P Swarm Network**: Distributed 16MB Merkle chunk streaming via local Gateway (`/api/swarm/p2p/`)
* **Local Ollama Daemon**:
  ```bash
  ollama run buta-ai:colossus-fused
  ```

