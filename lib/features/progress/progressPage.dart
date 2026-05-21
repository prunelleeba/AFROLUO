// lib/features/progress/progress_page.dart
import 'package:afroduo/core/widgets/custombottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:afroduo/core/theme/app_colors.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Simulons des données de progression (à remplacer par le vrai service)
  final Map<String, double> chapterProgress = {
    "Les bases": 0.8,
    "Vie quotidienne": 0.6,
    "Nourriture": 0.4,
    "Nature & Animaux": 0.2,
    "Temps & Climat": 0.0,
    "Société & Divers": 0.0,
    "Culture Camerounaise": 0.1,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overall = chapterProgress.values.fold<double>(0.0, (sum, p) => sum + p) / chapterProgress.length;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Ma Progression"),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _OverallProgress(progress: overall, animation: _animation),
            const SizedBox(height: 30),
            ...chapterProgress.entries.map((entry) {
              return _ChapterProgressBar(title: entry.key, progress: entry.value);
            }),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(),
    );
  }
}

class _OverallProgress extends StatelessWidget {
  final double progress;
  final Animation<double> animation;
  const _OverallProgress({required this.progress, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress * animation.value,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    color: AppColors.primaryBlue,
                  ),
                  Center(
                    child: Text(
                      "${(progress * animation.value * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Progrès total",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}

class _ChapterProgressBar extends StatelessWidget {
  final String title;
  final double progress;
  const _ChapterProgressBar({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}