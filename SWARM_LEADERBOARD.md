# 🏆 ButaAI Collective Swarm - Node Leaderboard

> **Decentralized FedAvg Consensus Rankings**  
> *Last Merged Epoch: 2026-10-17 21:32:06 UTC*

---

## 📊 Network Telemetry
* **Active Swarm Nodes**: `1,433`
* **Total Federated LoRA Merges**: `5,349`
* **Consensus Global Loss**: `1.12`
* **Release Artifact**: [`swarm-weights-latest`](https://github.com/bekovrafik/ButaAI/releases/tag/swarm-weights-latest)

---

## 🌟 Top Swarm Node Attestations

| Rank | Node ID | Intelligence Tier | Merged PRs | Mean Loss | Recognition Badge |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **#1** | `node-d7a7cc69` | **Titan (1.2GB)** | `42` | `1.09` | 🛡️ Genesis Leader |
| **#2** | `node-a4f21e88` | **Brain (500MB)** | `31` | `1.14` | 🛡️ Verified Contributor |
| **#3** | `node-f9b33c10` | **Brain (500MB)** | `28` | `1.16` | 🛡️ Verified Contributor |
| **#4** | `node-8e019a2b` | **Nano (11MB)** | `19` | `1.21` | 🛡️ Edge Node |
| **#5** | `node-3c77d401` | **Nano (11MB)** | `15` | `1.24` | 🛡️ Edge Node |

---

## 🚀 How to Climb the Leaderboard
1. Train a local delta adapter on your Apple Silicon Mac:
   ```bash
   python3 training/github_trainer.py --train 100 --tier brain
   ```
2. Validate and package your contribution:
   ```bash
   python3 training/github_trainer.py --contribute
   ```
3. Submit your PR on GitHub! Every merged consensus epoch updates your rank.
