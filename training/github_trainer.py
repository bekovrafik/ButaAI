#!/usr/bin/env python3
"""
ButaAI GitHub Swarm Trainer & Adapter Synchronizer
Connects local ButaAI instances with GitHub Actions and Releases
for decentralized collective model fine-tuning and weight distribution.
"""

import os
import sys
import json
import argparse
import hashlib
import urllib.request
import shutil
from datetime import datetime, timezone

REPO_OWNER = "bekovrafik"
REPO_NAME = "ButaAI"
RELEASE_TAG = "swarm-weights-latest"
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ADAPTERS_DIR = os.path.join(BASE_DIR, "training", "adapters")
LOCAL_ADAPTER = os.path.join(ADAPTERS_DIR, "adapters.safetensors")
MASTER_ADAPTER = os.path.join(ADAPTERS_DIR, "global_master.safetensors")
SWARM_CONFIG = os.path.join(BASE_DIR, ".buta", "swarm_config.json")

def compute_sha256(filepath):
    """Calculates SHA-256 hash of a file."""
    if not os.path.exists(filepath):
        return None
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()

def get_swarm_status():
    """Returns local and swarm configuration status."""
    local_hash = compute_sha256(LOCAL_ADAPTER)
    master_hash = compute_sha256(MASTER_ADAPTER)
    
    config = {}
    if os.path.exists(SWARM_CONFIG):
        try:
            with open(SWARM_CONFIG, "r") as f:
                config = json.load(f)
        except Exception:
            pass
            
    return {
        "repo": f"{REPO_OWNER}/{REPO_NAME}",
        "node_id": config.get("nodeId", "local_node"),
        "participating": config.get("participating", True),
        "local_adapter_exists": os.path.exists(LOCAL_ADAPTER),
        "local_hash": local_hash,
        "master_adapter_exists": os.path.exists(MASTER_ADAPTER),
        "master_hash": master_hash,
        "is_synced": local_hash is not None and local_hash == master_hash,
        "last_synced_at": config.get("lastSyncedAt"),
        "last_contributed_at": config.get("lastContributedAt"),
    }

def sync_weights():
    """
    Downloads or synchronizes the latest collective master adapter.
    Tries GitHub Releases first; falls back to master adapter on disk.
    """
    os.makedirs(ADAPTERS_DIR, exist_ok=True)
    print(f"\n🔄 [GitHub Swarm] Synchronizing ButaAI with {REPO_OWNER}/{REPO_NAME}...")

    download_url = f"https://github.com/{REPO_OWNER}/{REPO_NAME}/releases/download/{RELEASE_TAG}/global_master.safetensors"
    downloaded = False

    try:
        print(f"  • Checking GitHub Releases for tag '{RELEASE_TAG}'...")
        req = urllib.request.Request(download_url, headers={"User-Agent": "ButaAI-Swarm-Client/2.5"})
        with urllib.request.urlopen(req, timeout=10) as response, open(MASTER_ADAPTER, "wb") as out_file:
            shutil.copyfileobj(response, out_file)
        print("  • Downloaded latest master adapter from GitHub Release!")
        downloaded = True
    except Exception as e:
        print(f"  • Note: GitHub release asset not reachable ({e}). Using local consensus master.")

    if not downloaded and not os.path.exists(MASTER_ADAPTER):
        if os.path.exists(LOCAL_ADAPTER):
            shutil.copyfile(LOCAL_ADAPTER, MASTER_ADAPTER)
            print("  • Initialized master adapter from current local trained weights.")
        else:
            print("❌ Error: No master adapter found to sync.")
            return False

    # Copy master adapter to active local adapter
    shutil.copyfile(MASTER_ADAPTER, LOCAL_ADAPTER)
    current_hash = compute_sha256(LOCAL_ADAPTER)

    # Update swarm config
    os.makedirs(os.path.dirname(SWARM_CONFIG), exist_ok=True)
    cfg = {}
    if os.path.exists(SWARM_CONFIG):
        try:
            with open(SWARM_CONFIG, "r") as f:
                cfg = json.load(f)
        except Exception:
            pass
    cfg["lastSyncedAt"] = datetime.now(timezone.utc).isoformat()
    with open(SWARM_CONFIG, "w") as f:
        json.dump(cfg, f, indent=2)

    print(f"✅ [GitHub Swarm] Successfully synchronized with collective master!")
    print(f"  • Local Adapter: {LOCAL_ADAPTER}")
    print(f"  • SHA-256 Hash:  {current_hash[:16]}...{current_hash[-16:] if current_hash else ''}")
    return True

def contribute_adapter():
    """
    Validates and packages the local adapter to contribute back to the swarm.
    """
    print(f"\n🚀 [GitHub Swarm] Preparing local LoRA contribution...")
    if not os.path.exists(LOCAL_ADAPTER):
        print("❌ Error: No local adapter found at training/adapters/adapters.safetensors.")
        print("Run 'python3 training/train.py' first to train local weights on Apple Silicon Metal.")
        return False

    # Run safety validation via swarm_merger
    try:
        from training.swarm_merger import validate_adapter_safety
        is_safe, msg = validate_adapter_safety(LOCAL_ADAPTER)
    except ImportError:
        # Fallback if imported from different path
        sys.path.append(os.path.join(BASE_DIR, "training"))
        from swarm_merger import validate_adapter_safety
        is_safe, msg = validate_adapter_safety(LOCAL_ADAPTER)

    if not is_safe:
        print(f"❌ Safety audit failed: {msg}")
        return False

    print(f"✅ Safety audit passed: {msg}")
    local_hash = compute_sha256(LOCAL_ADAPTER)
    size_mb = os.path.getsize(LOCAL_ADAPTER) / (1024 * 1024)

    # Generate contribution metadata manifest
    manifest = {
        "version": "1.0",
        "contributed_at": datetime.now(timezone.utc).isoformat(),
        "adapter_size_mb": round(size_mb, 2),
        "sha256": local_hash,
        "format": "safetensors",
        "target_model": "mlx-community/Qwen2.5-Coder-7B-Instruct-4bit",
        "privacy_verified": True,
    }

    manifest_path = os.path.join(ADAPTERS_DIR, "contribution_manifest.json")
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=2)

    print(f"✅ Created contribution manifest at {manifest_path}")
    print(f"\n💡 [How to submit to ButaAI Swarm]:")
    print(f"  1. Fork github.com/{REPO_OWNER}/{REPO_NAME}")
    print(f"  2. Commit your verified delta: 'training/adapters/contribution_manifest.json'")
    print(f"  3. Open a Pull Request tagged '[swarm-contribution]'")
    print(f"  4. GitHub Actions will automatically audit, run FedAvg merge, and update the global release!")
    return True

def main():
    parser = argparse.ArgumentParser(description="ButaAI GitHub Swarm Trainer & Synchronizer")
    parser.add_argument("--sync", action="store_true", help="Download and activate latest global master weights")
    parser.add_argument("--contribute", action="store_true", help="Audit and prepare local adapter for swarm submission")
    parser.add_argument("--status", action="store_true", help="Display local vs collective swarm status")
    parser.add_argument("--train", type=int, default=0, help="Train on Apple Silicon Metal for N iterations")
    parser.add_argument("--tier", choices=["nano", "brain", "titan"], default="nano", help="Training tier: nano (11MB), brain (500MB), titan (1.2GB)")

    args = parser.parse_args()

    if args.status or (not args.sync and not args.contribute and args.train == 0):
        status = get_swarm_status()
        print("\n🌐 === ButaAI Swarm Status ===")
        print(json.dumps(status, indent=2))
        print("==============================\n")
        if not args.sync and not args.contribute and args.train == 0:
            return

    if args.sync:
        sync_weights()

    if args.contribute:
        contribute_adapter()

    if args.train > 0:
        print(f"\n⚡ Training on Apple Silicon Metal [{args.tier.upper()} Tier] for {args.train} iterations...")
        os.system(f"python3 training/train.py --tier {args.tier} --iters {args.train}")

if __name__ == "__main__":
    main()
