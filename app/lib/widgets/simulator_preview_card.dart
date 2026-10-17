import 'package:flutter/material.dart';
import '../models/task_phase.dart';
import '../theme/buta_theme.dart';

class SimulatorPreviewCard extends StatefulWidget {
  final TaskPhase currentPhase;
  final Function(String objective, String action) onTriggerAction;

  const SimulatorPreviewCard({
    super.key,
    required this.currentPhase,
    required this.onTriggerAction,
  });

  @override
  State<SimulatorPreviewCard> createState() => _SimulatorPreviewCardState();
}

class _SimulatorPreviewCardState extends State<SimulatorPreviewCard> {
  String _selectedDevice = 'iPhone 16 Pro';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: const BoxDecoration(
        color: ButaColors.surface,
        border: Border(
          left: BorderSide(color: ButaColors.surfaceBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.developer_mode_rounded, size: 18, color: ButaColors.secondary),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Simulator & QA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ButaColors.textBright,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedDevice,
                  underline: const SizedBox(),
                  dropdownColor: ButaColors.surfaceLight,
                  style: const TextStyle(fontSize: 12, color: ButaColors.textBright),
                  items: const [
                    DropdownMenuItem(value: 'iPhone 16 Pro', child: Text('iPhone 16 Pro')),
                    DropdownMenuItem(value: 'Pixel 9', child: Text('Pixel 9')),
                    DropdownMenuItem(value: 'macOS Desktop', child: Text('macOS Desktop')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDevice = val);
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // Simulated Device Screen Mockup
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: ButaColors.surfaceBorder, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: ButaColors.primary.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Column(
                    children: [
                      // Notch / Dynamic Island
                      Container(
                        height: 24,
                        color: Colors.black,
                        child: Center(
                          child: Container(
                            width: 70,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E202A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      // Device Screen Content
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF0F172A), Color(0xFF020617)],
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'HabitStreak',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ButaColors.success.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ONLINE',
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
                                // Habit Card 1
                                _buildMockHabitItem(
                                  'Drink 2L Water',
                                  '7 Day Streak 🔥',
                                  true,
                                  ButaColors.secondary,
                                ),
                                const SizedBox(height: 10),
                                // Habit Card 2
                                _buildMockHabitItem(
                                  'Read 20 Mins',
                                  '14 Day Streak 🔥',
                                  true,
                                  ButaColors.primary,
                                ),
                                const SizedBox(height: 10),
                                // Habit Card 3
                                _buildMockHabitItem(
                                  'Morning Workout',
                                  'Today Pending',
                                  false,
                                  ButaColors.reviewer,
                                ),
                                const SizedBox(height: 16),
                                // Device Footer Info
                                Center(
                                  child: Text(
                                    'Rendered by ButaAI Flutter Engine\nsimctl screencap verified',
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

                      // Home indicator
                      Container(
                        height: 16,
                        color: Colors.black,
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
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

          const Divider(),

          // Fast Action Triggers
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'EXECUTIVE ACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: ButaColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                _buildActionButton(
                  icon: Icons.assignment_outlined,
                  label: 'Generate PRD Blueprint',
                  color: ButaColors.primary,
                  onTap: () => widget.onTriggerAction('Plan and architect offline Habit Streak feature', 'plan'),
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: Icons.security_rounded,
                  label: 'Run Adversarial Review',
                  color: ButaColors.reviewer,
                  onTap: () => widget.onTriggerAction('Run adversarial code review for security & memory leaks', 'review'),
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: Icons.checklist_rounded,
                  label: 'Execute TDD Test Suite',
                  color: ButaColors.developer,
                  onTap: () => widget.onTriggerAction('Formulate and execute TDD test cases', 'tdd'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockHabitItem(String title, String streak, bool completed, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                streak,
                style: TextStyle(
                  fontSize: 9,
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: completed ? ButaColors.success : ButaColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
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
