import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../models/agent_message.dart';
import '../theme/buta_theme.dart';
import 'agent_avatar.dart';

class MessageBubble extends StatefulWidget {
  final AgentMessage message;
  final VoidCallback? onOpenArtifact;
  final String? thinkingContent;
  final String? artifactName;

  const MessageBubble({
    super.key,
    required this.message,
    this.onOpenArtifact,
    this.thinkingContent,
    this.artifactName,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isThinkingExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == AgentRole.user;
    final timeStr = DateFormat('HH:mm').format(widget.message.timestamp);

    if (isUser) {
      return _buildUserMessage(timeStr);
    } else {
      return _buildAssistantMessage(context, timeStr);
    }
  }

  Widget _buildUserMessage(String timeStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 620),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                color: ButaColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ButaColors.primary.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SelectableText(
                    widget.message.content,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const AgentAvatar(role: AgentRole.user, size: 34),
        ],
      ),
    );
  }

  Widget _buildAssistantMessage(BuildContext context, String timeStr) {
    final role = widget.message.role;
    final roleColor = role.color;
    final hasArtifact = widget.artifactName != null ||
        widget.message.content.contains('Deliverables') ||
        widget.message.content.contains('Launch Video') ||
        widget.message.content.contains('Artifact:');

    final bool showThinking = role == AgentRole.ceo || role == AgentRole.system;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Gel Avatar
          AgentAvatar(
            role: role,
            size: 42,
            isSpeaking: widget.message.isStreaming,
          ),
          const SizedBox(width: 14),

          // Message Content Body
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 780),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ButaColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ButaColors.surfaceBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assistant Header (Gel Name, Role Subtitle Badge, Time, Copy)
                  Row(
                    children: [
                      Text(
                        role.displayName,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: ButaColors.textBright,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: role.lightBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          role.roleSubtitle,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ButaColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.message.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Message copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.copy_rounded, size: 14, color: ButaColors.textMuted),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Collapsible Thinking Box
                  if (showThinking)
                    _buildGelThinkingBox(),

                  // Markdown Rendered Body (Clean Light Palette)
                  MarkdownBody(
                    data: widget.message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: ButaColors.textNormal,
                      ),
                      h1: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: ButaColors.textBright,
                        height: 1.4,
                      ),
                      h2: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: ButaColors.textBright,
                        height: 1.4,
                      ),
                      h3: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ButaColors.textBright,
                        height: 1.4,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ButaColors.textBright,
                      ),
                      em: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: ButaColors.textSecondary,
                      ),
                      listBullet: TextStyle(
                        color: roleColor,
                        fontSize: 14,
                      ),
                      blockquote: const TextStyle(
                        color: ButaColors.textSecondary,
                        fontStyle: FontStyle.normal,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: ButaColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(color: roleColor, width: 3.5),
                        ),
                      ),
                      tableBorder: TableBorder.all(
                        color: ButaColors.surfaceBorder,
                        width: 1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tableHead: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ButaColors.textBright,
                        fontSize: 13,
                      ),
                      tableBody: const TextStyle(
                        color: ButaColors.textNormal,
                        fontSize: 13,
                      ),
                      tableHeadAlign: TextAlign.left,
                      tablePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      code: TextStyle(
                        backgroundColor: ButaColors.surfaceLight,
                        color: ButaColors.primary,
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                  // Deliverables Drawer Trigger Card
                  if (hasArtifact && widget.onOpenArtifact != null) ...[
                    const SizedBox(height: 14),
                    _buildDeliverableAccessCard(),
                  ],

                  // Streaming Indicator
                  if (widget.message.isStreaming) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: roleColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${role.displayName} is formulating thoughts...',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: ButaColors.textMuted.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ButaAI Engineering Review Disclosure Box ---
  Widget _buildGelThinkingBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ButaColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ButaColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isThinkingExpanded = !_isThinkingExpanded),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _isThinkingExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                    size: 16,
                    color: ButaColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      '⚡ ButaAI Engineering Review (6 Autonomous Specialists)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ButaColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isThinkingExpanded ? 'Hide' : 'Show review',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ButaColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isThinkingExpanded) ...[
            const Divider(height: 1, color: ButaColors.surfaceBorder),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThoughtLine('🎯 CEO', 'Established technical roadmap, ROI milestones, and commercial architecture.'),
                  const SizedBox(height: 6),
                  _buildThoughtLine('📋 Product', 'Defined core user stories, PRD scope, and zero-defect acceptance criteria.'),
                  const SizedBox(height: 6),
                  _buildThoughtLine('🏛️ Architect', 'Structured Clean Architecture boundaries, SQLite schemas, and state patterns.'),
                  const SizedBox(height: 6),
                  _buildThoughtLine('🎨 Frontend', 'Engineered porcelain design tokens, responsive layouts, and 60fps micro-motion.'),
                  const SizedBox(height: 6),
                  _buildThoughtLine('⚙️ Backend', 'Implemented high-throughput local services, offline caching, and data pipelines.'),
                  const SizedBox(height: 6),
                  _buildThoughtLine('🛡️ QA Lead', 'Executed automated verification suite, security audits, and edge assertions.'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThoughtLine(String role, String thought) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            role,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: ButaColors.textBright,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            thought,
            style: const TextStyle(
              fontSize: 11.5,
              color: ButaColors.textNormal,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // --- Deliverables Card ---
  Widget _buildDeliverableAccessCard() {
    return InkWell(
      onTap: widget.onOpenArtifact,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ButaColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ButaColors.primary.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: ButaColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.inventory_2_rounded, size: 20, color: ButaColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📦 Product Deliverables & Creative Assets Ready',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ButaColors.primary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Interactive Launch Video • Audience Pulse • 3D Visuals • Launchpad',
                    style: TextStyle(
                      fontSize: 11,
                      color: ButaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: ButaColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Open Drawer',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
