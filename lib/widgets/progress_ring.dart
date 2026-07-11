import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A static progress ring — draws directly at the current [progress] value
/// with no animated transition. Deliberately has no AnimationController:
/// earlier versions replayed a "grow" animation on every value change,
/// which (since progress updates every second while a timer runs) caused
/// a continuous, distracting pulsing/blinking effect.
class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 160,
    this.strokeWidth = 12,
    this.color,
    this.trackColor,
    this.child,
    // Kept for backwards compatibility with existing call sites; no longer
    // has any effect since this widget never animates.
    bool animate = true,
    Duration animationDuration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    final ringColor = color ?? AppColors.primary;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          color: ringColor,
          trackColor: trackColor ?? AppColors.surfaceVariant,
          strokeWidth: strokeWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Subtle glow effect (static, no animation)
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
