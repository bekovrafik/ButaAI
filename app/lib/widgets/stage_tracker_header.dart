import 'package:flutter/material.dart';
import '../models/task_phase.dart';
import '../theme/buta_theme.dart';

class StageTrackerHeader extends StatelessWidget {
  final TaskPhase currentPhase;
  final bool isEngineOnline;
  final VoidCallback? onInstinctsTap;

  const StageTrackerHeader({
    super.key,
    required this.currentPhase,
    required this.isEngineOnline,
    this.onInstinctsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: ButaColors.surface,
        border: Border(
          bottom: BorderSide(color: ButaColors.surfaceBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Logo & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ButaColors.primary, ButaColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: ButaColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'ButaAI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ButaColors.textBright,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ButaColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ButaColors.primary.withOpacity(0.4)),
                        ),
                        child: const Text(
                          'COCKPIT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: ButaColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Autonomous AI Software Operator',
                    style: TextStyle(
                      fontSize: 11,
                      color: ButaColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 32),

          // 6-Stage Loop Pills (ECC Standard)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPhasePill(TaskPhase.planning, Icons.description_outlined),
                  _buildArrow(),
                  _buildPhasePill(TaskPhase.testDrivenDesign, Icons.fact_check_outlined),
                  _buildArrow(),
                  _buildPhasePill(TaskPhase.implementation, Icons.code_rounded),
                  _buildArrow(),
                  _buildPhasePill(TaskPhase.adversarialReview, Icons.rate_review_outlined),
                  _buildArrow(),
                  _buildPhasePill(TaskPhase.simulatorVerification, Icons.devices_rounded),
                  _buildArrow(),
                  _buildPhasePill(TaskPhase.memoryRetention, Icons.psychology_outlined),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Engine Status Badge (Zero Cloud Keys)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isEngineOnline 
                  ? ButaColors.success.withOpacity(0.12)
                  : ButaColors.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isEngineOnline
                    ? ButaColors.success.withOpacity(0.4)
                    : ButaColors.error.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEngineOnline ? ButaColors.success : ButaColors.error,
                    boxShadow: [
                      BoxShadow(
                        color: isEngineOnline
                            ? ButaColors.success.withOpacity(0.6)
                            : ButaColors.error.withOpacity(0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isEngineOnline ? 'Apple Silicon Metal (Local)' : 'Engine Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isEngineOnline ? ButaColors.success : ButaColors.error,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Instincts Button
          IconButton(
            icon: const Icon(Icons.psychology_rounded, color: ButaColors.secondary),
            tooltip: 'View Learned Instincts',
            onPressed: onInstinctsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildPhasePill(TaskPhase phase, IconData icon) {
    final isActive = currentPhase == phase;
    final isDone = currentPhase.index > phase.index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? ButaColors.primary.withValues(alpha: 0.2)
            : isDone
                ? ButaColors.success.withValues(alpha: 0.1)
                : ButaColors.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? ButaColors.primary
              : isDone
                  ? ButaColors.success.withValues(alpha: 0.4)
                  : ButaColors.surfaceBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : icon,
            size: 14,
            color: isActive
                ? ButaColors.primary
                : isDone
                    ? ButaColors.success
                    : ButaColors.textMuted,
          ),
          const SizedBox(width: 6),
          Text(
            phase.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? ButaColors.textBright
                  : isDone
                      ? ButaColors.success
                      : ButaColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: ButaColors.surfaceBorder,
      ),
    );
  }
}
