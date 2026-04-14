// creer un widget qui contient une option de reponse pour le quiz, avec un drapeau et un texte, et qui change de couleur quand on le selectionne
import 'package:flutter/material.dart';
import 'package:afroduo/core/theme/app_colors.dart';
import 'package:afroduo/features/auth/questions.dart';

Widget buildOptionItem(QuizOption option, bool isSelected, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.grey100,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 30,
            child: Image.asset(option.imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              option.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primaryBlue : AppColors.grey700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primaryBlue),
        ],
      ),
    ),
  );
}
