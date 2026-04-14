import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  // --- THÈME CLAIR ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        onPrimary: AppColors.pureWhite,
        surface: AppColors.pureWhite,
        onSurface: AppColors.grey900,
        error: AppColors.errorRed,
        outline: AppColors.grey100,
      ),
      textTheme: _buildTextTheme(Brightness.light), // Utilise les styles de texte personnalisés
      scaffoldBackgroundColor: AppColors.pureWhite,
      
      // Configuration des boutons (Bords arrondis comme sur ton image)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.pureWhite,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
      ),
      
      // Configuration des champs de texte (Input)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.grey100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  // --- THÈME SOMBRE ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        onPrimary: AppColors.pureWhite,
        surface: AppColors.grey900, // Fond des cartes/modals
        onSurface: AppColors.pureWhite,
        error: AppColors.errorRed,
      ),
      textTheme: _buildTextTheme(Brightness.dark), // Utilise les styles de texte personnalisés
      scaffoldBackgroundColor: AppColors.grey800, // Fond principal sombre
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.pureWhite,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }


static TextTheme _buildTextTheme(Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  final Color primaryTextColor = isDark ? AppColors.pureWhite : AppColors.grey700; // 212121
  final Color secondaryTextColor = isDark ? AppColors.grey300 : AppColors.grey400; // 616161

  return TextTheme(
    // Titres principaux (Grandes questions/titres d'écrans)
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800, // Très gras comme Duolingo
      color: primaryTextColor,
      letterSpacing: -0.5,
    ),
    
    // Titres de section
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: primaryTextColor,
    ),

    // Texte principal (Le corps du texte)
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: primaryTextColor,
    ),

    // Texte secondaire / Instructions (Plus petit et gris)
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: secondaryTextColor,
    ),

    // Boutons et petits labels
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700, // Gras pour les boutons
      letterSpacing: 1.2,
      color: isDark ? AppColors.pureWhite : AppColors.primaryBlue,
    ),

    // Légendes d'images ou petits textes d'aide
    bodySmall: TextStyle(
      fontSize: 12,
      color: secondaryTextColor,
    ),
  );
}


}
