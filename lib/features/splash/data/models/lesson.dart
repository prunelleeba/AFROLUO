// lesson.dart
import 'package:flutter/material.dart';

enum StepType { chapter, lesson }

class LearningStep {
  final String id;
  final String title;
  final StepType type;
  final double progress;
  final String? imagePath;
  final IconData? iconData;

  LearningStep({
    required this.id,
    required this.title,
    required this.type,
    this.progress = 0.0,
    this.imagePath,
    this.iconData,
  });

  // Pour faciliter l'affichage de l'icône effective (en fonction du verrouillage)
  IconData get displayIcon {
    if (type == StepType.chapter) return Icons.label; // fallback
    return iconData ?? Icons.star;
  }
}


// import 'package:flutter/material.dart';

// enum StepType { chapter, lesson }

// class LearningStep {
//   final String title;
//   final StepType type;
//   final double progress;
//   final String? imagePath;   // pour une image depuis les assets
//   final IconData? iconData;  // pour une icône Material

//   LearningStep({
//     required this.title,
//     required this.type,
//     this.progress = 0.0,
//     this.imagePath,
//     this.iconData,
//   });
// }

