#!/usr/bin/env python3
"""
ButaAI Hugging Face Hub Global Mirror
Publishes collective master LoRA weights and consensus attestation to Hugging Face Hub.
Enables developers worldwide to load ButaAI via huggingface_hub, vLLM, llama.cpp, or Ollama.
"""

import os
import sys
import json
import argparse
import hashlib

TRAINING_DIR = os.path.dirname(os.path.abspath(__file__))
ADAPTERS_DIR = os.path.join(TRAINING_DIR, "adapters")
MASTER_ADAPTER = os.path.join(ADAPTERS_DIR, "global_master.safetensors")
CONFIG_PATH = os.path.join(ADAPTERS_DIR, "adapter_config.json")

def compute_sha256(filepath):
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()

def generate_model_card(repo_id, sha256_hash, size_mb):
    return f"""---
license: apache-2.0
base_model: Qwen/Qwen2.5-Coder-7B-Instruct
tags:
  - buta-ai
  - lora
  - mlx
  - apple-silicon
  - metal
  - federated-learning
  - swarm-intelligence
  - code-generation
  - autonomous-agents
pipeline_tag: text-generation
---

# 🌐 ButaAI: Sovereign Collective Swarm LoRA Weights

Official decentralized consensus adapter weights for **ButaAI**, trained on local Apple Silicon Metal GPUs across community nodes using privacy-preserving Federated Averaging (FedAvg).

## 🛡️ Cryptographic Integrity
* **Target Base Model**: `Qwen/Qwen2.5-Coder-7B-Instruct` (or `mlx-community/Qwen2.5-Coder-7B-Instruct-4bit`)
* **Format**: `.safetensors` (Zero text or personal telemetry included)
* **SHA-256 Digest**: `{sha256_hash}`
* **File Size**: `{size_mb:.2f} MB`
* **Release Channel**: Sovereign Swarm Production

## ⚡ Quick Start

### 1. Run with Apple Silicon MLX
```bash
git clone https://github.com/bekovrafik/ButaAI.git
cd ButaAI
python3 training/github_trainer.py --sync
```

### 2. Run with Ollama
```bash
# Pull & run ButaAI directly:
ollama run bekovrafik/buta-ai:latest
```

### 3. Load in Python with Hugging Face Hub
```python
from huggingface_hub import hf_hub_download

adapter_path = hf_hub_download(
    repo_id="{repo_id}",
    filename="global_master.safetensors"
)
print("ButaAI Swarm Weights loaded from:", adapter_path)
```

## 🌐 Join the Swarm
Every Apple Silicon Mac running ButaAI can train mathematical delta updates on device and merge into the collective brain:
* **Repository**: [https://github.com/bekovrafik/ButaAI](https://github.com/bekovrafik/ButaAI)
"""

def publish(repo_id="bekovrafik/ButaAI-Swarm-Weights", token=None):
    print("\n" + "="*70)
    print(f"🤗 [ButaAI] Publishing Swarm Weights to Hugging Face Hub: {repo_id}")
    print("="*70)

    if not os.path.exists(MASTER_ADAPTER):
        print(f"❌ Master adapter not found at {MASTER_ADAPTER}")
        sys.exit(1)

    sha = compute_sha256(MASTER_ADAPTER)
    size_mb = os.path.getsize(MASTER_ADAPTER) / (1024 * 1024)
    hf_token = token or os.getenv("HF_TOKEN")

    print(f"• File:   {MASTER_ADAPTER}")
    print(f"• Size:   {size_mb:.2f} MB")
    print(f"• SHA256: {sha}")

    try:
        from huggingface_hub import HfApi, create_repo
    except ImportError:
        print("\n⚠️ Note: 'huggingface_hub' package not installed in active environment.")
        print("Run: pip install huggingface_hub")
        print("\nGenerated Model Card Preview:")
        print(generate_model_card(repo_id, sha, size_mb)[:300] + "...\n")
        return

    if not hf_token:
        print("\n⚠️ No HF_TOKEN found in environment or arguments.")
        print("Set your Hugging Face API token with: export HF_TOKEN=hf_xxx")
        return

    api = HfApi(token=hf_token)
    create_repo(repo_id=repo_id, repo_type="model", token=hf_token, exist_ok=True)

    # Write README.md model card
    readme_path = os.path.join(ADAPTERS_DIR, "README_HF.md")
    with open(readme_path, "w") as f:
        f.write(generate_model_card(repo_id, sha, size_mb))

    api.upload_file(
        path_or_fileobj=MASTER_ADAPTER,
        path_in_repo="global_master.safetensors",
        repo_id=repo_id,
        repo_type="model",
    )
    api.upload_file(
        path_or_fileobj=readme_path,
        path_in_repo="README.md",
        repo_id=repo_id,
        repo_type="model",
    )
    if os.path.exists(CONFIG_PATH):
        api.upload_file(
            path_or_fileobj=CONFIG_PATH,
            path_in_repo="adapter_config.json",
            repo_id=repo_id,
            repo_type="model",
        )

    print(f"\n🎉 Successfully published ButaAI Swarm Weights to: https://huggingface.co/{repo_id}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Publish ButaAI Swarm Weights to Hugging Face Hub")
    parser.add_argument("--repo-id", default="bekovrafik/ButaAI-Swarm-Weights", help="Target Hugging Face repository ID")
    parser.add_argument("--token", default=None, help="Hugging Face User Access Token")
    args = parser.parse_args()

    publish(repo_id=args.repo_id, token=args.token)
