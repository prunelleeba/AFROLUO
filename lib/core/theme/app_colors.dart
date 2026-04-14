import 'package:flutter/material.dart';

class AppColors {
  // Couleurs de base
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  
  // Couleurs d'accentuation (Bleus)
  // 0xFF304FFE
  static const Color primaryBlue = Color(0xFF50B0FF); // Le bleu principal du design
  static const Color secondaryBlue = Color(0xFF0572CC);
  static const Color lightBlueAccent = Color(0xFF50B0FF);
  static const Color blueOpacity8 = Color(0x14068FFF); // 068FFF avec 8% d'opacité

  // Échelles de gris / Anthracite
  static const Color grey900 = Color(0xFF181A20); // Utilisé pour le texte ou fond dark
  static const Color grey800 = Color(0xFF1F222A);
  static const Color grey700 = Color(0xFF212121);
  static const Color grey600 = Color(0xFF35383F);
  static const Color grey500 = Color(0xFF424242);
  static const Color grey400 = Color(0xFF616161);
  static const Color grey300 = Color(0xFF9E9E9E);
  static const Color grey200 = Color(0xFFBDBDBD);
  static const Color grey100 = Color(0xFFE0E0E0);
  static const Color grey50 = Color(0xFFFAFAFA);
  
  // Couleurs d'état
  static const Color errorRed = Color(0xFFE12727);
  static const Color successGreen = Color(0xFF31A444);
  static const Color warningOrange = Color(0xFFE55D42);

  // Opacités spécifiques
  static const Color blackOpacity25 = Color(0x40000000); 
  static const Color darkOpacity10 = Color(0x1A181A20); // 181A20 10%
}
