// Widget personnalise pour afficher un questionnaire avec une barre de progression et des options de réponse
import 'package:flutter/material.dart';

import 'package:afroduo/core/theme/app_colors.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.grey700),
          onPressed: onBackPressed, // Utilise la fonction passée en paramètre
        ),
        title: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.grey100,
                  color: AppColors.primaryBlue,
                  minHeight: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(progressText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: body), 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity, // Pour que le bouton prenne toute la largeur
              height: 56, // Hauteur standard pour un bouton pro
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text("CONTINUER"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
