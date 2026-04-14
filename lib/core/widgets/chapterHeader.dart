// ignore: file_names
import 'package:afroduo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ChapterHeader extends StatelessWidget {
  final String title;
  const ChapterHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 78, 201, 99),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
