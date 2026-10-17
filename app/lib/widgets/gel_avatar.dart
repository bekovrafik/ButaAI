import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/agent_message.dart';

/// A delightful, squishy, bouncy 3D-effect translucent Gel Assistant avatar.
/// Features glossy liquid highlights, expressive shiny eyes, cute smiles,
/// and subtle organic breathing/squish physics animations.
class GelAvatar extends StatefulWidget {
  final AgentRole role;
  final double size;
  final bool isSpeaking;
  final bool showShadow;

  const GelAvatar({
    super.key,
    required this.role,
    this.size = 44,
    this.isSpeaking = false,
    this.showShadow = true,
  });

  @override
  State<GelAvatar> createState() => _GelAvatarState();
}

class _GelAvatarState extends State<GelAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    // Subtle idle squish & breathing loop
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + (widget.role.index * 220)),
    )..repeat(reverse: true);

    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    if (!mounted) return;
    final delay = 2500 + math.Random().nextInt(3000);
    _blinkTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() => _isBlinking = true);
      _blinkTimer = Timer(const Duration(milliseconds: 140), () {
        if (!mounted) return;
        setState(() => _isBlinking = false);
        _scheduleNextBlink();
      });
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Idle squish physics: slight vertical and horizontal stretch
        final double t = _controller.value;
        final double squishFactor = widget.isSpeaking ? 0.09 : 0.045;
        final double scaleX = 1.0 + (math.sin(t * math.pi) * squishFactor);
        final double scaleY = 1.0 - (math.sin(t * math.pi) * squishFactor);
        final double bounceY = widget.isSpeaking ? -math.sin(t * math.pi * 2).abs() * 4.0 : 0.0;

        return Transform.translate(
          offset: Offset(0, bounceY),
          child: Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _GelPainter(
                  role: widget.role,
                  isBlinking: _isBlinking,
                  isSpeaking: widget.isSpeaking,
                  showShadow: widget.showShadow,
                  animValue: t,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GelPainter extends CustomPainter {
  final AgentRole role;
  final bool isBlinking;
  final bool isSpeaking;
  final bool showShadow;
  final double animValue;

  _GelPainter({
    required this.role,
    required this.isBlinking,
    required this.isSpeaking,
    required this.showShadow,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.44;

    // 1. Soft Ambient Drop Shadow
    if (showShadow) {
      final shadowPaint = Paint()
        ..color = role.color.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      final shadowRect = Rect.fromCenter(
        center: Offset(w / 2, h * 0.90),
        width: w * 0.65,
        height: h * 0.18,
      );
      canvas.drawOval(shadowRect, shadowPaint);
    }

    // 2. Main Translucent Gel Body (Radial gradient from highlight to rich jelly tint)
    final gelPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.42),
        radius: 0.92,
        colors: [
          Color.lerp(role.color, Colors.white, 0.45)!,
          role.color,
          _getDeepGelTone(role.color),
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, gelPaint);

    // 3. Inner Gel Refraction Rim (Simulates liquid glass subsurface glow)
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.2),
        radius: 0.85,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.45),
        ],
        stops: const [0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - (w * 0.02), rimPaint);

    // 4. Glossy Specular Reflection (Top-left glass crescent shine)
    final specPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.85),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.14, w * 0.35, h * 0.22));

    canvas.save();
    canvas.translate(w * 0.30, h * 0.22);
    canvas.rotate(-math.pi / 7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.34, height: h * 0.16),
      specPaint,
    );
    canvas.restore();

    // 5. Cute Pink Cheek Blush
    final blushPaint = Paint()
      ..color = const Color(0xFFFF6B8B).withValues(alpha: 0.42)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.28, h * 0.58), width: w * 0.14, height: h * 0.08),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.72, h * 0.58), width: w * 0.14, height: h * 0.08),
      blushPaint,
    );

    // 6. Eyes (Cute shiny black beads with high-specular white glints)
    final eyePaint = Paint()..color = const Color(0xFF1E1B2E);
    final glintPaint = Paint()..color = Colors.white;

    final eyeLeft = Offset(w * 0.38, h * 0.46);
    final eyeRight = Offset(w * 0.62, h * 0.46);
    final eyeRadius = w * 0.065;

    if (isBlinking) {
      // Blinking: cute curved thin slit
      final blinkPaint = Paint()
        ..color = const Color(0xFF1E1B2E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(eyeLeft.dx - eyeRadius, eyeLeft.dy),
        Offset(eyeLeft.dx + eyeRadius, eyeLeft.dy),
        blinkPaint,
      );
      canvas.drawLine(
        Offset(eyeRight.dx - eyeRadius, eyeRight.dy),
        Offset(eyeRight.dx + eyeRadius, eyeRight.dy),
        blinkPaint,
      );
    } else {
      // Open shiny eyes
      canvas.drawCircle(eyeLeft, eyeRadius, eyePaint);
      canvas.drawCircle(eyeRight, eyeRadius, eyePaint);

      // Top specular dot
      canvas.drawCircle(
        Offset(eyeLeft.dx - (eyeRadius * 0.35), eyeLeft.dy - (eyeRadius * 0.35)),
        eyeRadius * 0.42,
        glintPaint,
      );
      canvas.drawCircle(
        Offset(eyeRight.dx - (eyeRadius * 0.35), eyeRight.dy - (eyeRadius * 0.35)),
        eyeRadius * 0.42,
        glintPaint,
      );
    }

    // 7. Expressive Mouth (Cute smile or speaking 'O')
    final mouthPaint = Paint()
      ..color = const Color(0xFF1E1B2E)
      ..style = isSpeaking ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    if (isSpeaking) {
      // Talking: Cute bouncy open 'O'
      final mouthRect = Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.62),
        width: w * 0.12,
        height: h * 0.11,
      );
      canvas.drawOval(mouthRect, mouthPaint);
    } else {
      // Idle smiling curve
      final mouthPath = Path();
      mouthPath.moveTo(w * 0.44, h * 0.58);
      mouthPath.quadraticBezierTo(w * 0.50, h * 0.66, w * 0.56, h * 0.58);
      canvas.drawPath(mouthPath, mouthPaint);
    }
  }

  Color _getDeepGelTone(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant _GelPainter oldDelegate) {
    return oldDelegate.animValue != animValue ||
        oldDelegate.isBlinking != isBlinking ||
        oldDelegate.isSpeaking != isSpeaking ||
        oldDelegate.role != role;
  }
}
