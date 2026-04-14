import 'dart:math' as math;
import 'package:flutter/material.dart';

class SegmentedCircularProgress extends StatelessWidget {
  final int totalSegments;
  final int completedSegments;
  final double radius;
  final double strokeWidth;
  final Color completedColor;
  final Color backgroundColor;
  final Widget centerWidget;

  const SegmentedCircularProgress({
    Key? key,
    required this.totalSegments,
    required this.completedSegments,
    required this.radius,
    required this.strokeWidth,
    required this.completedColor,
    required this.backgroundColor,
    required this.centerWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: CustomPaint(
        painter: _SegmentedCirclePainter(
          totalSegments: totalSegments,
          completedSegments: completedSegments,
          completedColor: completedColor,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
        ),
        child: Center(child: centerWidget),
      ),
    );
  }
}

class _SegmentedCirclePainter extends CustomPainter {
  final int totalSegments;
  final int completedSegments;
  final Color completedColor;
  final Color backgroundColor;
  final double strokeWidth;

  _SegmentedCirclePainter({
    required this.totalSegments,
    required this.completedSegments,
    required this.completedColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final double sweepAngle = (2 * math.pi) / totalSegments;
    final double gapAngle = 0.26;   // espace visible entre les segments

    // Fond (gris)
    paint.color = backgroundColor;
    for (int i = 0; i < totalSegments; i++) {
      final startAngle = i * sweepAngle + gapAngle / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - gapAngle,
        false,
        paint,
      );
    }

    // Segments complétés (vert)
    paint.color = completedColor;
    for (int i = 0; i < completedSegments; i++) {
      final startAngle = i * sweepAngle + gapAngle / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - gapAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}