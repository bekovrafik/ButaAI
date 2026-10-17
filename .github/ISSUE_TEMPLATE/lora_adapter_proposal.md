---
name: LoRA Adapter / Swarm Contribution
about: Propose a community LoRA adapter to merge into the collective ButaAI model
title: '[ADAPTER] '
labels: lora-swarm
assignees: ''
---

**Adapter Details**
* Domain / Role: [e.g. Flutter Advanced Animations, SQLite High-Perf Indexes, Riverpod AsyncNotifier]
* Base Model: [e.g. Qwen2.5-Coder-7B-Instruct / buta-ai:latest]
* LoRA Rank (r): [e.g. 16]
* LoRA Alpha: [e.g. 32]
* Training Epochs / Steps: [e.g. 100 steps]

**Validation & Eval Pass Rate**
* Test Suite Passed: [e.g. 100% on 50 unit test prompts]
* Benchmark Score (before vs after): [e.g. 78% -> 96%]
* Parameter Hash: `sha256:...`

**Checklist**
- [ ] Adapter weights trained on verified unit-tested code
- [ ] Zero private or proprietary data included
- [ ] Ready for TIES-merging eval via `swarm_merger.py`
