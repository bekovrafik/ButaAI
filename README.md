# ButaAI 🚀
### Autonomous AI Software Company Operator (ECC-Powered)

> **Mission**: An autonomous, self-directed AI software company operator that receives a business objective, researches opportunities, designs the product architecture, creates the application (Flutter, Web, Node), tests on real simulators, conducts adversarial reviews, and stages releases under human executive oversight.

Built with **TypeScript / Node.js**, incorporating the battle-tested engineering rigor, memory persistence, safety gates, and multi-agent hierarchy of **ECC (Everything Claude Code)**.

---

## 🏛️ System Topology

```
                         HUMAN OWNER (CHAIRMAN)
                                   │
                          ┌────────▼────────┐
                          │   EXECUTIVE AI  │
                          │   (CEO / CTO)   │
                          └────────┬────────┘
                                   │
                        ┌──────────┴──────────┐
                        │                     │
                 DECISION ENGINE         MEMORY ENGINE
                  (GateGuard)           (ContextKeeper)
                        │                     │
                        └──────────┬──────────┘
                                   │
                            AGENT ORCHESTRATOR
                                   │
          ┌────────────────────────┼────────────────────────┐
          │                        │                        │
       RESEARCH                 PRODUCT                ENGINEERING
    (Market Scout)           (PRD Architect)                │
                                                     ┌──────┼──────┐
                                                     │      │      │
                                                    DEV   REVIEW   QA
                                                     │      │      │
                                                     └──────┴──────┘
                                                            │
                                                     DELIVERY ENGINE
                                                            │
                                              Fastlane / Store Staging
```

---

## 🔄 The 6-Stage Autonomous Engineering Loop

Inspired by ECC's loop (`Plan ➔ Test ➔ Implement ➔ Review ➔ Verify ➔ Remember`):

1. **Plan & PRD**: Decomposes high-level objectives into unambiguous user stories, acceptance criteria, and architecture blueprints.
2. **Test-First (TDD)**: Formulates failing tests first before touching implementation code.
3. **Incremental Implementation**: Produces minimal, self-contained diffs designed to turn test suites green.
4. **Adversarial Review**: Code Reviewer and AgentShield perform security, memory-leak, performance, and anti-slop audits.
5. **Simulator Verification**: Boots device simulators (`xcrun simctl` / `adb`), runs the app, and captures screenshots as proof.
6. **Remember & Evolve**: ContextKeeper captures session snapshots, records Architectural Decision Records (ADRs), and permanently logs learned instincts.

---

## 🛡️ GateGuard & Safety Permissions

| Action | Execution Mode | Safety Guardrail |
| :--- | :--- | :--- |
| Read/Write Workspace | `Autonomous` | Scoped to active repository |
| Destructive (`rm -rf`, `DROP TABLE`, `git reset --hard`) | **BLOCKED** | Explicit human sign-off required |
| Simulator Automation (`simctl`, `adb`, screencap) | `Autonomous` | Headless execution |
| App Store / Play Store Live Release | **APPROVAL** | Staged in Fastlane, human confirms push |
| Real Payments / Credit Card Operations | **FROZEN** | Hard-coded freeze (never executed by AI) |

---

## 💻 CLI Quickstart

### Installation & Setup

```bash
cd ~/Butalabs/ButaAI
npm install
npm run build
npm link # Optional: make 'buta' command available globally
```

### Commands

#### 1. Run Autonomous End-to-End Cycle
```bash
buta run "Build an interactive Habit Streak tracker with local caching" --framework flutter
```

#### 2. Plan a Product Feature (PRD & Architecture)
```bash
buta plan "Add Stripe and RevenueCat in-app subscription flow"
```

#### 3. Run Adversarial Code & Security Review
```bash
buta review
```

#### 4. Inspect Project Memory & Instincts
```bash
buta status
```

#### 5. Teach a Permanent Engineering Rule
```bash
buta instinct "Flutter Riverpod" "Use NotifierProvider instead of StateProvider in 3.x"
```

---

## 🧠 100% Local Private AI Engine (Zero Cloud API Keys)

**ButaAI** runs completely private and offline on your machine (optimized for Apple Silicon Metal on Mac M2/M3/M4). It requires **zero cloud API keys** (no Gemini, OpenAI, or Anthropic keys needed).

### How It Works:
1. **Local Model (`buta-ai`)**: Built from the high-performance `qwen2.5-coder:7b` base model with ButaAI's custom ECC engineering principles baked into the `Modelfile`.
2. **Apple Silicon Hardware Acceleration**: Uses Metal/MLX via Ollama at `http://localhost:11434` for rapid, zero-latency code generation and reasoning.
3. **Complete Privacy**: Your code, git commits, simulator tests, and architectural plans never leave your machine.

```bash
# Check available local models
ollama list

# Create or re-build the ButaAI local brain
ollama create buta-ai -f Modelfile
```

---

## 🖥️ ButaAI Cockpit: Mac, Windows & Web Application

ButaAI includes a unified, responsive **Flutter Cockpit** for macOS, Windows, and Web browsers, featuring the **Agent War Room**, 6-stage lifecycle visualizer, live simulator preview, and instinct manager.

```
app/
├── lib/
│   ├── main.dart                      # Cockpit entrypoint
│   ├── screens/cockpit_home_screen.dart # Interactive War Room
│   ├── services/buta_local_service.dart# Direct connection to local buta-ai
│   ├── widgets/stage_tracker_header.dart # 6-stage ECC lifecycle bar
│   ├── widgets/simulator_preview_card.dart # Simulated device & actions
│   └── widgets/instincts_sheet.dart    # Learned instincts manager
├── macos/                             # Native macOS desktop app
├── windows/                           # Native Windows desktop app (.exe)
└── web/                               # Browser web application (Wasm/CanvasKit)
```

### Running the Cockpit:

#### 1. Native macOS App
```bash
cd app
flutter run -d macos
```

#### 2. Web Application (Chrome/Safari)
```bash
cd app
flutter run -d chrome
```

#### 3. Windows Native Desktop App (Run on Windows)
```bash
cd app
flutter run -d windows
# Or create release bundle:
flutter build windows
```

---

## 📂 Project Structure

- `bin/buta.ts`: Unified command-line interface.
- `app/`: Flutter desktop & web application for Mac, Windows, and Web.
- `src/core/engine.ts`: Autonomous software lifecycle orchestrator.
- `src/core/guardrail.ts`: GateGuard safety matrix & fact-forcing validator.
- `src/agents/specialists.ts`: CEO, Product, Architect, Developer, Reviewer, and QA personas.
- `src/memory/context-keeper.ts`: Persistent memory, instincts, and ADR ledger.
- `src/tools/index.ts`: Sandboxed filesystem, terminal, and simulator automation tools.
- `src/providers/provider-factory.ts`: Multi-model LLM abstraction.

