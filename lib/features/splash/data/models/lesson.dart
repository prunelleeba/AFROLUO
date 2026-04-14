
import 'package:flutter/material.dart';

enum StepType { chapter, lesson }

class LearningStep {
  final String title;
  final StepType type;
  final double progress;
  final String? imagePath;   // pour une image depuis les assets
  final IconData? iconData;  // pour une icône Material

  LearningStep({
    required this.title,
    required this.type,
    this.progress = 0.0,
    this.imagePath,
    this.iconData,
  });
}

