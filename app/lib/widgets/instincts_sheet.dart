import 'package:flutter/material.dart';
import '../models/instinct.dart';
import '../theme/buta_theme.dart';

class InstinctsSheet extends StatelessWidget {
  final List<LearnedInstinct> instincts;
  final Function(String trigger, String rule) onAddInstinct;

  const InstinctsSheet({
    super.key,
    required this.instincts,
    required this.onAddInstinct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: ButaColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology_rounded, color: ButaColors.secondary),
                  SizedBox(width: 10),
                  Text(
                    'Learned Instincts & Permanent Rules',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ButaColors.textBright,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: ButaColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Rules automatically remembered by ContextKeeper without model retraining.',
            style: TextStyle(fontSize: 12, color: ButaColors.textMuted),
          ),
          const SizedBox(height: 20),

          // Instincts List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: instincts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final inst = instincts[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ButaColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ButaColors.surfaceBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ButaColors.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              inst.trigger,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ButaColors.secondary,
                              ),
                            ),
                          ),
                          Text(
                            'Confidence: ${(inst.confidence * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: ButaColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        inst.rule,
                        style: const TextStyle(
                          fontSize: 13,
                          color: ButaColors.textBright,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Add Instinct Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ButaColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Teach New Permanent Instinct'),
            onPressed: () {
              _showAddDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final triggerController = TextEditingController();
    final ruleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ButaColors.surface,
        title: const Text('Teach ButaAI an Instinct', style: TextStyle(color: ButaColors.textBright)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: triggerController,
              decoration: const InputDecoration(
                labelText: 'Trigger Keyword (e.g. Flutter Riverpod, SQLite)',
                labelStyle: TextStyle(color: ButaColors.textMuted),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ruleController,
              decoration: const InputDecoration(
                labelText: 'Learned Rule / Architecture Pattern',
                labelStyle: TextStyle(color: ButaColors.textMuted),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: ButaColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ButaColors.primary),
            onPressed: () {
              if (triggerController.text.isNotEmpty && ruleController.text.isNotEmpty) {
                onAddInstinct(triggerController.text, ruleController.text);
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('Save Instinct'),
          ),
        ],
      ),
    );
  }
}
