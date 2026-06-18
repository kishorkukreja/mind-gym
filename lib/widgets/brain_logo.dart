import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BrainLogo extends StatefulWidget {
  final double size;
  final double developmentPercent; // 0.0 to 1.0

  const BrainLogo({
    super.key,
    this.size = 80,
    this.developmentPercent = 1.0,
  });

  @override
  State<BrainLogo> createState() => _BrainLogoState();
}

class _BrainLogoState extends State<BrainLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: BrainPainter(
            animValue: _controller.value,
            developmentPercent: widget.developmentPercent,
          ),
        );
      },
    );
  }
}

class BrainPainter extends CustomPainter {
  final double animValue;
  final double developmentPercent;

  BrainPainter({required this.animValue, required this.developmentPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;

    // Background circle
    final bgPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r + 4, bgPaint);

    // Brain circle border
    final borderPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r + 4, borderPaint);

    // Brain icon (simplified)
    final brainPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.fill;

    // Left hemisphere
    final leftPath = Path();
    leftPath.moveTo(center.dx - 2, center.dy - r * 0.5);
    leftPath.cubicTo(
      center.dx - r * 0.9, center.dy - r * 0.8,
      center.dx - r * 1.1, center.dy + r * 0.2,
      center.dx - 2, center.dy + r * 0.55,
    );
    leftPath.cubicTo(
      center.dx - r * 0.5, center.dy + r * 0.7,
      center.dx - r * 0.1, center.dy + r * 0.3,
      center.dx - 2, center.dy - r * 0.5,
    );
    canvas.drawPath(leftPath, brainPaint);

    // Right hemisphere
    final rightPath = Path();
    rightPath.moveTo(center.dx + 2, center.dy - r * 0.5);
    rightPath.cubicTo(
      center.dx + r * 0.9, center.dy - r * 0.8,
      center.dx + r * 1.1, center.dy + r * 0.2,
      center.dx + 2, center.dy + r * 0.55,
    );
    rightPath.cubicTo(
      center.dx + r * 0.5, center.dy + r * 0.7,
      center.dx + r * 0.1, center.dy + r * 0.3,
      center.dx + 2, center.dy - r * 0.5,
    );
    canvas.drawPath(rightPath, brainPaint);

    // Neural nodes (glow and pulse)
    final nodes = _getNodes(center, r);
    final nodeCount = (nodes.length * developmentPercent).ceil();

    for (int i = 0; i < nodeCount; i++) {
      final node = nodes[i];
      final pulsePhase = (animValue + i * 0.15) % 1.0;
      final pulse = sin(pulsePhase * pi * 2) * 0.5 + 0.5;

      // Connection lines between nearby nodes
      for (int j = i + 1; j < nodeCount; j++) {
        final other = nodes[j];
        final dist = (node - other).distance;
        if (dist < r * 0.7) {
          final linePaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.25 * developmentPercent)
            ..strokeWidth = 0.8
            ..style = PaintingStyle.stroke;
          canvas.drawLine(node, other, linePaint);
        }
      }

      // Node glow
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.15 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node, 5, glowPaint);

      // Node dot
      final nodePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7 + 0.3 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node, 2, nodePaint);
    }
  }

  List<Offset> _getNodes(Offset center, double r) {
    return [
      center + Offset(-r * 0.4, -r * 0.35),
      center + Offset(-r * 0.65, 0),
      center + Offset(-r * 0.4, r * 0.35),
      center + Offset(-r * 0.2, r * 0.6),
      center + Offset(r * 0.4, -r * 0.35),
      center + Offset(r * 0.65, 0),
      center + Offset(r * 0.4, r * 0.35),
      center + Offset(r * 0.2, r * 0.6),
      center + Offset(0, -r * 0.55),
      center + Offset(0, r * 0.55),
    ];
  }

  @override
  bool shouldRepaint(BrainPainter old) =>
      old.animValue != animValue || old.developmentPercent != developmentPercent;
}

// Big brain visualization for progress screen
class BrainProgress extends StatefulWidget {
  final double developmentPercent;
  final int level;
  final String levelTitle;

  const BrainProgress({
    super.key,
    required this.developmentPercent,
    required this.level,
    required this.levelTitle,
  });

  @override
  State<BrainProgress> createState() => _BrainProgressState();
}

class _BrainProgressState extends State<BrainProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(220, 220),
          painter: BrainProgressPainter(
            animValue: _ctrl.value,
            developmentPercent: widget.developmentPercent,
            level: widget.level,
          ),
        );
      },
    );
  }
}

class BrainProgressPainter extends CustomPainter {
  final double animValue;
  final double developmentPercent;
  final int level;

  BrainProgressPainter({
    required this.animValue,
    required this.developmentPercent,
    required this.level,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;

    // Outer progress ring
    final ringBg = Paint()
      ..color = AppTheme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r + 12, ringBg);

    final ringFg = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final sweep = 2 * pi * developmentPercent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r + 12),
      -pi / 2,
      sweep,
      false,
      ringFg,
    );

    // Background
    final bgPaint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r, bgPaint);

    // Brain hemispheres
    _drawBrain(canvas, center, r);

    // Neural connections (more = higher level)
    final maxNodes = 12;
    final visibleNodes = (maxNodes * developmentPercent).ceil();
    final nodes = _getNodes(center, r);

    for (int i = 0; i < visibleNodes && i < nodes.length; i++) {
      final node = nodes[i];
      final pulsePhase = (animValue + i * 0.12) % 1.0;
      final pulse = sin(pulsePhase * pi * 2) * 0.5 + 0.5;

      for (int j = i + 1; j < visibleNodes && j < nodes.length; j++) {
        final other = nodes[j];
        final dist = (node - other).distance;
        if (dist < r * 0.65) {
          final alpha = (0.35 * developmentPercent * (1 - dist / (r * 0.65))).clamp(0.0, 1.0);
          final linePaint = Paint()
            ..color = AppTheme.primary.withValues(alpha: alpha)
            ..strokeWidth = 1.2
            ..style = PaintingStyle.stroke;
          canvas.drawLine(node, other, linePaint);
        }
      }

      final glowPaint = Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.2 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node, 7, glowPaint);

      final nodePaint = Paint()
        ..color = AppTheme.primary.withValues(alpha: 0.7 + 0.3 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(node, 3, nodePaint);
    }
  }

  void _drawBrain(Canvas canvas, Offset center, double r) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final leftPath = Path();
    leftPath.moveTo(center.dx - 2, center.dy - r * 0.5);
    leftPath.cubicTo(
      center.dx - r * 0.85, center.dy - r * 0.75,
      center.dx - r * 1.0, center.dy + r * 0.2,
      center.dx - 2, center.dy + r * 0.5,
    );
    leftPath.cubicTo(
      center.dx - r * 0.45, center.dy + r * 0.65,
      center.dx - r * 0.1, center.dy + r * 0.25,
      center.dx - 2, center.dy - r * 0.5,
    );
    canvas.drawPath(leftPath, paint);

    final rightPath = Path();
    rightPath.moveTo(center.dx + 2, center.dy - r * 0.5);
    rightPath.cubicTo(
      center.dx + r * 0.85, center.dy - r * 0.75,
      center.dx + r * 1.0, center.dy + r * 0.2,
      center.dx + 2, center.dy + r * 0.5,
    );
    rightPath.cubicTo(
      center.dx + r * 0.45, center.dy + r * 0.65,
      center.dx + r * 0.1, center.dy + r * 0.25,
      center.dx + 2, center.dy - r * 0.5,
    );
    canvas.drawPath(rightPath, paint);
  }

  List<Offset> _getNodes(Offset center, double r) {
    return [
      center + Offset(-r * 0.45, -r * 0.4),
      center + Offset(-r * 0.7, -r * 0.05),
      center + Offset(-r * 0.5, r * 0.35),
      center + Offset(-r * 0.2, r * 0.55),
      center + Offset(-r * 0.25, -r * 0.1),
      center + Offset(r * 0.45, -r * 0.4),
      center + Offset(r * 0.7, -r * 0.05),
      center + Offset(r * 0.5, r * 0.35),
      center + Offset(r * 0.2, r * 0.55),
      center + Offset(r * 0.25, -r * 0.1),
      center + Offset(0, -r * 0.6),
      center + Offset(0, r * 0.15),
    ];
  }

  @override
  bool shouldRepaint(BrainProgressPainter old) =>
      old.animValue != animValue ||
      old.developmentPercent != developmentPercent;
}
