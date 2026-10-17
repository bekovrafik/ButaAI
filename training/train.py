#!/usr/bin/env python3
"""
ButaAI Apple Silicon Metal Fast Trainer (MLX LoRA)
Trains ButaAI on local hardware with zero external dependencies.
"""

import os
import sys
import subprocess

TRAINING_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(TRAINING_DIR, "data")
ADAPTER_DIR = os.path.join(TRAINING_DIR, "adapters")
os.makedirs(ADAPTER_DIR, exist_ok=True)

MODEL_NAME = os.getenv("BUTA_BASE_MODEL", "mlx-community/Qwen2.5-Coder-7B-Instruct-4bit")

def check_environment():
    train_file = os.path.join(DATA_DIR, "train.jsonl")
    if not os.path.exists(train_file):
        print("Dataset not found. Generating...")
        subprocess.run([sys.executable, os.path.join(TRAINING_DIR, "generate_dataset.py")], check=True)

def train(iters=50, batch_size=1, num_layers=4, lr=1e-4, max_seq_length=512):
    print("\n" + "="*60)
    print("🚀 [ButaAI] Launching Apple Silicon Metal Local Training Loop")
    print(f"Base Model:       {MODEL_NAME}")
    print(f"Hardware:         Apple Silicon (Metal Unified Memory - Memory Guarded)")
    print(f"Iterations:       {iters}")
    print(f"Batch Size:       {batch_size}")
    print(f"LoRA Layers:      {num_layers}")
    print(f"Max Seq Length:   {max_seq_length}")
    print(f"Adapter Output:   {ADAPTER_DIR}")
    print("="*60 + "\n")

    cmd = [
        sys.executable,
        "-m", "mlx_lm", "lora",
        "--model", MODEL_NAME,
        "--train",
        "--data", DATA_DIR,
        "--adapter-path", ADAPTER_DIR,
        "--iters", str(iters),
        "--batch-size", str(batch_size),
        "--num-layers", str(num_layers),
        "--max-seq-length", str(max_seq_length),
        "--grad-checkpoint",
        "--learning-rate", str(lr),
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
    check_environment()
    iters = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    train(iters=iters)
