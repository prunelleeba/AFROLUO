import 'package:flutter/material.dart';
import 'package:afroduo/features/splash/data/models/lessonStepData.dart';
import 'package:afroduo/core/theme/app_colors.dart';
import 'package:afroduo/core/widgets/evaluate_widget.dart';

class LessonContentSwitcher extends StatelessWidget {
  final LessonStepData stepData;
  final VoidCallback onAudioPressed;
  final ValueChanged<bool> onCanProceedChanged;

  const LessonContentSwitcher({
    Key? key,
    required this.stepData,
    required this.onAudioPressed,
    required this.onCanProceedChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stepData.kind == StepKind.learning) {
      return _LearningContent(
        stepData: stepData,
        onAudioPressed: onAudioPressed,
      );
    } else {
      return EvaluationWidget(
        pairs: stepData.evaluationPairs!,
        avatarPath: stepData.avatarPath!,
        hintText: stepData.hintText!,
        onCanProceedChanged: onCanProceedChanged,
      );
    }
  }
}

class _LearningContent extends StatelessWidget {
  final LessonStepData stepData;
  final VoidCallback onAudioPressed;

  const _LearningContent({
    required this.stepData,
    required this.onAudioPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                stepData.avatarPath!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              stepData.hintText!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Image.asset(stepData.imagePath!, height: 360, width: 400),
        Text(
          stepData.ewondoWord!,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          stepData.frenchTranslation!,
          style: const TextStyle(fontSize: 24, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 180),
          child: CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.primaryBlue,
            child: IconButton(
              onPressed: onAudioPressed,
              icon: const Icon(Icons.volume_up, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}