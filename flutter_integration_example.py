"""
╔══════════════════════════════════════════════════════════════╗
║   GUIDE D'INTÉGRATION FLUTTER → FASTAPI                      ║
║   Fichier : flutter_integration_example.dart                 ║
╚══════════════════════════════════════════════════════════════╝

Ce fichier montre comment Flutter appelle le backend AfroLuo.
Ce N'EST PAS du code à copier directement — c'est un guide.
"""

# ════════════════════════════════════════════════════════════
# DANS FLUTTER : pubspec.yaml
# Ajouter ces dépendances :
# ════════════════════════════════════════════════════════════

FLUTTER_DEPS = """
dependencies:
  http: ^1.2.0              # Appels HTTP vers l'API
  shared_preferences: ^2.2.2 # Stocker le token JWT localement
  provider: ^6.1.1          # Gestion d'état
"""

# ════════════════════════════════════════════════════════════
# DANS FLUTTER : lib/services/api_service.dart
# ════════════════════════════════════════════════════════════

FLUTTER_API_SERVICE = """
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ En développement local (émulateur Android) : 10.0.2.2
  // ⚠️ En développement local (iOS simulator / web) : localhost
  // ⚠️ En production : ton vrai domaine (https://api.afroluo.com)
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // ─────────────────────────────────────────────────────────
  // Récupérer le token stocké localement
  // ─────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ─────────────────────────────────────────────────────────
  // Headers avec authentification JWT
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────────────────
  // INSCRIPTION
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String password,
    required int langueId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nom': nom,
        'email': email,
        'password': password,
        'langue_id': langueId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Sauvegarder le token JWT localement
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      return data;
    } else {
      throw Exception(data['detail'] ?? 'Erreur inscription');
    }
  }

  // ─────────────────────────────────────────────────────────
  // CONNEXION
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access_token']);
      return data;
    } else {
      throw Exception(data['detail'] ?? 'Email ou mot de passe incorrect');
    }
  }

  // ─────────────────────────────────────────────────────────
  // LISTE DES LEÇONS
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getLessons({
    required int langueId,
    int? themeId,
    int page = 1,
  }) async {
    final headers = await getHeaders();
    var url = '$baseUrl/lessons?langue_id=$langueId&page=$page';
    if (themeId != null) url += '&theme_id=$themeId';

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Session expirée. Reconnectez-vous.');
    } else {
      throw Exception('Erreur lors du chargement des leçons');
    }
  }

  // ─────────────────────────────────────────────────────────
  // GÉNÉRER UN QUIZ
  // ─────────────────────────────────────────────────────────
  static Future<List<dynamic>> generateQuiz({
    required int langueId,
    int? themeId,
    int nbQuestions = 10,
  }) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/quiz/generate'),
      headers: headers,
      body: jsonEncode({
        'langue_id': langueId,
        if (themeId != null) 'theme_id': themeId,
        'nb_questions': nbQuestions,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Impossible de générer le quiz');
    }
  }

  // ─────────────────────────────────────────────────────────
  // STATISTIQUES DE L'UTILISATEUR
  // ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMyStats() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/progress/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Impossible de charger les statistiques');
    }
  }

  // ─────────────────────────────────────────────────────────
  // DÉCONNEXION
  // ─────────────────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
"""

print("Guide d'intégration Flutter généré.")
print("Voir le contenu de la variable FLUTTER_API_SERVICE pour le code Dart.")
