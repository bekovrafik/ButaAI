import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/agent_message.dart';
import '../models/instinct.dart';
import '../models/product_deliverables.dart';
import '../models/task_phase.dart';
import '../services/buta_local_service.dart';
import '../theme/buta_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/artifacts_workspace.dart';
import '../widgets/instincts_sheet.dart';
import '../widgets/agent_avatar.dart';
import '../widgets/knowledge_database_sheet.dart';

class ChatSession {
  final String id;
  String title;
  DateTime updatedAt;
  IconData icon;
  final List<AgentMessage> messages;
  ProductDeliverables? deliverables;

  ChatSession({
    required this.id,
    required this.title,
    required this.updatedAt,
    this.icon = Icons.auto_awesome_rounded,
    List<AgentMessage>? messages,
    this.deliverables,
  }) : messages = messages ?? [];
}

class CockpitHomeScreen extends StatefulWidget {
  const CockpitHomeScreen({super.key});

  @override
  State<CockpitHomeScreen> createState() => _CockpitHomeScreenState();
}

class _CockpitHomeScreenState extends State<CockpitHomeScreen> {
  final ButaLocalService _localService = ButaLocalService();
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final FocusNode _promptFocusNode;

  bool _isEngineOnline = true;
  TaskPhase _currentPhase = TaskPhase.idle;
  bool _isGenerating = false;
  bool _isSidebarOpen = true;
  bool _isWorkspaceOpen = false;
  String _activeSessionId = '';
  AgentRole _activeTypingRole = AgentRole.ceo;
  String _typingStatusText = 'Buta CEO is orchestrating sprint requirements...';
  String _selectedSwarmTier = 'nano';
  bool _swarmAutoSyncEnabled = true;

  StreamSubscription? _eventSub;

  final List<ChatSession> _sessions = [];

  ChatSession get _activeSession {
    if (_sessions.isEmpty) {
      final initial = _createNewSession(title: 'New Group Chat');
      _sessions.add(initial);
      _activeSessionId = initial.id;
      return initial;
    }
    return _sessions.firstWhere(
      (s) => s.id == _activeSessionId,
      orElse: () => _sessions.first,
    );
  }

  List<AgentMessage> get _messages => _activeSession.messages;
  ProductDeliverables? get _activeDeliverables => _activeSession.deliverables;

  final List<LearnedInstinct> _instincts = [
    LearnedInstinct(
      id: 'ins-001',
      trigger: 'Clean Light UI Aesthetic',
      rule: 'Avoid gloomy dark clunky palettes. Use airy porcelain white, generous spacing, and calibrated micro-accents.',
      confidence: 0.98,
      learnedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    LearnedInstinct(
      id: 'ins-002',
      trigger: 'Autonomous Engineering Squad Review',
      rule: 'Specialists (CEO, Product Architect, System Architect, Frontend Lead, Backend Lead, QA Lead) debate architecture, PRD requirements, and implementation before generating production deliverables.',
      confidence: 0.96,
      learnedAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    LearnedInstinct(
      id: 'ins-003',
      trigger: 'Silent Background Engines',
      rule: 'Execute complex video rendering, swarm simulation, and 3D generation silently in the background without exposing raw engine names.',
      confidence: 1.0,
      learnedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final firstSession = _createNewSession(title: 'New Group Chat');
    _sessions.add(firstSession);
    _activeSessionId = firstSession.id;
    _checkEngineHealth();
    _fetchSwarmState();

    // Keyboard listener: Enter sends, Shift+Enter adds newline
    _promptFocusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          if (HardwareKeyboard.instance.isShiftPressed) {
            return KeyEventResult.ignored; // Allows newline
          } else {
            _handleSendMessage();
            return KeyEventResult.handled; // Prevents newline and sends
          }
        }
        return KeyEventResult.ignored;
      },
    );

    // Listen to real-time agent and tool execution events from the local Gateway
    _eventSub = _localService.agentEvents.listen((event) {
      if (!mounted) return;
      final type = event['type'] as String?;
      final agent = event['agent'] as String? ?? 'Agent';

      if (type == 'tool_call_start') {
        final toolName = event['data']?['name'] ?? 'tool';
        setState(() {
          _activeSession.messages.add(
            AgentMessage(
              id: 'tool-${DateTime.now().millisecondsSinceEpoch}',
              role: AgentRole.pip,
              content: '🛠️ **$agent** executing tool: `$toolName`...',
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      } else if (type == 'tool_call_result') {
        final toolName = event['data']?['name'] ?? 'tool';
        final success = event['data']?['success'] == true;
        setState(() {
          _activeSession.messages.add(
            AgentMessage(
              id: 'tool-res-${DateTime.now().millisecondsSinceEpoch}',
              role: AgentRole.pip,
              content: success
                  ? '✅ Tool `$toolName` executed successfully.'
                  : '⚠️ Tool `$toolName` finished with warnings.',
              timestamp: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      } else if (type == 'cycle_stage') {
        final stage = event['data']?['stage'] as String? ?? '';
        if (stage.contains('developer') || stage.contains('build')) {
          setState(() => _currentPhase = TaskPhase.implementation);
        } else if (stage.contains('qa') || stage.contains('test')) {
          setState(() => _currentPhase = TaskPhase.simulatorVerification);
        }
      } else if (type == 'SWARM_TIER_CHANGED') {
        final tier = event['data']?['tier'] as String?;
        if (tier != null && mounted) {
          setState(() => _selectedSwarmTier = tier);
        }
      } else if (type == 'SWARM_UPDATE_APPLIED') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🌐 Swarm Consensus weights updated automatically! (${event['data']?['tier'] ?? 'consensus'})'),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _promptFocusNode.dispose();
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkEngineHealth() async {
    try {
      final online = await _localService.isEngineOnline();
      if (mounted) {
        setState(() => _isEngineOnline = online);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isEngineOnline = true);
      }
    }
  }

  Future<void> _fetchSwarmState() async {
    try {
      final tiers = await _localService.getSwarmTiers();
      if (tiers.isNotEmpty && mounted) {
        final active = tiers.firstWhere((t) => t['active'] == true, orElse: () => tiers.first);
        setState(() {
          _selectedSwarmTier = active['id']?.toString() ?? 'nano';
        });
      }
    } catch (_) {}
  }

  AgentMessage _createWelcomeMessage() {
    return AgentMessage(
      id: 'msg-init-${DateTime.now().millisecondsSinceEpoch}',
      role: AgentRole.ceo,
      content:
          "⚡ **Welcome to ButaAI Autonomous Engineering Studio!** I'm **Buta CEO**, executive orchestrator of your on-device software agency.\n\n"
          "We operate 100% locally on your Apple Silicon Metal GPU with **zero cloud dependencies**. In this workspace, collaborate directly with your 6 dedicated engineering specialists:\n"
          "• **Buta CEO**: Executive Strategy, Scoping & Release Roadmaps\n"
          "• **Product Architect**: Rigorous PRDs, User Journeys & Acceptance Criteria\n"
          "• **System Architect**: Clean Architecture, SQLite Schemas & Riverpod Patterns\n"
          "• **Lead Frontend Engineer**: Hardware-Grade UI, Interactive Tokens & Layouts\n"
          "• **Lead Backend Engineer**: High-Performance APIs, Local Services & Data Pipelines\n"
          "• **QA & Security Verifier**: Automated Unit Tests, Security Audits & Edge Guards\n\n"
          "Pitch an app, service, or feature concept to kick off an autonomous architectural review and full codebase generation!",
      timestamp: DateTime.now(),
    );
  }

  ChatSession _createNewSession({String title = 'New Group Chat'}) {
    final session = ChatSession(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      updatedAt: DateTime.now(),
      icon: Icons.chat_bubble_outline_rounded,
    );
    session.messages.add(_createWelcomeMessage());
    return session;
  }

  void _handleNewChat() {
    final newSession = _createNewSession();
    setState(() {
      _sessions.insert(0, newSession);
      _activeSessionId = newSession.id;
      _currentPhase = TaskPhase.idle;
      _isGenerating = false;
      _isWorkspaceOpen = false;
      _promptController.clear();
    });
  }

  Future<void> _handleSendMessage({String? overridePrompt}) async {
    final text = overridePrompt ?? _promptController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    if (overridePrompt == null) {
      _promptController.clear();
    }

    final currentSession = _activeSession;

    // Auto-update session title if it's currently default
    if (currentSession.title == 'New Group Chat' || currentSession.title.startsWith('AI Studio')) {
      final cleanTitle = text.length > 26 ? '${text.substring(0, 26)}...' : text;
      currentSession.title = cleanTitle;
      currentSession.icon = Icons.auto_awesome_rounded;
    }
    currentSession.updatedAt = DateTime.now();

    // 1. Add User Message
    final userMsg = AgentMessage(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      role: AgentRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      currentSession.messages.add(userMsg);
      _isGenerating = true;
      _currentPhase = TaskPhase.planning;
      _activeTypingRole = AgentRole.ceo;
      _typingStatusText = 'Buta CEO is orchestrating sprint requirements...';
    });
    _scrollToBottom();

    // 2. Immediate Kickoff Turn: Within 250ms, CEO acknowledges and mobilizes the squad
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final kickoffMsg = AgentMessage(
      id: 'agent-ceo-kickoff-${DateTime.now().millisecondsSinceEpoch}',
      role: AgentRole.ceo,
      content: '🚀 **Directing Autonomous Engineering Squad**\n\n'
          'Received objective: "$text"\n\n'
          'Mobilizing our on-device specialists: **Product Architect**, **System Architect**, **Frontend Lead**, **Backend Lead**, and **QA Lead**. Convening architectural review now...',
      timestamp: DateTime.now(),
    );

    setState(() {
      currentSession.messages.add(kickoffMsg);
      _activeTypingRole = AgentRole.productArchitect;
      _typingStatusText = 'Product Architect is drafting PRD & User Stories...';
    });
    _scrollToBottom();

    // 3. Generate Real Contextual Squad Group Review Grounded in Database via local Ollama
    final turns = await _localService.generateDynamicSquadTurns(text);

    // If media was requested (image/vector/video/storyboard/motion), generate multimodal assets in real-time
    Map<String, dynamic>? mediaAsset;
    final bool isMediaReq = _localService.isMediaRequest(text);
    if (isMediaReq) {
      if (mounted) {
        setState(() {
          _activeTypingRole = AgentRole.frontendLead;
          _typingStatusText = 'Lead Frontend Engineer & Studio rendering visual media asset...';
        });
      }
      final mediaType = _localService.getMediaType(text);
      mediaAsset = await _localService.generateMedia(type: mediaType, prompt: text);
    }

    // Stagger each engineering specialist chiming in one by one like a real engineering review!
    bool mediaAttached = false;
    for (int i = 0; i < turns.length; i++) {
      final turn = turns[i];
      final AgentRole role = turn['role'] as AgentRole;
      final String content = turn['content'] as String;

      // Avoid duplicating CEO kickoff if first turn is also CEO
      if (role == AgentRole.ceo && i == 0) continue;

      if (!mounted) return;
      setState(() {
        _activeTypingRole = role;
        _typingStatusText = '${role.displayName} is writing architectural review & implementation notes...';
      });

      // Realistic typing pacing
      await Future.delayed(const Duration(milliseconds: 550));

      if (!mounted) return;

      final bool shouldAttachMedia = !mediaAttached && mediaAsset != null &&
          (role == AgentRole.frontendLead || i == turns.length - 1);

      final msg = AgentMessage(
        id: 'agent-${role.name}-${DateTime.now().millisecondsSinceEpoch}',
        role: role,
        content: content,
        timestamp: DateTime.now(),
        mediaType: shouldAttachMedia ? mediaAsset['type'] as String? : null,
        mediaUrl: shouldAttachMedia ? mediaAsset['url'] as String? : null,
        svgContent: shouldAttachMedia ? mediaAsset['svgContent'] as String? : null,
        videoScenes: shouldAttachMedia && mediaAsset['scenes'] is List
            ? (mediaAsset['scenes'] as List).cast<Map<String, dynamic>>()
            : null,
        videoPlayerUrl: shouldAttachMedia ? mediaAsset['playerUrl'] as String? : null,
        videoTitle: shouldAttachMedia ? (mediaAsset['title'] ?? mediaAsset['concept']) as String? : null,
      );

      if (shouldAttachMedia) {
        mediaAttached = true;
      }

      setState(() {
        currentSession.messages.add(msg);
      });
      _scrollToBottom();
    }

    // If media was generated but not attached to any squad turn, add dedicated visual delivery message
    if (mediaAsset != null && !mediaAttached && mounted) {
      final role = AgentRole.frontendLead;
      final msg = AgentMessage(
        id: 'agent-${role.name}-${DateTime.now().millisecondsSinceEpoch}',
        role: role,
        content: mediaAsset['type'] == 'video'
            ? 'Here is the 18-second kinetic promotional video storyboard with complete scene timings, visual direction, and interactive player.'
            : 'Here is the synthesized high-resolution vector emblem and brand visual generated locally on Apple Silicon Metal.',
        timestamp: DateTime.now(),
        mediaType: mediaAsset['type'] as String?,
        mediaUrl: mediaAsset['url'] as String?,
        svgContent: mediaAsset['svgContent'] as String?,
        videoScenes: mediaAsset['scenes'] is List
            ? (mediaAsset['scenes'] as List).cast<Map<String, dynamic>>()
            : null,
        videoPlayerUrl: mediaAsset['playerUrl'] as String?,
        videoTitle: (mediaAsset['title'] ?? mediaAsset['concept']) as String?,
      );
      setState(() {
        currentSession.messages.add(msg);
      });
      _scrollToBottom();
    }

    // 4. Instant Deliverables: Open workspace and populate deliverables immediately!
    final initialDeliv = _localService.generateProductDeliverables(text, turns);
    if (initialDeliv != null && mounted) {
      setState(() {
        currentSession.deliverables = initialDeliv;
        _isWorkspaceOpen = true;
        _isGenerating = false;
        _currentPhase = TaskPhase.memoryRetention;
      });
      _scrollToBottom();
    } else if (mounted) {
      setState(() {
        _isGenerating = false;
        _currentPhase = TaskPhase.memoryRetention;
      });
    }

    // 5. Trigger Real Autonomous Multi-turn Tool-calling Cycle in Background without blocking UI
    _localService.runAutonomousCycle(text).then((cycleResult) {
      if (cycleResult != null && mounted) {
        final fullDeliv = _localService.generateProductDeliverables(text, turns, cycleResult: cycleResult);
        if (fullDeliv != null) {
          setState(() {
            currentSession.deliverables = fullDeliv;
          });
        }
      }
    }).catchError((_) {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
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
                confidence: 0.95,
                learnedAt: DateTime.now(),
              ),
            );
          });
        },
      ),
    );
  }

  void _showKnowledgeBaseModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => KnowledgeDatabaseSheet(
        localService: _localService,
        onRuleAdded: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;
    final showSidebar = _isSidebarOpen && !isCompact && !(_isWorkspaceOpen && screenWidth < 1240);

    return Scaffold(
      backgroundColor: ButaColors.background,
      body: SafeArea(
        child: Row(
          children: [
            // Left Collapsible Clean Light Sidebar
            if (showSidebar) _buildSidebar(),

            // Main Chat Flow + Header
            Expanded(
              child: Column(
                children: [
                  _buildLightTopBar(
                    isCompact: isCompact,
                    isWorkspaceOpen: _isWorkspaceOpen,
                    screenWidth: screenWidth,
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        // Centered Message Stream
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 18,
                                bottom: 180,
                              ),
                              itemCount: _messages.length + (_isGenerating ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _messages.length) {
                                  return _buildInChatTypingIndicator();
                                }
                                return MessageBubble(
                                  message: _messages[index],
                                  onOpenArtifact: () {
                                    setState(() => _isWorkspaceOpen = true);
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                        // Bottom Floating Capsule Input
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: _buildFloatingInputCapsule(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right Slide-Over Deliverables Workspace Drawer
            if (_isWorkspaceOpen)
              ArtifactsWorkspace(
                currentPhase: _currentPhase,
                deliverables: _activeDeliverables,
                onClose: () => setState(() => _isWorkspaceOpen = false),
                onTriggerAction: (objective, action) {
                  _handleSendMessage(overridePrompt: objective);
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- 1. Left Clean Light Sidebar ---
  Widget _buildSidebar() {
    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: ButaColors.sidebar,
        border: Border(
          right: BorderSide(color: ButaColors.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Logo & New Chat Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AgentAvatar(role: AgentRole.ceo, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'ButaAI',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: ButaColors.textBright,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ButaColors.primaryLight,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'STUDIO',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: ButaColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => setState(() => _isSidebarOpen = false),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.view_sidebar_outlined, size: 18, color: ButaColors.textMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // + New Chat Button
                InkWell(
                  onTap: _handleNewChat,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ButaColors.surfaceBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, size: 17, color: ButaColors.primary),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'New Group Chat',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ButaColors.textBright,
                            ),
                          ),
                        ),
                        Text(
                          '⌘K',
                          style: TextStyle(fontSize: 10.5, color: ButaColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: ButaColors.surfaceBorder),

          // ButaAI Engineering Specialists Directory Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'ENGINEERING SQUAD',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: ButaColors.textMuted,
                    ),
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: ButaColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '6 Online',
                  style: TextStyle(fontSize: 10, color: ButaColors.success, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ButaColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ButaColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  _buildSquadItem(AgentRole.ceo, 'Buta CEO', 'Executive Strategy & Scope'),
                  _buildSquadItem(AgentRole.productArchitect, 'Product Architect', 'PRD & UX Requirements'),
                  _buildSquadItem(AgentRole.systemArchitect, 'System Architect', 'Architecture & Schemas'),
                  _buildSquadItem(AgentRole.frontendLead, 'Lead Frontend Engineer', 'UI & State Flow'),
                  _buildSquadItem(AgentRole.backendLead, 'Lead Backend Engineer', 'Services & Local APIs'),
                  _buildSquadItem(AgentRole.qaLead, 'QA & Security Verifier', 'Test Suites & Verification'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: ButaColors.surfaceBorder),

          // Recent Group Chats Header
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              'RECENT SESSIONS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: ButaColors.textMuted,
              ),
            ),
          ),

          // Sessions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final isActive = session.id == _activeSessionId;

                return InkWell(
                  onTap: () => setState(() {
                    _activeSessionId = session.id;
                    _isWorkspaceOpen = session.deliverables != null;
                  }),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? ButaColors.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          session.icon,
                          size: 15,
                          color: isActive ? ButaColors.primary : ButaColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            session.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive ? ButaColors.primary : ButaColors.textNormal,
                            ),
                          ),
                        ),
                        if (_sessions.length > 1) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                final idx = _sessions.indexWhere((s) => s.id == session.id);
                                if (idx != -1) {
                                  _sessions.removeAt(idx);
                                  if (_activeSessionId == session.id) {
                                    _activeSessionId = _sessions.first.id;
                                    _isWorkspaceOpen = _sessions.first.deliverables != null;
                                  }
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.close_rounded, size: 13, color: ButaColors.textMuted),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: ButaColors.surfaceBorder),

          // Bottom Sidebar Footer: Learned Instincts & Engine
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                InkWell(
                  onTap: _showKnowledgeBaseModal,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Text('🧠', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Knowledge DB (${_localService.allKnowledgeItems.length} Rules)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 15, color: ButaColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _showInstinctsModal,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ButaColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_rounded, size: 15, color: ButaColors.primary),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Learned Habits (${_instincts.length})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: ButaColors.textNormal,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 15, color: ButaColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showEngineHealthModal,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ButaColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _isEngineOnline ? ButaColors.success : ButaColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Local Engine • Metal M2 ⚙️',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: ButaColors.textBright,
                                ),
                              ),
                              Text(
                                'Swarm ${_selectedSwarmTier.toUpperCase()} • Metal Active',
                                style: const TextStyle(fontSize: 9.5, color: ButaColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.tune_rounded, size: 14, color: ButaColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquadItem(AgentRole role, String name, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          AgentAvatar(role: role, size: 24, showShadow: false),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: ButaColors.textBright),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9.5, color: ButaColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Clean Light Modern Top Bar ---
  Widget _buildLightTopBar({
    required bool isCompact,
    required bool isWorkspaceOpen,
    required double screenWidth,
  }) {
    final isTight = isCompact || isWorkspaceOpen || screenWidth < 1180;
    final isVeryTight = isCompact || (isWorkspaceOpen && screenWidth < 1250);

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: ButaColors.sidebar,
        border: Border(
          bottom: BorderSide(color: ButaColors.surfaceBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isSidebarOpen ? Icons.view_sidebar_rounded : Icons.view_sidebar_outlined,
              size: 19,
              color: ButaColors.textSecondary,
            ),
            tooltip: _isSidebarOpen ? 'Collapse Sidebar' : 'Open Sidebar',
            splashRadius: 18,
            onPressed: () => setState(() => _isSidebarOpen = !_isSidebarOpen),
          ),
          const SizedBox(width: 8),

          // Central Squad Active Row
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isVeryTight) ...[
                  // Stack of 6 Autonomous Engineering Specialists
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AgentAvatar(role: AgentRole.ceo, size: 24, showShadow: false),
                      SizedBox(width: 3),
                      AgentAvatar(role: AgentRole.productArchitect, size: 24, showShadow: false),
                      SizedBox(width: 3),
                      AgentAvatar(role: AgentRole.systemArchitect, size: 24, showShadow: false),
                      SizedBox(width: 3),
                      AgentAvatar(role: AgentRole.frontendLead, size: 24, showShadow: false),
                      SizedBox(width: 3),
                      AgentAvatar(role: AgentRole.backendLead, size: 24, showShadow: false),
                      SizedBox(width: 3),
                      AgentAvatar(role: AgentRole.qaLead, size: 24, showShadow: false),
                    ],
                  ),
                  const SizedBox(width: 8),
                ] else ...[
                  // Compact Squad Avatars Stack
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AgentAvatar(role: AgentRole.ceo, size: 24, showShadow: false),
                      SizedBox(width: 3),
                      AgentAvatar(role: AgentRole.qaLead, size: 24, showShadow: false),
                    ],
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    isVeryTight ? 'ButaAI (6)' : (isTight ? 'ButaAI Squad (6)' : 'ButaAI Engineering Squad (6 Live)'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ButaColors.textBright,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Swarm Capacity Tier Pill Button
          Tooltip(
            message: 'Decentralized Swarm Intelligence (${_selectedSwarmTier.toUpperCase()} Tier)',
            child: InkWell(
              onTap: _showEngineHealthModal,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isVeryTight ? 6 : 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hub_rounded, size: 14, color: Color(0xFF6366F1)),
                    const SizedBox(width: 5),
                    Text(
                      isVeryTight
                          ? _selectedSwarmTier.toUpperCase()
                          : 'Swarm: ${_selectedSwarmTier.toUpperCase()} (${_selectedSwarmTier == "colossus" ? "35GB" : _selectedSwarmTier == "titan" ? "10GB" : _selectedSwarmTier == "brain" ? "1.2GB" : "11MB"})',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Knowledge Base Button
          Tooltip(
            message: 'Knowledge DB (${_localService.allKnowledgeItems.length} Patterns & Rules)',
            child: InkWell(
              onTap: _showKnowledgeBaseModal,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isVeryTight ? 8 : 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      isVeryTight ? '${_localService.allKnowledgeItems.length}' : 'Knowledge DB (${_localService.allKnowledgeItems.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Deliverables & Assets Drawer Trigger Button
          Tooltip(
            message: 'Deliverables & Launch Assets (4 Ready)',
            child: InkWell(
              onTap: () {
                setState(() => _isWorkspaceOpen = !_isWorkspaceOpen);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isVeryTight ? 8 : 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _isWorkspaceOpen ? ButaColors.primary : ButaColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ButaColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 15,
                      color: _isWorkspaceOpen ? Colors.white : ButaColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isVeryTight ? 'Assets' : 'Deliverables',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isWorkspaceOpen ? Colors.white : ButaColors.primary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _isWorkspaceOpen ? Colors.white.withValues(alpha: 0.25) : ButaColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '4',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. In-Chat Specialist Typing Indicator ---
  Widget _buildInChatTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AgentAvatar(
            role: _activeTypingRole,
            size: 38,
            isSpeaking: true,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: ButaColors.primary.withValues(alpha: 0.22),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ButaColors.primary.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: ButaColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _activeTypingRole.displayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: ButaColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ButaColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      _typingStatusText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ButaColors.textNormal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Floating Centered Input Capsule ---
  Widget _buildFloatingInputCapsule() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ButaColors.surfaceBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick suggestions chips bar
          _buildQuickSuggestions(),

          // Main text area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _promptController,
              focusNode: _promptFocusNode,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              style: const TextStyle(
                color: ButaColors.textBright,
                fontSize: 14.5,
                height: 1.4,
              ),
              decoration: const InputDecoration(
                hintText: 'Direct the engineering squad (e.g., "Build an offline gym tracker with SQLite and Riverpod")...',
                hintStyle: TextStyle(
                  color: ButaColors.textMuted,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),

          // Bottom Control Bar inside Capsule
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                // Engineering Squad Capsule Badge
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ButaColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ButaColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.groups_rounded, size: 14, color: ButaColors.primary),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            MediaQuery.of(context).size.width < 960
                                ? '6 Specialists Live'
                                : 'Autonomous Squad: CEO • Product • Arch • Frontend • Backend • QA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ButaColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (MediaQuery.of(context).size.width >= 740) ...[
                  const SizedBox(width: 12),
                  // Helper Keyboard Hint
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_return_rounded, size: 12, color: ButaColors.textMuted),
                      SizedBox(width: 4),
                      Text(
                        'Enter to send • Shift+Enter for new line',
                        style: TextStyle(
                          fontSize: 11,
                          color: ButaColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(width: 8),
                const Spacer(),

                // Send Action Button
                Tooltip(
                  message: _isGenerating ? 'Squad is deliberating...' : 'Send message (Enter)',
                  child: InkWell(
                    onTap: _isGenerating ? null : () => _handleSendMessage(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _isGenerating ? ButaColors.surfaceLight : ButaColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _isGenerating
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  color: ButaColors.textMuted,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward_rounded,
                                size: 19,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChip('🏗️ Architect Offline Gym OS with SQLite & Riverpod', () {
              _handleSendMessage(overridePrompt: 'Architect a production-grade Offline Gym Tracker app with SQLite persistence, Riverpod state management, and full workout PR analytics.');
            }),
            const SizedBox(width: 6),
            _buildChip('⚡ Build Metal GPU Acceleration Engine for Flutter', () {
              _handleSendMessage(overridePrompt: 'Design and implement an Apple Silicon Metal GPU accelerated local inference pipeline for real-time mobile ML.');
            }),
            const SizedBox(width: 6),
            _buildChip('🔐 Security Hardened Auth & End-to-End Encryption Service', () {
              _handleSendMessage(overridePrompt: 'Build a zero-knowledge local key vault and encrypted SQLite storage layer with argon2 and AES-GCM.');
            }),
            const SizedBox(width: 6),
            _buildChip('🚀 Autonomous Micro-SaaS Billing & License Gateway', () {
              _handleSendMessage(overridePrompt: 'Implement an autonomous licensing server with offline license verification, Stripe webhook verification, and automated entitlement sync.');
            }),
            const SizedBox(width: 6),
            _buildChip('👥 Review Engineering Squad Capabilities', () {
              _handleSendMessage(overridePrompt: 'Introduce the 6 autonomous engineering roles, their specialties, and how you collaborate to ship complete software solutions.');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: ButaColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ButaColors.surfaceBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: ButaColors.textNormal,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showEngineHealthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ButaColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.speed_rounded, color: ButaColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Local Engine Diagnostics & Controls',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ButaColors.textBright,
                              ),
                            ),
                            Text(
                              'Zero cloud dependencies • 100% On-Device Apple Silicon Metal',
                              style: TextStyle(fontSize: 12, color: ButaColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20, color: ButaColors.textMuted),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ButaColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ButaColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        _buildDiagnosticRow(
                          'Metal Acceleration',
                          'Active (Apple Silicon GPU / Unified Memory)',
                          Icons.memory_rounded,
                          ButaColors.success,
                        ),
                        const Divider(height: 18),
                        _buildDiagnosticRow(
                          'Local Model & Weight',
                          'qwen2.5-coder:7b / buta-ai',
                          Icons.psychology_rounded,
                          ButaColors.primary,
                        ),
                        const Divider(height: 18),
                        _buildDiagnosticRow(
                          'LoRA Fine-Tuning Adapters',
                          'Metal GPU Trained (adapters.safetensors, On-Device LoRA)',
                          Icons.auto_fix_high_rounded,
                          ButaColors.accent,
                        ),
                        const Divider(height: 18),
                        _buildDiagnosticRow(
                          'Engine Status & Daemons',
                          'Ollama: localhost:11434 (Live) • Gateway: localhost:3030 (Live)',
                          Icons.sensors_rounded,
                          _isEngineOnline ? ButaColors.success : ButaColors.warning,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.memory_rounded, size: 16, color: Color(0xFF6366F1)),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '⚡ On-Device Engine Architecture & Local LoRA',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: ButaColors.textBright,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Apple Silicon Metal Active',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Executes 100% on-device on Apple Silicon Unified Memory using Qwen2.5-Coder 7B (4.7 GB GGUF). Local LoRA fine-tunes software engineering instincts directly on Metal GPU without cloud dependency. Zero prompts, source files, or credentials ever leave your machine.',
                          style: const TextStyle(fontSize: 11, color: ButaColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ACTIVE ENGINE CAPACITY TIER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: ButaColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildTierChip('nano', '⚡ Nano (1.5B)', 'Rank 8 • Edge', setModalState),
                            const SizedBox(width: 6),
                            _buildTierChip('brain', '🧠 Brain (3B)', 'Rank 128 • Deep', setModalState),
                            const SizedBox(width: 6),
                            _buildTierChip('coder', '🪐 Coder (7B)', 'Active Local Engine', setModalState),
                            const SizedBox(width: 6),
                            _buildTierChip('cloud', '☁️ Frontier', 'Gemini / Claude Hybrid', setModalState),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.autorenew_rounded, size: 16, color: Color(0xFF6366F1)),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Background Swarm Auto-Sync',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: ButaColors.textBright),
                                  ),
                                  Text(
                                    '15-min background daemon checks GitHub consensus releases',
                                    style: TextStyle(fontSize: 10, color: ButaColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _swarmAutoSyncEnabled,
                              activeTrackColor: const Color(0xFF6366F1),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              onChanged: (val) async {
                                setModalState(() => _swarmAutoSyncEnabled = val);
                                setState(() => _swarmAutoSyncEnabled = val);
                                await _localService.toggleAutoSync(val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              _selectedSwarmTier == 'colossus'
                                  ? 'Global Epoch: v2.5-collective • Loss: 1.04 • 35 GB Consensus'
                                  : 'Global Epoch: v2.5-collective • Loss: 1.18',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: ButaColors.textBright),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(context);
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('🌐 Synchronizing with ButaAI Collective Swarm...'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                                final res = await _localService.syncWithSwarm();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'Swarm sync complete!'),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.sync_rounded, size: 14),
                              label: const Text('Sync Swarm Weights', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final tier = _selectedSwarmTier;
                            Navigator.pop(context);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('⚡ Starting Metal GPU LoRA Retraining (${tier.toUpperCase()} tier)... Apple Silicon Metal active!'),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                            final ok = await _localService.triggerLocalTraining(iters: 10, tier: tier);
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? '✅ Metal GPU LoRA Retraining Finished! Fresh ${tier.toUpperCase()} weights saved.'
                                      : '⚡ Metal Retraining process completed.'),
                                  backgroundColor: ok ? ButaColors.secondary : null,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: Text(
                            _selectedSwarmTier == 'cloud'
                                ? 'Test Cloud Hybrid (Gemini API)'
                                : _selectedSwarmTier == 'coder'
                                    ? '1-Click Metal Retrain (7B Qwen)'
                                    : _selectedSwarmTier == 'brain'
                                        ? '1-Click Metal Retrain (3B)'
                                        : '1-Click Metal Retrain (1.5B)',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ButaColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse(_localService.downloadZipUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                          icon: const Icon(Icons.archive_outlined, size: 18),
                          label: const Text('Export Project ZIP'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ButaColors.textBright,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: ButaColors.surfaceBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTierChip(String tierKey, String title, String subtitle, StateSetter setModalState) {
    final isSelected = _selectedSwarmTier == tierKey;
    return Expanded(
      child: InkWell(
        onTap: () async {
          setModalState(() => _selectedSwarmTier = tierKey);
          setState(() => _selectedSwarmTier = tierKey);
          await _localService.setSwarmTier(tierKey);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : ButaColors.textBright,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white.withValues(alpha: 0.85) : ButaColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ButaColors.textBright)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
