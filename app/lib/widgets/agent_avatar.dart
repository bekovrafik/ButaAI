import 'package:flutter/material.dart';
import '../models/agent_message.dart';
import '../theme/buta_theme.dart';

class AgentAvatar extends StatelessWidget {
  final AgentRole role;
  final double size;

  const AgentAvatar({
    super.key,
    required this.role,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRoleColor(role);
    final icon = _getRoleIcon(role);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.52,
          color: color,
        ),
      ),
    );
  }

  static Color _getRoleColor(AgentRole role) {
    switch (role) {
      case AgentRole.user:
        return ButaColors.user;
      case AgentRole.ceo:
        return ButaColors.ceo;
      case AgentRole.productArchitect:
        return ButaColors.secondary;
      case AgentRole.systemArchitect:
        return ButaColors.architect;
      case AgentRole.developer:
        return ButaColors.developer;
      case AgentRole.codeReviewer:
        return ButaColors.reviewer;
      case AgentRole.qaSimulator:
        return ButaColors.qa;
      case AgentRole.system:
        return ButaColors.textMuted;
    }
  }

  static IconData _getRoleIcon(AgentRole role) {
    switch (role) {
      case AgentRole.user:
        return Icons.person_rounded;
      case AgentRole.ceo:
        return Icons.business_center_rounded;
      case AgentRole.productArchitect:
        return Icons.design_services_rounded;
      case AgentRole.systemArchitect:
        return Icons.account_tree_rounded;
      case AgentRole.developer:
        return Icons.code_rounded;
      case AgentRole.codeReviewer:
        return Icons.security_rounded;
      case AgentRole.qaSimulator:
        return Icons.phone_iphone_rounded;
      case AgentRole.system:
        return Icons.memory_rounded;
    }
  }
}
