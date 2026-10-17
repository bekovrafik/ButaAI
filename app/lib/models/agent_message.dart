import 'package:flutter/material.dart';

enum AgentRole {
  user,
  ceo,
  productArchitect,
  systemArchitect,
  frontendLead,
  backendLead,
  qaLead,
  system;

  // Backward-compatible aliases
  static AgentRole get gelly => AgentRole.ceo;
  static AgentRole get bloop => AgentRole.productArchitect;
  static AgentRole get pip => AgentRole.systemArchitect;
  static AgentRole get mochi => AgentRole.frontendLead;
  static AgentRole get spark => AgentRole.qaLead;
  static AgentRole get developer => AgentRole.backendLead;
  static AgentRole get codeReviewer => AgentRole.frontendLead;
  static AgentRole get qaSimulator => AgentRole.qaLead;

  String get displayName {
    switch (this) {
      case AgentRole.user:
        return 'You';
      case AgentRole.ceo:
        return 'Buta CEO';
      case AgentRole.productArchitect:
        return 'Product Architect';
      case AgentRole.systemArchitect:
        return 'System Architect';
      case AgentRole.frontendLead:
        return 'Lead Frontend Engineer';
      case AgentRole.backendLead:
        return 'Lead Backend Engineer';
      case AgentRole.qaLead:
        return 'QA & Security Verifier';
      case AgentRole.system:
        return 'ButaAI Core Engine';
    }
  }

  String get roleSubtitle {
    switch (this) {
      case AgentRole.user:
        return 'Product Creator';
      case AgentRole.ceo:
        return 'Executive Strategy & Roadmaps';
      case AgentRole.productArchitect:
        return 'PRD & UX Requirements';
      case AgentRole.systemArchitect:
        return 'Tech Stack & System Design';
      case AgentRole.frontendLead:
        return 'UI Components & Reactive State';
      case AgentRole.backendLead:
        return 'Data Models & High-Performance APIs';
      case AgentRole.qaLead:
        return 'Automated Tests & Vulnerability Gate';
      case AgentRole.system:
        return 'Apple Silicon Metal Engine';
    }
  }

  String get shortRole {
    switch (this) {
      case AgentRole.user:
        return 'YOU';
      case AgentRole.ceo:
        return 'CEO';
      case AgentRole.productArchitect:
        return 'PRD';
      case AgentRole.systemArchitect:
        return 'ARCH';
      case AgentRole.frontendLead:
        return 'UI';
      case AgentRole.backendLead:
        return 'CORE';
      case AgentRole.qaLead:
        return 'QA/SEC';
      case AgentRole.system:
        return 'ENGINE';
    }
  }

  IconData get icon {
    switch (this) {
      case AgentRole.user:
        return Icons.person_rounded;
      case AgentRole.ceo:
        return Icons.psychology_rounded;
      case AgentRole.productArchitect:
        return Icons.assignment_turned_in_rounded;
      case AgentRole.systemArchitect:
        return Icons.account_tree_rounded;
      case AgentRole.frontendLead:
        return Icons.palette_rounded;
      case AgentRole.backendLead:
        return Icons.terminal_rounded;
      case AgentRole.qaLead:
        return Icons.verified_user_rounded;
      case AgentRole.system:
        return Icons.memory_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AgentRole.user:
        return const Color(0xFF4F46E5);
      case AgentRole.ceo:
        return const Color(0xFF6366F1); // Indigo
      case AgentRole.productArchitect:
        return const Color(0xFF0284C7); // Sky Blue
      case AgentRole.systemArchitect:
        return const Color(0xFF0D9488); // Teal
      case AgentRole.frontendLead:
        return const Color(0xFFD97706); // Amber Gold
      case AgentRole.backendLead:
        return const Color(0xFF2563EB); // Electric Blue
      case AgentRole.qaLead:
        return const Color(0xFF059669); // Emerald Green
      case AgentRole.system:
        return const Color(0xFF64748B);
    }
  }

  Color get lightBackgroundColor {
    switch (this) {
      case AgentRole.user:
        return const Color(0xFFEEF2FF);
      case AgentRole.ceo:
        return const Color(0xFFEEF2FF);
      case AgentRole.productArchitect:
        return const Color(0xFFF0F9FF);
      case AgentRole.systemArchitect:
        return const Color(0xFFF0FDFA);
      case AgentRole.frontendLead:
        return const Color(0xFFFFFBEB);
      case AgentRole.backendLead:
        return const Color(0xFFEFF6FF);
      case AgentRole.qaLead:
        return const Color(0xFFECFDF5);
      case AgentRole.system:
        return const Color(0xFFF8FAFC);
    }
  }
}

class AgentMessage {
  final String id;
  final AgentRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
  final String? codeSnippet;
  final String? metadata;

  AgentMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.codeSnippet,
    this.metadata,
  });

  AgentMessage copyWith({
    String? content,
    bool? isStreaming,
    String? codeSnippet,
    String? metadata,
    AgentRole? role,
  }) {
    return AgentMessage(
      id: id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      metadata: metadata ?? this.metadata,
    );
  }
}
