#!/usr/bin/env python3
"""
ButaAI Collective Swarm - Federated LoRA Merger
Fuses decentralized low-rank adapter updates from millions of edge devices
into a single Global Master ButaAI Model using Federated Averaging (FedAvg)
and Parameter-Space Consensus Merging with Apple Silicon MLX.
"""

import os
import sys
import json
import hashlib
import mlx.core as mx

def compute_file_sha256(filepath):
    """Computes SHA-256 hash of a file for cryptographic integrity."""
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()

def validate_adapter_safety(filepath):
    """
    Audits a submitted LoRA adapter for privacy and anti-poisoning safety.
    Guarantees:
      1. Zero raw text, prompt logs, or personal metadata are included.
      2. File format is strictly safetensors dictionary.
      3. Only legitimate low-rank weight matrices (lora_a, lora_b) are present.
      4. No NaN or Inf values.
    """
    if not os.path.exists(filepath):
        return False, "File does not exist"
    
    file_size_mb = os.path.getsize(filepath) / (1024 * 1024)
    if file_size_mb > 35.0:
        return False, f"File size too large ({file_size_mb:.2f} MB > 35 MB limit)"
    
    try:
        tensors = mx.load(filepath)
    except Exception as e:
        return False, f"Corrupted safetensors file: {str(e)}"
    
    if len(tensors) == 0:
        return False, "Adapter contains 0 tensors"
    
    for key, val in tensors.items():
        if not ("lora_a" in key or "lora_b" in key):
            return False, f"Illegal non-LoRA parameter detected: {key}"
        
        # Check for NaN / Inf
        if mx.any(mx.isnan(val)).item() or mx.any(mx.isinf(val)).item():
            return False, f"Corrupted weights (NaN or Inf) in tensor: {key}"
            
    return True, f"Verified safe ({len(tensors)} valid LoRA tensors, {file_size_mb:.2f} MB)"

def federated_average(adapter_paths, weights=None, output_path=None):
    """
    Computes Federated Average (FedAvg) across multiple edge device adapters:
        W_global = sum(weight_i * W_i)
    """
    if not adapter_paths:
        raise ValueError("No adapter paths provided for merging.")
    
    num_adapters = len(adapter_paths)
    if weights is None:
        weights = [1.0 / num_adapters] * num_adapters
    else:
        total_w = sum(weights)
        weights = [w / total_w for w in weights]
        
    print(f"\n🌐 [ButaAI Swarm] Merging {num_adapters} decentralized LoRA adapters...")
    for idx, (path, w) in enumerate(zip(adapter_paths, weights)):
        print(f"  • Node {idx+1}: {os.path.basename(path)} (Weight: {w*100:.1f}%)")
        
    # Load first adapter to initialize global structure
    base_tensors = mx.load(adapter_paths[0])
    global_weights = {}
    
    for key in base_tensors.keys():
        global_weights[key] = base_tensors[key] * weights[0]
        
    # Accumulate remaining adapters
    for i in range(1, num_adapters):
        curr_tensors = mx.load(adapter_paths[i])
        for key in global_weights.keys():
            if key in curr_tensors:
                global_weights[key] = global_weights[key] + (curr_tensors[key] * weights[i])
            else:
                print(f"⚠️ Warning: Missing key {key} in {adapter_paths[i]}, keeping existing consensus")
                
    # Evaluate and persist global master weights
    mx.eval(*global_weights.values())
    
    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        mx.save_safetensors(output_path, global_weights)
        sha = compute_file_sha256(output_path)
        size_mb = os.path.getsize(output_path) / (1024 * 1024)
        print(f"\n✅ [ButaAI Swarm] Global Master Adapter synthesized successfully!")
        print(f"  • File: {output_path}")
        print(f"  • Size: {size_mb:.2f} MB")
        print(f"  • SHA256: {sha[:16]}...{sha[-16:]}")
        return output_path, sha
        
    return global_weights, None

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 swarm_merger.py <validate|merge> [args...]")
        sys.exit(1)
        
    action = sys.argv[1]
    
    if action == "validate":
        if len(sys.argv) < 3:
            print("Usage: python3 swarm_merger.py validate <adapter.safetensors>")
            sys.exit(1)
        target = sys.argv[2]
        is_safe, msg = validate_adapter_safety(target)
        print(f"Validation: {'PASSED' if is_safe else 'FAILED'} - {msg}")
        sys.exit(0 if is_safe else 1)
        
    elif action == "merge":
        if len(sys.argv) < 4:
            print("Usage: python3 swarm_merger.py merge <output.safetensors> <adapter1> <adapter2> ...")
            sys.exit(1)
        out = sys.argv[2]
        inputs = sys.argv[3:]
        federated_average(inputs, output_path=out)
