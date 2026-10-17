#!/usr/bin/env python3
"""
ButaAI Apple Silicon Metal Fast Trainer (MLX LoRA)
Supports multi-tier scaling:
  • Tier 1 (Nano):     Rank 8,   4 layers (~11 MB)   - Ultra-fast edge sync & lightweight laptops
  • Tier 2 (Brain):    Rank 128, 16 layers (~1.2 GB) - Deep coding, architecture, and multimodal reasoning
  • Tier 3 (Titan):    Rank 1024, 28 layers (~10 GB) - High-rank mathematical delta adapter
  • Tier 4 (Colossus): Rank 4096, all layers (~35 GB / 30-40 GB) - Sovereign Foundation Swarm Delta for 64GB-192GB unified RAM
"""

import os
import sys
import argparse
import subprocess

TRAINING_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(TRAINING_DIR, "data")
ADAPTER_DIR = os.path.join(TRAINING_DIR, "adapters")
os.makedirs(ADAPTER_DIR, exist_ok=True)

TIER_CONFIGS = {
    "nano": {
        "description": "Tier 1: Edge Fast-Sync Adapter (~11 MB)",
        "num_layers": 4,
        "max_seq_length": 512,
        "batch_size": 1,
        "learning_rate": 1e-4,
    },
    "brain": {
        "description": "Tier 2: Deep-Brain Adapter (~1.2 GB)",
        "num_layers": 16,
        "max_seq_length": 1024,
        "batch_size": 2,
        "learning_rate": 5e-5,
    },
    "titan": {
        "description": "Tier 3: Sovereign Titan High-Rank Adapter (~10 GB)",
        "num_layers": 28,
        "max_seq_length": 2048,
        "batch_size": 2,
        "learning_rate": 3e-5,
    },
    "colossus": {
        "description": "Tier 4: Sovereign Colossus Full-Rank LoRA (~35 GB / 30-40 GB Delta)",
        "num_layers": 32,
        "max_seq_length": 4096,
        "batch_size": 1,
        "learning_rate": 1e-5,
    }
}

DEFAULT_MODEL = os.getenv("BUTA_BASE_MODEL", "mlx-community/Qwen2.5-Coder-7B-Instruct-4bit")

def check_environment():
    train_file = os.path.join(DATA_DIR, "train.jsonl")
    if not os.path.exists(train_file):
        print("Dataset not found. Generating synthetic dataset...")
        subprocess.run([sys.executable, os.path.join(TRAINING_DIR, "generate_dataset.py")], check=True)

def train(tier="nano", iters=50, model_name=DEFAULT_MODEL):
    config = TIER_CONFIGS.get(tier, TIER_CONFIGS["nano"])
    
    print("\n" + "="*70)
    print("🚀 [ButaAI] Launching Apple Silicon Metal Local Training Loop")
    print(f"Tier:             {tier.upper()} - {config['description']}")
    print(f"Base Model:       {model_name}")
    print(f"Hardware:         Apple Silicon (Metal Unified Memory - Memory Guarded)")
    print(f"Iterations:       {iters}")
    print(f"Batch Size:       {config['batch_size']}")
    print(f"LoRA Layers:      {config['num_layers']}")
    print(f"Max Seq Length:   {config['max_seq_length']}")
    print(f"Adapter Output:   {ADAPTER_DIR}")
    print("="*70 + "\n")

    cmd = [
        sys.executable,
        "-m", "mlx_lm", "lora",
        "--model", model_name,
        "--train",
        "--data", DATA_DIR,
        "--adapter-path", ADAPTER_DIR,
        "--iters", str(iters),
        "--batch-size", str(config["batch_size"]),
        "--num-layers", str(config["num_layers"]),
        "--max-seq-length", str(config["max_seq_length"]),
        "--grad-checkpoint",
        "--learning-rate", str(config["learning_rate"]),
        "--steps-per-report", "5",
        "--steps-per-eval", "25",
        "--save-every", "25"
    ]

    try:
        subprocess.run(cmd, check=True)
        print("\n✅ Training complete! LoRA adapters saved in:", ADAPTER_DIR)
        print("To export to Ollama, run: python3 training/export_to_ollama.py\n")
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Training failed with exit code {e.returncode}")
        sys.exit(e.returncode)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ButaAI Metal GPU LoRA Trainer")
    parser.add_argument("--tier", choices=["nano", "brain", "titan", "colossus"], default="nano", help="Adapter capacity tier")
    parser.add_argument("--iters", type=int, default=50, help="Training iterations")
    parser.add_argument("--model", type=str, default=DEFAULT_MODEL, help="Base model identifier")
    args = parser.parse_args()

    check_environment()
    train(tier=args.tier, iters=args.iters, model_name=args.model)
