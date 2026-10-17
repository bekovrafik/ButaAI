import 'dart:async';
import 'package:flutter/material.dart';
import '../models/agent_message.dart';
import '../models/instinct.dart';
import '../models/task_phase.dart';
import '../services/buta_local_service.dart';
import '../theme/buta_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/simulator_preview_card.dart';
import '../widgets/stage_tracker_header.dart';
import '../widgets/instincts_sheet.dart';

class CockpitHomeScreen extends StatefulWidget {
  const CockpitHomeScreen({super.key});

  @override
  State<CockpitHomeScreen> createState() => _CockpitHomeScreenState();
}

class _CockpitHomeScreenState extends State<CockpitHomeScreen> {
  final ButaLocalService _localService = ButaLocalService();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isEngineOnline = false;
  TaskPhase _currentPhase = TaskPhase.idle;
  AgentRole _selectedRole = AgentRole.ceo;
  bool _isGenerating = false;

  final List<AgentMessage> _messages = [];
  final List<LearnedInstinct> _instincts = [
    LearnedInstinct(
      id: 'ins-001',
      trigger: 'Flutter Riverpod',
      rule: 'Migrate from StateProvider to NotifierProvider in Riverpod 3.x with explicit mutations',
      confidence: 0.85,
      learnedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    LearnedInstinct(
      id: 'ins-002',
      trigger: 'Clean Architecture',
      rule: 'UI layer must never import Data sources directly. Mediate via Domain Repository interfaces.',
      confidence: 0.95,
      learnedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    LearnedInstinct(
      id: 'ins-003',
      trigger: 'GateGuard Safety',
      rule: 'Never execute rm -rf, DROP TABLE, or live store releases without explicit confirmation.',
      confidence: 1.0,
      learnedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkEngineHealth();
    _addInitialWelcomeMessage();
  }

  Future<void> _checkEngineHealth() async {
    final online = await _localService.isEngineOnline();
    if (mounted) {
      setState(() => _isEngineOnline = online);
    }
  }

  void _addInitialWelcomeMessage() {
    _messages.add(
      AgentMessage(
        id: 'msg-init',
        role: AgentRole.ceo,
        content: 'Welcome to the ButaAI Cockpit. I am your autonomous AI software company operator. All models and processes run 100% locally on your Apple Silicon Mac M2 with zero external API keys.\n\nWhat product objective or architectural feature would you like to build today?',
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _handleSendMessage({String? overridePrompt, AgentRole? overrideRole}) async {
    final text = overridePrompt ?? _promptController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    final targetRole = overrideRole ?? _selectedRole;

    if (overridePrompt == null) {
      _promptController.clear();
    }

    // 1. Append User Message
    final userMsg = AgentMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      role: AgentRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isGenerating = true;
      _currentPhase = TaskPhase.planning;
    });

    _scrollToBottom();

    // 2. Prepare Placeholder for Streaming Response
    final botMsgId = 'bot-${DateTime.now().millisecondsSinceEpoch}';
    final botMsg = AgentMessage(
      id: botMsgId,
      role: targetRole,
      content: '',
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    setState(() {
      _messages.add(botMsg);
    });

    _scrollToBottom();

    // 3. Stream completion from local Ollama/buta-ai model
    StringBuffer buffer = StringBuffer();
    try {
      await for (final chunk in _localService.generateStream(
        prompt: text,
        role: targetRole,
      )) {
        buffer.write(chunk);
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m.id == botMsgId);
            if (idx != -1) {
              _messages[idx] = _messages[idx].copyWith(
                content: buffer.toString(),
                isStreaming: true,
              );
            }
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      buffer.write('\n[Error streaming response: $e]');
    }

    if (mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == botMsgId);
        if (idx != -1) {
          _messages[idx] = _messages[idx].copyWith(
            content: buffer.toString(),
            isStreaming: false,
          );
        }
        _isGenerating = false;
        _currentPhase = TaskPhase.testDrivenDesign;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showInstinctsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => InstinctsSheet(
        instincts: _instincts,
        onAddInstinct: (trigger, rule) {
          setState(() {
            _instincts.add(
              LearnedInstinct(
                id: 'ins-${DateTime.now().millisecondsSinceEpoch}',
                trigger: trigger,
                rule: rule,
                confidence: 0.9,
                learnedAt: DateTime.now(),
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Stage Tracker Header
            StageTrackerHeader(
              currentPhase: _currentPhase,
              isEngineOnline: _isEngineOnline,
              onInstinctsTap: _showInstinctsModal,
            ),

            // Main Cockpit Body
            Expanded(
              child: Row(
                children: [
                  // Center: War Room Messages & Input
                  Expanded(
                    child: Column(
                      children: [
                        // Messages Stream
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return MessageBubble(message: _messages[index]);
                            },
                          ),
                        ),

                        // Quick Suggestion Chips
                        _buildQuickSuggestions(),

                        // Interactive Prompt Input Bar
                        _buildInputBar(),
                      ],
                    ),
                  ),

                  // Right Dock: Simulator & Quick Actions (shown on wide screens)
                  if (MediaQuery.of(context).size.width >= 860)
                    SimulatorPreviewCard(
                      currentPhase: _currentPhase,
                      onTriggerAction: (objective, action) {
                        AgentRole targetRole = AgentRole.ceo;
                        if (action == 'plan') targetRole = AgentRole.productArchitect;
                        if (action == 'review') targetRole = AgentRole.codeReviewer;
                        if (action == 'tdd') targetRole = AgentRole.developer;

                        _handleSendMessage(
                          overridePrompt: objective,
                          overrideRole: targetRole,
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('🎯 Plan Habit Tracker with SQLite', () {
              _handleSendMessage(
                overridePrompt: 'Plan and formulate PRD for an offline Habit Tracker with SQLite local persistence in Flutter',
                overrideRole: AgentRole.productArchitect,
              );
            }),
            const SizedBox(width: 8),
            _buildChip('🛡️ Run Anti-Slop & Security Review', () {
              _handleSendMessage(
                overridePrompt: 'Conduct an adversarial code and security review of our habit tracking repository',
                overrideRole: AgentRole.codeReviewer,
              );
            }),
            const SizedBox(width: 8),
            _buildChip('🧪 Formulate TDD Test Suite', () {
              _handleSendMessage(
                overridePrompt: 'Write failing widget and unit test suite for habit streak calculations',
                overrideRole: AgentRole.developer,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ButaColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ButaColors.surfaceBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: ButaColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: ButaColors.surface,
        border: Border(
          top: BorderSide(color: ButaColors.surfaceBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Specialist Role Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: ButaColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ButaColors.surfaceBorder),
            ),
            child: DropdownButton<AgentRole>(
              value: _selectedRole,
              underline: const SizedBox(),
              dropdownColor: ButaColors.surfaceLight,
              style: const TextStyle(fontSize: 12, color: ButaColors.textBright),
              items: const [
                DropdownMenuItem(value: AgentRole.ceo, child: Text('👔 CEO')),
                DropdownMenuItem(value: AgentRole.productArchitect, child: Text('📐 Product')),
                DropdownMenuItem(value: AgentRole.systemArchitect, child: Text('🏗️ Architect')),
                DropdownMenuItem(value: AgentRole.developer, child: Text('💻 TDD Dev')),
                DropdownMenuItem(value: AgentRole.codeReviewer, child: Text('🛡️ Reviewer')),
                DropdownMenuItem(value: AgentRole.qaSimulator, child: Text('📱 QA Sim')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
          ),

          const SizedBox(width: 12),

          // Text Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ButaColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ButaColors.surfaceBorder),
              ),
              child: TextField(
                controller: _promptController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Direct the ButaAI squad (e.g., "Build an offline Habit streak widget in Flutter")...',
                  hintStyle: TextStyle(color: ButaColors.textMuted, fontSize: 13),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Send Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ButaColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            onPressed: _isGenerating ? null : () => _handleSendMessage(),
            child: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
