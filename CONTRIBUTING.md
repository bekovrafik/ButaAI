# Contributing to ButaAI 🚀

Thank you for your interest in contributing to **ButaAI**! We are building an open, on-device autonomous software engineering squad powered by decentralized swarm intelligence.

---

## 🌟 How You Can Contribute

1. **Autonomous Specialists**: Add new specialist roles or improve existing ones (`src/agents/specialists.ts`).
2. **LoRA Adapters & Swarm Weights**: Train specialized domain adapters (e.g. Kotlin Multiplatform, Swift, Rust, PostgreSQL) and submit them to `training/adapters/`.
3. **Synthetic Training Data**: Expand verified instruction pairs and DPO datasets in `training/data/`.
4. **Cockpit UI & Experience**: Improve the Flutter Web/Desktop interface in `app/`.
5. **Hardware Accelerators**: Optimize Metal, CUDA, and WebGPU compute pipelines.

---

## 🛠️ Development Setup

1. **Fork & Clone**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/ButaAI.git
   cd ButaAI
   ```
2. **Install Engine Dependencies**:
   ```bash
   npm install
   npm run build
   ```
3. **Launch the Gateway**:
   ```bash
   npm run server
   ```
4. **Run the Cockpit**:
   ```bash
   cd app
   flutter pub get
   flutter run -d chrome # Or macOS desktop
   ```

---

## 🐝 Submitting a LoRA Adapter to the Swarm

If you trained a custom LoRA adapter using `python3 training/train.py`:
1. Ensure your adapter passes validation evals with 90%+ pass rate.
2. Place the adapter weights or configuration in `training/adapters/<your_adapter_name>/`.
3. Open a Pull Request using the **LoRA Adapter Proposal** template.
4. Our automated CI evaluates parameter interference via TIES and merges qualified weights into the master model!

---

## 📜 Commit Conventions

We follow [Conventional Commits](https://www.conventionalcommits.org/):
* `feat(specialist)`: Add new specialist capabilities
* `fix(engine)`: Bug fixes in inference or tool execution
* `data(swarm)`: Contributions to training datasets or LoRA adapters
* `docs`: Documentation enhancements

Thank you for joining the ButaAI open-source movement!
