import 'package:flutter/material.dart';

class AppColors {
  // Couleurs de base
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);

  // Couleurs d'accentuation (palette Cameroun/Afrique)
  static const Color primaryBlue = Color(0xFF009A4A);
  static const Color secondaryBlue = Color(0xFFE30613);
  static const Color lightBlueAccent = Color(0xFFFFCD00);
  static const Color blueOpacity8 = Color(0x14009A4A);

  // Échelles de gris / Anthracite
  static const Color grey900 = Color(0xFF1F1712);
  static const Color grey800 = Color(0xFF2E231B);
  static const Color grey700 = Color(0xFF3A2B20);
  static const Color grey600 = Color(0xFF594639);
  static const Color grey500 = Color(0xFF776458);
  static const Color grey400 = Color(0xFF8B7768);
  static const Color grey300 = Color(0xFFB5A89A);
  static const Color grey200 = Color(0xFFD8CEC1);
  static const Color grey100 = Color(0xFFEDE4D6);
  static const Color grey50 = Color(0xFFFFF8EC);

  // Couleurs d'état
  static const Color errorRed = Color(0xFFE30613);
  static const Color successGreen = Color(0xFF009A4A);
  static const Color warningOrange = Color(0xFFFF8C00);
  static const List<Color> cameroonGradient = [
    primaryBlue,
    lightBlueAccent,
    warningOrange,
    secondaryBlue,
    primaryBlue,
  ];

  // Opacités spécifiques
  static const Color blackOpacity25 = Color(0x40000000);
  static const Color darkOpacity10 = Color(0x1A1F1712);
}
