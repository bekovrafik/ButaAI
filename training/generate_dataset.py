#!/usr/bin/env python3
"""
ButaAI Synthetic Training Dataset Generator
Generates high-fidelity tool-calling and Clean Architecture trajectories
for training ButaAI locally on Apple Silicon Metal.
"""

import json
import os
import random

TRAINING_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(TRAINING_DIR, "data")
os.makedirs(DATA_DIR, exist_ok=True)

# 1. Tool Call Templates & Scenarios
SCENARIOS = [
    {
        "user": "Create a new Flutter habit tracking service using Riverpod 3.x NotifierProvider with unit tests.",
        "thought_1": "I need to design a clean domain model and a NotifierProvider for habits, avoiding the deprecated StateProvider.",
        "tool_call_1": {
            "name": "write_file",
            "arguments": {
                "path": "lib/features/habits/domain/habit.dart",
                "content": "class Habit {\n  final String id;\n  final String title;\n  final int streak;\n  final bool isCompletedToday;\n\n  const Habit({\n    required this.id,\n    required this.title,\n    this.streak = 0,\n    this.isCompletedToday = false,\n  });\n\n  Habit copyWith({int? streak, bool? isCompletedToday}) {\n    return Habit(\n      id: id,\n      title: title,\n      streak: streak ?? this.streak,\n      isCompletedToday: isCompletedToday ?? this.isCompletedToday,\n    );\n  }\n}\n"
            }
        },
        "tool_res_1": "Successfully wrote 380 characters to lib/features/habits/domain/habit.dart",
        "thought_2": "Now I will formulate the unit test suite before writing the notifier logic (TDD).",
        "tool_call_2": {
            "name": "write_file",
            "arguments": {
                "path": "test/features/habits/habit_notifier_test.dart",
                "content": "import 'package:flutter_test/flutter_test.dart';\nimport 'package:habit_app/features/habits/domain/habit.dart';\nimport 'package:habit_app/features/habits/presentation/habit_notifier.dart';\n\nvoid main() {\n  group('HabitNotifier', () {\n    test('initial state is empty list', () {\n      final notifier = HabitNotifier();\n      expect(notifier.build(), isEmpty);\n    });\n\n    test('addHabit appends a new habit', () {\n      final notifier = HabitNotifier();\n      notifier.addHabit('Morning Run');\n      expect(notifier.state.length, 1);\n      expect(notifier.state.first.title, 'Morning Run');\n    });\n  });\n}\n"
            }
        },
        "tool_res_2": "Successfully wrote 520 characters to test/features/habits/habit_notifier_test.dart",
        "thought_3": "Now implementing HabitNotifier using Riverpod 3.x Notifier<List<Habit>>.",
        "tool_call_3": {
            "name": "write_file",
            "arguments": {
                "path": "lib/features/habits/presentation/habit_notifier.dart",
                "content": "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../domain/habit.dart';\n\nclass HabitNotifier extends Notifier<List<Habit>> {\n  @override\n  List<Habit> build() => [];\n\n  void addHabit(String title) {\n    final habit = Habit(id: DateTime.now().toIso8601String(), title: title);\n    state = [...state, habit];\n  }\n\n  void toggleHabit(String id) {\n    state = state.map((h) {\n      if (h.id == id) {\n        return h.copyWith(\n          isCompletedToday: !h.isCompletedToday,\n          streak: !h.isCompletedToday ? h.streak + 1 : (h.streak > 0 ? h.streak - 1 : 0),\n        );\n      }\n      return h;\n    }).toList();\n  }\n}\n\nfinal habitProvider = NotifierProvider<HabitNotifier, List<Habit>>(HabitNotifier.new);\n"
            }
        },
        "tool_res_3": "Successfully wrote 740 characters to lib/features/habits/presentation/habit_notifier.dart",
        "thought_4": "Now running flutter test to verify the implementation passes cleanly.",
        "tool_call_4": {
            "name": "run_terminal_command",
            "arguments": {
                "command": "flutter test test/features/habits/habit_notifier_test.dart"
            }
        },
        "tool_res_4": "00:01 +2: All tests passed!",
        "final": "Created the Habit domain model, test suite, and Riverpod 3.x NotifierProvider. All tests executed and passed clean."
    },
    {
        "user": "Fix iOS Xcode code signing error: resource fork, Finder information, or similar detritus not allowed.",
        "thought_1": "This error occurs when macOS extended attributes and AppleDouble metadata attach to assets. I'll inspect and strip them cleanly.",
        "tool_call_1": {
            "name": "run_terminal_command",
            "arguments": {
                "command": "xattr -cr ios/"
            }
        },
        "tool_res_1": "(Command completed with no output)",
        "thought_2": "Now verifying that no hidden extended attributes remain in the ios directory.",
        "tool_call_2": {
            "name": "run_terminal_command",
            "arguments": {
                "command": "xattr -lr ios/"
            }
        },
        "tool_res_2": "(Command completed with no output)",
        "final": "Cleaned all AppleDouble resource fork and extended provenance metadata from the iOS directory using `xattr -cr`. Xcode codesigning can now proceed without detritus errors."
    },
    {
        "user": "Implement the Double-Bezel (Doppelrand) hardware-grade card design tokens in Flutter.",
        "thought_1": "Double-Bezel architecture requires an outer machined shell container and an inner pure core with concentric border radii and specular highlights.",
        "tool_call_1": {
            "name": "write_file",
            "arguments": {
                "path": "lib/core/theme/double_bezel_card.dart",
                "content": "import 'package:flutter/material.dart';\n\nclass DoubleBezelCard extends StatelessWidget {\n  final Widget child;\n  final double outerRadius;\n  final double shellPadding;\n\n  const DoubleBezelCard({\n    super.key,\n    required this.child,\n    this.outerRadius = 24.0,\n    this.shellPadding = 6.0,\n  });\n\n  @override\n  Widget build(BuildContext context) {\n    final innerRadius = outerRadius - shellPadding;\n    return Container(\n      padding: EdgeInsets.all(shellPadding),\n      decoration: BoxDecoration(\n        color: const Color(0xFFF1F5F9),\n        borderRadius: BorderRadius.circular(outerRadius),\n        border: Border.all(color: const Color(0xFFE2E8F0)),\n        boxShadow: [\n          BoxShadow(\n            color: Colors.black.withOpacity(0.04),\n            blurRadius: 14,\n            offset: const Offset(0, 4),\n          ),\n        ],\n      ),\n      child: Container(\n        padding: const EdgeInsets.all(16),\n        decoration: BoxDecoration(\n          color: Colors.white,\n          borderRadius: BorderRadius.circular(innerRadius),\n          border: Border.all(color: Colors.white),\n          boxShadow: [\n            BoxShadow(\n              color: Colors.black.withOpacity(0.02),\n              blurRadius: 6,\n              offset: const Offset(0, 2),\n            ),\n          ],\n        ),\n        child: child,\n      ),\n    );\n  }\n}\n"
            }
        },
        "tool_res_1": "Successfully wrote 1200 characters to lib/core/theme/double_bezel_card.dart",
        "thought_2": "Now verifying that dart analyze passes on the new design system component.",
        "tool_call_2": {
            "name": "run_terminal_command",
            "arguments": {
                "command": "dart analyze lib/core/theme/double_bezel_card.dart"
            }
        },
        "tool_res_2": "No issues found!",
        "final": "Engineered the Double-Bezel card architecture with outer porcelain shell (#F1F5F9) and inner core container with concentric border radius calculations."
    },
    {
        "user": "Run an adversarial code review on our latest staged git changes.",
        "thought_1": "I need to inspect the latest git diff to audit for security leaks, Riverpod 3.x compliance, and performance bottlenecks.",
        "tool_call_1": {
            "name": "run_terminal_command",
            "arguments": {
                "command": "git diff HEAD~1"
            }
        },
        "tool_res_1": "diff --git a/lib/main.dart b/lib/main.dart\n+ final userToken = 'sk_live_12345';\n+ final counter = StateProvider((ref) => 0);",
        "thought_2": "The diff contains critical issues: a hardcoded secret key and a deprecated Riverpod 2.x StateProvider.",
        "final": "### Adversarial Code Review: DO NOT SHIP 🛑\n\n1. **Critical Security**: Hardcoded live secret token `'sk_live_12345'` found in `lib/main.dart`. Must be moved to secure storage or environment variables.\n2. **Architecture Violation**: `StateProvider` is deprecated in Riverpod 3.x. Refactor to `NotifierProvider` with an explicit `Notifier` class.\n3. **Verdict**: BLOCKED until credentials are removed and NotifierProvider is adopted."
    },
    {
        "user": "Generate an ultra-modern app icon and vector shield logo for ButaAI with glowing emerald circuits.",
        "thought_1": "I will invoke `generate_image` with style `app_icon` to produce an on-device SVG and interactive HTML preview.",
        "tool_call_1": {
            "name": "generate_image",
            "arguments": {
                "prompt": "ButaAI emerald quantum shield with neural circuits, metallic bevel, and cybernetic core",
                "filename": "buta_quantum_shield",
                "style": "app_icon"
            }
        },
        "tool_res_1": "✅ Generated SVG image at .buta/artifacts/images/buta_quantum_shield.svg\nGenerated interactive preview at .buta/artifacts/images/buta_quantum_shield_preview.html",
        "final": "Crafted high-fidelity vector app icon and interactive preview with specular lighting, concentric beveled borders, and glowing SVG filters."
    },
    {
        "user": "Create a 60 FPS glowing pulse radar animation widget for Flutter to visualize active AI agent thinking.",
        "thought_1": "I will use `generate_animation` to synthesize a production Flutter CustomPainter widget with AnimationController and hardware-accelerated repainting.",
        "tool_call_1": {
            "name": "generate_animation",
            "arguments": {
                "prompt": "Concentric glowing cyan and indigo pulse radar rings with smooth cubic easing",
                "animationType": "flutter_motion",
                "filename": "agent_pulse_radar",
                "durationMs": 2200
            }
        },
        "tool_res_1": "✅ Generated Flutter animation widget at .buta/artifacts/animations/agent_pulse_radar.dart\nGenerated web animation at .buta/artifacts/animations/agent_pulse_radar.html",
        "final": "Created hardware-accelerated Flutter CustomPainter animation widget `AgentPulseRadar` and companion web preview."
    },
    {
        "user": "Create an 18-second kinetic product launch video for ButaAI showing the decentralised on-device swarm.",
        "thought_1": "I will invoke `generate_video_storyboard` to generate an 18s 5-scene launch package (Hook, Problem, Reveal, Proof, CTA) with JSON timeline, interactive canvas player, and FFmpeg render script.",
        "tool_call_1": {
            "name": "generate_video_storyboard",
            "arguments": {
                "title": "ButaAI: Sovereign On-Device Intelligence",
                "concept": "Decentralized Swarm LoRA on Apple Silicon Metal with Zero Cloud Fees",
                "filename": "buta_launch_18s"
            }
        },
        "tool_res_1": "✅ Generated 18-second kinetic video storyboard at .buta/artifacts/videos/buta_launch_18s_timeline.json\nGenerated interactive player at .buta/artifacts/videos/buta_launch_18s_player.html\nGenerated FFmpeg build script at .buta/artifacts/videos/buta_launch_18s_render.sh",
        "final": "Delivered full 18-second kinetic launch video storyboard with scene timing, kinetic motion cues, voiceover script, and automated FFmpeg render command."
    },
    {
        "user": "Synchronize local ButaAI weights with the latest GitHub Swarm Collective Release.",
        "thought_1": "I will run the swarm synchronization tool to download and cryptographically verify the master LoRA weights from GitHub.",
        "tool_call_1": {
            "name": "run_terminal_command",
            "arguments": {
                "command": "python3 training/github_trainer.py --sync"
            }
        },
        "tool_res_1": "✅ [GitHub Swarm] Synchronized master LoRA adapter (SHA-256: 7f83b... verified). Activated on Metal GPU.",
        "final": "Synchronized local Metal GPU engine with the collective master weights from GitHub Releases. Local intelligence has been updated with consensus weights."
    }
]

def generate_variations(base_scenarios, target_count=500):
    dataset = []
    modifiers = [
        ("coffee tasting journal", "CoffeeRecord", "brew timers"),
        ("fitness habit streak tracker", "WorkoutRecord", "calorie metrics"),
        ("real-time crypto ticker", "CryptoPrice", "websocket streams"),
        ("offline notes & markdown editor", "NoteDocument", "local SQLite storage"),
        ("ai prompt experimentation studio", "PromptExperiment", "token analytics"),
        ("inventory warehouse scanner", "InventoryItem", "barcode lookup"),
    ]

    for i in range(target_count):
        base = random.choice(base_scenarios)
        domain, entity, extra = random.choice(modifiers)

        # Build trajectory
        messages = [
            {"role": "system", "content": "You are ButaAI, the autonomous local AI software company operator. You use tools actively to inspect, write, test, and verify code."}
        ]

        if "coffee" in domain or "fitness" in domain:
            messages.append({"role": "user", "content": f"Build a {domain} with Clean Architecture, Riverpod 3.x, and {extra}."})
            messages.append({
                "role": "assistant",
                "content": f"I'll start by scaffolding the {entity} domain model and unit test suite.",
                "tool_calls": [{
                    "id": f"call_{i}_1",
                    "type": "function",
                    "function": {
                        "name": "write_file",
                        "arguments": json.dumps({"path": f"lib/features/{entity.lower()}/domain/{entity.lower()}.dart", "content": f"class {entity} {{\n  final String id;\n  final DateTime timestamp;\n  const {entity}({{required this.id, required this.timestamp}});\n}}\n"})
                    }
                }]
            })
            messages.append({
                "role": "tool",
                "name": "write_file",
                "content": f"Successfully wrote to lib/features/{entity.lower()}/domain/{entity.lower()}.dart"
            })
            messages.append({
                "role": "assistant",
                "content": "Now running dart analyze to verify null-safety and syntax.",
                "tool_calls": [{
                    "id": f"call_{i}_2",
                    "type": "function",
                    "function": {
                        "name": "run_terminal_command",
                        "arguments": json.dumps({"command": f"dart analyze lib/features/{entity.lower()}/"})
                    }
                }]
            })
            messages.append({
                "role": "tool",
                "name": "run_terminal_command",
                "content": "No issues found!"
            })
            messages.append({
                "role": "assistant",
                "content": f"Completed {domain} implementation with pure domain model and verified syntax."
            })
        else:
            # Use base scenario
            messages.append({"role": "user", "content": base["user"]})
            messages.append({
                "role": "assistant",
                "content": base["thought_1"],
                "tool_calls": [{
                    "id": f"call_{i}_1",
                    "type": "function",
                    "function": {
                        "name": base["tool_call_1"]["name"],
                        "arguments": json.dumps(base["tool_call_1"]["arguments"])
                    }
                }]
            })
            messages.append({
                "role": "tool",
                "name": base["tool_call_1"]["name"],
                "content": base["tool_res_1"]
            })
            if "tool_call_2" in base:
                messages.append({
                    "role": "assistant",
                    "content": base["thought_2"],
                    "tool_calls": [{
                        "id": f"call_{i}_2",
                        "type": "function",
                        "function": {
                            "name": base["tool_call_2"]["name"],
                            "arguments": json.dumps(base["tool_call_2"]["arguments"])
                        }
                    }]
                })
                messages.append({
                    "role": "tool",
                    "name": base["tool_call_2"]["name"],
                    "content": base["tool_res_2"]
                })
            messages.append({
                "role": "assistant",
                "content": base["final"]
            })

        dataset.append({"messages": messages})

    return dataset

print(f"Generating synthetic tool-calling dataset for ButaAI...")
all_data = generate_variations(SCENARIOS, target_count=400)
split_idx = int(len(all_data) * 0.9)
train_data = all_data[:split_idx]
valid_data = all_data[split_idx:]

train_path = os.path.join(DATA_DIR, "train.jsonl")
valid_path = os.path.join(DATA_DIR, "valid.jsonl")

with open(train_path, "w") as f:
    for item in train_data:
        f.write(json.dumps(item) + "\n")

with open(valid_path, "w") as f:
    for item in valid_data:
        f.write(json.dumps(item) + "\n")

print(f"✅ Generated {len(train_data)} training examples -> {train_path}")
print(f"✅ Generated {len(valid_data)} validation examples -> {valid_path}")
