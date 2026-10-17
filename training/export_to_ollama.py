#!/usr/bin/env python3
"""
ButaAI Model Exporter
Fuses trained LoRA weights with base model and packages directly into local Ollama.
"""

import os
import sys
import subprocess

TRAINING_DIR = os.path.dirname(os.path.abspath(__file__))
ADAPTER_DIR = os.path.join(TRAINING_DIR, "adapters")
FUSED_DIR = os.path.join(TRAINING_DIR, "fused_model")
ROOT_DIR = os.path.dirname(TRAINING_DIR)

BASE_MODEL = "Qwen/Qwen2.5-Coder-7B-Instruct"

def fuse_and_export():
    print("\n" + "="*60)
    print("📦 [ButaAI] Fusing LoRA Adapter & Packaging for Ollama")
    print(f"Adapter:    {ADAPTER_DIR}")
    print(f"Target:     {FUSED_DIR}")
    print("="*60 + "\n")

    if not os.path.exists(ADAPTER_DIR) or not os.listdir(ADAPTER_DIR):
        print(f"❌ Error: No adapters found in {ADAPTER_DIR}. Run training first:")
        print("   python3 training/train.py")
        sys.exit(1)

    # 1. Fuse LoRA weights with base model via MLX
    print("Step 1: Fusing LoRA adapter weights...")
    fuse_cmd = [
        sys.executable,
        "-m", "mlx_lm.fuse",
        "--model", BASE_MODEL,
        "--adapter-path", ADAPTER_DIR,
        "--save-path", FUSED_DIR
    ]
    subprocess.run(fuse_cmd, check=True)
    print("✅ Model weights fused successfully into:", FUSED_DIR)

    # 2. Generate updated Modelfile
    trained_modelfile = os.path.join(ROOT_DIR, "Modelfile.trained")
    print("Step 2: Generating Modelfile for Ollama...")
    with open(trained_modelfile, "w") as f:
        f.write(f"""FROM {FUSED_DIR}

PARAMETER temperature 0.2
PARAMETER top_p 0.95
PARAMETER repeat_penalty 1.1
PARAMETER num_ctx 8192

SYSTEM \"\"\"You are ButaAI, the autonomous local AI software company operator.
You use tools actively to inspect, write, test, and verify code on the user's machine.
You follow strict Clean Architecture, Riverpod 3.x NotifierProvider conventions, and TDD cycles.
\"\"\"
""")

    # 3. Create or update Ollama model
    print("Step 3: Registering buta-ai model in local Ollama daemon...")
    ollama_cmd = ["ollama", "create", "buta-ai", "-f", trained_modelfile]
    subprocess.run(ollama_cmd, check=True)

    print("\n🎉 [Success] buta-ai has been updated in local Ollama with your trained weights!")
    print("Check with: ollama list\n")

if __name__ == "__main__":
    fuse_and_export()
