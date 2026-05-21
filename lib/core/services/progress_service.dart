// lib/core/services/progress_service.dart
import 'package:flutter/foundation.dart';

class ProgressService extends ChangeNotifier {
  final Set<String> _completedLessons = {};
  int _points = 0;

  Set<String> get completedLessons => _completedLessons;
  int get points => _points;

  void completeLesson(String lessonId) {
    if (_completedLessons.add(lessonId)) {
      _points += 10; // 10 points par leçon terminée
      notifyListeners();
    }
  }

  bool isLessonCompleted(String lessonId) => _completedLessons.contains(lessonId);
  double get overallProgress => _completedLessons.isEmpty
      ? 0.0
      : (_completedLessons.length / _allLessons.length).clamp(0.0, 1.0);

  static const List<String> _allLessons = [
    "salutation_id",
    "nombre_id",
    "famille_id",
    "culture_chefs",
    "culture_ngondo",
    "culture_mariage",
    "nombre_ordinaux_id",
    "pronom_id",
    "questions_id",
    "avoir_id",
    "maison_id",
    "habit_id", 
    "corps_id",
    "medecine_id",
    "poste_id",
    "nourriture_id",
    "fruit_id",
    "legume_id",
    "dessert_id",
    "boisson_id",
    "nature_id",
    "animaux_domestiques_id",
    "animaux_sauvages_id",
    "oiseau_id",
    "poisson_id",
    "insectes_id",
    "temps_id",
    "jour_id",
    "mois_id",
    "saison_id",
    "climat_id",
    "phrase_climat_id",
    "ville_id",
    "place_id",
    "transport_id",
    "geographie_id",
    "couleur_id",
    "sport_id",
    "jeu_id",
    "metal_id"
  ];
}