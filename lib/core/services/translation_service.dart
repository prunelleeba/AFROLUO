import 'dart:async';

import 'package:afroduo/features/splash/data/models/translation.dart';


class TranslationService {
  // Méthode à appeler – pour l'instant, simulation
  Future<TranslationResult> translate(String query) async {
    // Simulation réseau
    await Future.delayed(const Duration(seconds: 1));
    // Retour mocké
    return TranslationResult(
      ewondo: "M'a ke nda-ekóló",
      explanation: "On utilise l'expression 'M'a ke' pour dire 'je vais', suivi de 'nda-ekóló' (école).",
      audioUrl: "assets/audio/ew/ecole.mp3",
    );
  }
}