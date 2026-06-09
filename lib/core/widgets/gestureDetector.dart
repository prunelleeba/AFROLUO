// creer un widget qui contient une option de reponse pour le quiz, avec un drapeau et un texte, et qui change de couleur quand on le selectionne
import 'package:flutter/material.dart';
import 'package:afroduo/core/theme/app_colors.dart';
import 'package:afroduo/features/auth/questions.dart';

Widget buildOptionItem(QuizOption option, bool isSelected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      constraints: const BoxConstraints(minHeight: 68),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFBDF4DA) : AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF8AE9BC) : AppColors.pureWhite,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1F1712),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(option.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              option.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.grey900 : AppColors.grey700,
              ),
            ),
          ),
          if (isSelected)
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.lightBlueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.grey900,
                size: 26,
              ),
            ),
        ],
      ),
    ),
  );
}
