import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task_phase.dart';
import '../theme/buta_theme.dart';

enum ArtifactTab { preview, codeDiff, terminal }

class ArtifactsWorkspace extends StatefulWidget {
  final TaskPhase currentPhase;
  final Function(String objective, String action) onTriggerAction;

  const ArtifactsWorkspace({
    super.key,
    required this.currentPhase,
    required this.onTriggerAction,
  });

  @override
  State<ArtifactsWorkspace> createState() => _ArtifactsWorkspaceState();
}

class _ArtifactsWorkspaceState extends State<ArtifactsWorkspace> {
  ArtifactTab _activeTab = ArtifactTab.preview;
  String _selectedDevice = 'iPhone 16 Pro';
  String _selectedFile = 'habit_tracker_screen.dart';

  // Interactive mockup state
  final List<Map<String, dynamic>> _mockHabits = [
    {'title': 'Drink 2L Water', 'streak': 7, 'completed': true, 'color': ButaColors.secondary},
    {'title': 'Read 20 Mins', 'streak': 14, 'completed': true, 'color': ButaColors.primary},
    {'title': 'Morning Workout', 'streak': 3, 'completed': false, 'color': ButaColors.reviewer},
    {'title': 'Review PRs & Tests', 'streak': 5, 'completed': false, 'color': ButaColors.developer},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440,
      decoration: const BoxDecoration(
        color: ButaColors.surface,
        border: Border(
          left: BorderSide(color: ButaColors.surfaceBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Tab Bar (Claude Artifacts & Cursor Style)
          _buildWorkspaceTabBar(),

          // Active Workspace Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildActiveTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceTabBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: ButaColors.surface,
        border: Border(
          bottom: BorderSide(color: ButaColors.surfaceBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(
            tab: ArtifactTab.preview,
            icon: Icons.phone_iphone_rounded,
            label: 'Live Preview',
          ),
          const SizedBox(width: 4),
          _buildTabButton(
            tab: ArtifactTab.codeDiff,
            icon: Icons.code_rounded,
            label: 'Code & Diff',
          ),
          const SizedBox(width: 4),
          _buildTabButton(
            tab: ArtifactTab.terminal,
            icon: Icons.terminal_rounded,
            label: 'Terminal Logs',
          ),
          const Spacer(),
          // Phase Indicator Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ButaColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ButaColors.primary.withValues(alpha: 0.3)),
            ),
            child: Text(
              widget.currentPhase.displayName.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: ButaColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required ArtifactTab tab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _activeTab == tab;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _activeTab = tab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? ButaColors.surfaceLight : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: ButaColors.surfaceBorder)
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? ButaColors.secondary : ButaColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? ButaColors.textBright : ButaColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case ArtifactTab.preview:
        return _buildPreviewTab();
      case ArtifactTab.codeDiff:
        return _buildCodeDiffTab();
      case ArtifactTab.terminal:
        return _buildTerminalTab();
    }
  }

  // -------------------------------------------------------------
  // TAB 1: LIVE SIMULATOR PREVIEW
  // -------------------------------------------------------------
  Widget _buildPreviewTab() {
    return Column(
      key: const ValueKey('preview-tab'),
      children: [
        // Device Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.touch_app_outlined, size: 14, color: ButaColors.success),
                  const SizedBox(width: 6),
                  Text(
                    'Interactive CanvasKit Sim',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ButaColors.textMuted,
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: _selectedDevice,
                underline: const SizedBox(),
                dropdownColor: ButaColors.surfaceLight,
                style: const TextStyle(fontSize: 11, color: ButaColors.textBright),
                items: const [
                  DropdownMenuItem(value: 'iPhone 16 Pro', child: Text('iPhone 16 Pro')),
                  DropdownMenuItem(value: 'Pixel 9 Pro', child: Text('Pixel 9 Pro')),
                  DropdownMenuItem(value: 'iPad Air (M2)', child: Text('iPad Air')),
                  DropdownMenuItem(value: 'macOS Window', child: Text('macOS Window')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDevice = val);
                },
              ),
            ],
          ),
        ),

        const Divider(),

        // Device Frame
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              child: Container(
                width: 290,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(36),
                  border: Border.all(color: const Color(0xFF2C324B), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: ButaColors.primary.withValues(alpha: 0.2),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(33),
                  child: Column(
                    children: [
                      // Dynamic Island
                      Container(
                        height: 28,
                        color: Colors.black,
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161922),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      // Screen Content
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF0F172A), Color(0xFF020617)],
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'HabitStreak',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ButaColors.success.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'SQLITE READY',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: ButaColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Interactive Habit Items
                                ..._mockHabits.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _buildInteractiveHabitItem(
                                      title: item['title'],
                                      streak: '${item['streak']} Day Streak 🔥',
                                      completed: item['completed'],
                                      accentColor: item['color'],
                                      onToggle: () {
                                        setState(() {
                                          _mockHabits[idx]['completed'] = !_mockHabits[idx]['completed'];
                                          if (_mockHabits[idx]['completed']) {
                                            _mockHabits[idx]['streak'] += 1;
                                          } else {
                                            _mockHabits[idx]['streak'] -= 1;
                                          }
                                        });
                                      },
                                    ),
                                  );
                                }),

                                const SizedBox(height: 14),
                                Center(
                                  child: Text(
                                    'Built & tested with ButaAI TDD Suite\nZero Cloud Telemetry',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: ButaColors.textMuted.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Home Bar
                      Container(
                        height: 18,
                        color: Colors.black,
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const Divider(),

        // Bottom Executive Triggers
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildFastTrigger(
                icon: Icons.auto_awesome_rounded,
                label: '1. Plan & Architect Feature',
                color: ButaColors.architect,
                onTap: () => widget.onTriggerAction('Plan and architect offline Habit Streak feature with SQLite', 'plan'),
              ),
              const SizedBox(height: 6),
              _buildFastTrigger(
                icon: Icons.checklist_rounded,
                label: '2. Execute Failing TDD Suite',
                color: ButaColors.developer,
                onTap: () => widget.onTriggerAction('Formulate failing TDD test cases for Habit calculations', 'tdd'),
              ),
              const SizedBox(height: 6),
              _buildFastTrigger(
                icon: Icons.security_rounded,
                label: '3. Run Anti-Slop Security Review',
                color: ButaColors.reviewer,
                onTap: () => widget.onTriggerAction('Run adversarial code review for security & memory leaks', 'review'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveHabitItem({
    required String title,
    required String streak,
    required bool completed,
    required Color accentColor,
    required VoidCallback onToggle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: completed ? accentColor.withValues(alpha: 0.4) : const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: completed ? TextDecoration.lineThrough : null,
                      color: completed ? Colors.white70 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    streak,
                    style: TextStyle(
                      fontSize: 10,
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                size: 18,
                color: completed ? ButaColors.success : ButaColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: CODE & DIFF INSPECTOR (CURSOR / CLAUDE ARTIFACT STYLE)
  // -------------------------------------------------------------
  Widget _buildCodeDiffTab() {
    final codeSnippets = {
      'habit_tracker_screen.dart': '''// lib/screens/habit_tracker_screen.dart
import 'package:flutter/material.dart';
import '../repositories/habit_repository.dart';

class HabitTrackerScreen extends StatefulWidget {
  final HabitRepository repository;
  const HabitTrackerScreen({super.key, required this.repository});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
+ // [ECC Stage 3: Zero-slop implementation with SQLite persistence]
+ late final Future<List<Habit>> _habitsFuture;
+
+ @override
+ void initState() {
+   super.initState();
+   _habitsFuture = widget.repository.fetchHabits();
+ }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Habit Tracker')),
      body: FutureBuilder<List<Habit>>(
        future: _habitsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final habits = snapshot.data!;
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, i) => HabitTile(habit: habits[i]),
          );
        },
      ),
    );
  }
}''',
      'habit_streak_test.dart': '''// test/habit_streak_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:buta_app/models/habit.dart';

void main() {
  group('Habit Streak Calculation Tests [ECC Stage 2]', () {
+   test('Streak increments when completed consecutively', () {
+     final habit = Habit(id: '1', title: 'Code', streak: 4);
+     final updated = habit.markCompleted(DateTime.now());
+     expect(updated.streak, 5);
+     expect(updated.isCompletedToday, isTrue);
+   });
+
+   test('Streak resets if gap is greater than 36 hours', () {
+     final habit = Habit(id: '2', title: 'Gym', streak: 10);
+     final updated = habit.evaluateStreak(DateTime.now().add(const Duration(days: 2)));
+     expect(updated.streak, 0);
+   });
  });
}''',
      'pubspec.yaml': '''name: buta_habit_module
description: Offline-first Habit Tracker module
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
+ sqflite: ^2.3.3+1
+ path: ^1.9.0
+ riverpod: ^2.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
+ mockito: ^5.4.4
+ build_runner: ^2.4.9''',
    };

    final currentCode = codeSnippets[_selectedFile] ?? '// No code available';

    return Column(
      key: const ValueKey('codediff-tab'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // File Selector Tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: ButaColors.surfaceLight,
            border: Border(bottom: BorderSide(color: ButaColors.surfaceBorder)),
          ),
          child: Row(
            children: [
              _buildFileChip('habit_tracker_screen.dart'),
              const SizedBox(width: 8),
              _buildFileChip('habit_streak_test.dart'),
              const SizedBox(width: 8),
              _buildFileChip('pubspec.yaml'),
            ],
          ),
        ),

        // Action Toolbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ButaColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '+18 additions, 0 deletions',
                    style: TextStyle(fontSize: 11, color: ButaColors.success, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: currentCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copied to clipboard!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ButaColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ButaColors.surfaceBorder),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.copy_rounded, size: 12, color: ButaColors.textMuted),
                      SizedBox(width: 4),
                      Text('Copy', style: TextStyle(fontSize: 11, color: ButaColors.textBright)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Code Viewer with syntax formatting
        Expanded(
          child: Container(
            color: const Color(0xFF090B10),
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: SelectableText.rich(
                _formatCodeWithDiff(currentCode),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileChip(String fileName) {
    final isSelected = _selectedFile == fileName;
    return InkWell(
      onTap: () => setState(() => _selectedFile = fileName),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? ButaColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? ButaColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          fileName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? ButaColors.textBright : ButaColors.textMuted,
          ),
        ),
      ),
    );
  }

  TextSpan _formatCodeWithDiff(String code) {
    final lines = code.split('\n');
    List<TextSpan> spans = [];

    for (final line in lines) {
      if (line.startsWith('+')) {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(
              color: Color(0xFF4ADE80), // Emerald
              backgroundColor: Color(0x1810B981),
            ),
          ),
        );
      } else if (line.startsWith('-')) {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(
              color: Color(0xFFF87171), // Rose
              backgroundColor: Color(0x18EF4444),
            ),
          ),
        );
      } else if (line.trim().startsWith('//')) {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$line\n',
            style: const TextStyle(color: Color(0xFFCBD5E1)),
          ),
        );
      }
    }

    return TextSpan(children: spans);
  }

  // -------------------------------------------------------------
  // TAB 3: TERMINAL & BUILD LOGS (CURSOR / LINUX CONSOLE STYLE)
  // -------------------------------------------------------------
  Widget _buildTerminalTab() {
    const terminalLogs = r'''$ buta exec --phase=tdd --suite=streak_tests
[BUTA-ENGINE] Initializing Apple Silicon Metal GPU runtime (16GB unified RAM)...
[BUTA-ENGINE] Model loaded: buta-ai:latest (Qwen 2.5 Coder 7B + ECC system instructions)
[BUTA-COMPILER] Running: flutter test test/habit_streak_test.dart
00:00 +0: Habit Streak Calculation Tests [ECC Stage 2] Streak increments when completed consecutively
00:01 +1: Habit Streak Calculation Tests [ECC Stage 2] Streak resets if gap is greater than 36 hours
00:01 +2: All tests passed! [Exit 0]

[BUTA-VERIFY] Checking static analysis (dart analyze)...
No issues found! (took 0.8s)

[BUTA-SIMCTL] Connecting to iOS Simulator "iPhone 16 Pro" (booted)...
[BUTA-SIMCTL] Installing bundle: com.butalabs.butaCockpit
[BUTA-SIMCTL] Launching app process ID: 41829
[BUTA-SIMCTL] Screencap captured: .buta/artifacts/sim_shot_17922.png
[BUTA-MEM] Distilling lesson into .buta/memory/instincts.json
Done in 2.14s. Ready for operator review.''';

    return Container(
      key: const ValueKey('terminal-tab'),
      color: const Color(0xFF07090E),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ButaColors.developer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'zsh • Apple Silicon Metal Daemon',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: ButaColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ButaColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'EXIT 0',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ButaColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                terminalLogs,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  height: 1.5,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastTrigger({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
