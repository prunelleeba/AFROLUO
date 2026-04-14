
import 'package:flutter/material.dart';


class TestThemePage extends StatelessWidget {
  const TestThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    // On récupère le texte du thème actuel pour l'utiliser facilement
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // La couleur de fond (blanc ou gris sombre) est gérée par le thème
      appBar: AppBar(title: const Text("Mon Design")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. UTILISER LE TEXTE
            Text("Bienvenue !", style: textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              "Apprenez une langue en vous amusant.",
              style: textTheme.bodyMedium, // Gris automatique
            ),

            const SizedBox(height: 40),

            // 2. LES INPUTS (TEXTFIELD)
            // Ils prendront automatiquement les bords arrondis et la couleur de fond du thème
            const TextField(
              decoration: InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Mot de passe",
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),

            const Spacer(),

            // 3. LES BOUTONS
            // Ils seront bleus, arrondis et feront toute la largeur (double.infinity) automatiquement
            ElevatedButton(
              onPressed: () {},
              child: const Text("CONTINUER"),
            ),
            
            const SizedBox(height: 12),
            
            // Un bouton secondaire
            TextButton(
              onPressed: () {},
              child: const Text("J'AI DÉJÀ UN COMPTE"),
            ),
          ],
        ),
      ),
    );
  }
}
