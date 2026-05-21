import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // Remplace par l'URL de ton serveur (en local pour le test, puis une URL publique)
  static const String baseUrl = "http://10.36.77.122:8000"; // Android emulator -> localhost

  Future<String> sendMessage(String text) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["response"] as String;
    } else {
      throw Exception("Erreur API : ${response.statusCode}");
    }
  }

  Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/categories"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data["categories"]);
    } else {
      return [];
    }
  }
}