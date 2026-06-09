import 'dart:async';
import 'dart:math' as math;

import 'package:afroduo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Firstpage extends StatefulWidget {
  const Firstpage({super.key});

  @override
  State<Firstpage> createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/welcome");
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 330,
                  height: 330,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Image.asset(
                      "assets/images/avatars/liodebut.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Afroluo",
                  style: textTheme.displayMedium?.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
                CameroonCircularProgress(animation: _progressController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CameroonCircularProgress extends StatelessWidget {
  final Animation<double> animation;

  const CameroonCircularProgress({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return CustomPaint(
            painter: _CameroonProgressPainter(animation.value),
          );
        },
      ),
    );
  }
}

class _CameroonProgressPainter extends CustomPainter {
  final double progress;

  _CameroonProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final rect = Offset.zero & size;
    final insetRect = rect.deflate(strokeWidth / 2);
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.grey100;

    canvas.drawArc(insetRect, 0, math.pi * 2, false, backgroundPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: const [
          AppColors.primaryBlue,
          AppColors.lightBlueAccent,
          AppColors.warningOrange,
          AppColors.secondaryBlue,
          AppColors.primaryBlue,
        ],
      ).createShader(insetRect);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate((progress * math.pi * 2) - math.pi / 2);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawArc(insetRect, 0, math.pi * 1.55, false, progressPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CameroonProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
