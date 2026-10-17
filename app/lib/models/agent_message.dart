enum AgentRole {
  user,
  ceo,
  productArchitect,
  systemArchitect,
  developer,
  codeReviewer,
  qaSimulator,
  system;

  String get displayName {
    switch (this) {
      case AgentRole.user:
        return 'Executive Chairman (You)';
      case AgentRole.ceo:
        return 'CEO Orchestrator';
      case AgentRole.productArchitect:
        return 'Product Architect';
      case AgentRole.systemArchitect:
        return 'System Architect';
      case AgentRole.developer:
        return 'TDD Developer';
      case AgentRole.codeReviewer:
        return 'Adversarial Reviewer';
      case AgentRole.qaSimulator:
        return 'QA Simulator Runner';
      case AgentRole.system:
        return 'ButaAI Engine';
    }
  }

  String get shortRole {
    switch (this) {
      case AgentRole.user:
        return 'YOU';
      case AgentRole.ceo:
        return 'CEO';
      case AgentRole.productArchitect:
        return 'PRODUCT';
      case AgentRole.systemArchitect:
        return 'ARCHITECT';
      case AgentRole.developer:
        return 'DEV';
      case AgentRole.codeReviewer:
        return 'REVIEW';
      case AgentRole.qaSimulator:
        return 'QA';
      case AgentRole.system:
        return 'ENGINE';
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
  }) {
    return AgentMessage(
      id: id,
      role: role,
      content: content ?? this.content,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      codeSnippet: codeSnippet ?? this.codeSnippet,
      metadata: metadata ?? this.metadata,
    );
  }
}
