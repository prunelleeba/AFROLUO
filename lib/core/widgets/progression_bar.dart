// Widget personnalise pour afficher un questionnaire avec une barre de progression et des options de réponse
import 'package:flutter/material.dart';

import 'package:afroduo/core/theme/app_colors.dart';
import 'package:afroduo/core/widgets/custom_button.dart';

class QuizLayout extends StatelessWidget {
  final double progress;
  final String progressText;
  final Widget body;
  final VoidCallback onContinue;
  final VoidCallback onBackPressed; // Ajout pour gérer le retour arrière

  const QuizLayout({
    super.key,
    required this.progress,
    required this.progressText,
    required this.body,
    required this.onContinue,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.grey900,
                    ),
                    onPressed: onBackPressed,
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: CameroonGradientProgressBar(value: progress)),
                  const SizedBox(width: 14),
                  Text(
                    progressText.replaceAll(' ', ''),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.grey900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: GradientButton(label: "CONTINUER", onPressed: onContinue),
            ),
          ],
        ),
      ),
    );
  }
}

class CameroonGradientProgressBar extends StatelessWidget {
  final double value;

  const CameroonGradientProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0);

    return SizedBox(
      height: 34,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 8, color: AppColors.grey100),
                FractionallySizedBox(
                  widthFactor: normalizedValue,
                  child: Container(
                    height: 8,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: AppColors.cameroonGradient,
                        stops: [0.0, 0.42, 0.62, 0.86, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment((normalizedValue * 2) - 1, 0),
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackOpacity25,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.star, size: 14, color: AppColors.pureWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
