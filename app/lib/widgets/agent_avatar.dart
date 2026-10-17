import 'package:flutter/material.dart';
import '../models/agent_message.dart';
import '../theme/buta_theme.dart';

/// Ultra-clean, hardware-grade AI Engineering Specialist Avatar
/// Built with double-bezel concentric rings, gradient surface,
/// vector specialty icon, and pulsing online status.
class AgentAvatar extends StatelessWidget {
  final AgentRole role;
  final double size;
  final bool isSpeaking;
  final bool showShadow;

  const AgentAvatar({
    super.key,
    required this.role,
    this.size = 36,
    this.isSpeaking = false,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    if (role == AgentRole.user) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ButaColors.user,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ButaColors.user.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.person_rounded,
            size: size * 0.54,
            color: Colors.white,
          ),
        ),
      );
    }

    final roleColor = role.color;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer concentric glow ring when speaking / active
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: role.lightBackgroundColor,
            border: Border.all(
              color: isSpeaking ? roleColor : roleColor.withValues(alpha: 0.35),
              width: isSpeaking ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: roleColor.withValues(alpha: isSpeaking ? 0.35 : 0.12),
                blurRadius: isSpeaking ? 10 : 4,
                spreadRadius: isSpeaking ? 1 : 0,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: size * 0.76,
              height: size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    roleColor,
                    roleColor.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  role.icon,
                  size: size * 0.44,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Live micro-indicator dot
        if (isSpeaking)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.32,
              height: size * 0.32,
              decoration: BoxDecoration(
                color: ButaColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: ButaColors.success.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
