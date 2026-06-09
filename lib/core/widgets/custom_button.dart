import 'package:afroduo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.borderRadius = 28,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: enabled
            ? const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: AppColors.cameroonGradient,
                stops: [0.0, 0.42, 0.62, 0.86, 1.0],
              )
            : LinearGradient(colors: [AppColors.grey200, AppColors.grey100]),
        boxShadow: enabled
            ? const [
                BoxShadow(
                  color: AppColors.blackOpacity25,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: Center(
              child: Text(
                label,
                style:
                    textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
