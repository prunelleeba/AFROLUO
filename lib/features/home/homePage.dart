import 'package:afroduo/core/theme/app_colors.dart';
import "package:flutter/material.dart";

import 'package:afroduo/core/widgets/chapterHeader.dart';
import 'package:afroduo/core/widgets/custombottomNavbar.dart';
import 'package:afroduo/core/widgets/topbarWidget.dart';
import 'package:afroduo/features/splash/data/models/lesson.dart';
import 'package:afroduo/core/widgets/lesson_node.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'dart:math';

class HomePage extends StatelessWidget {
  // Ta liste complète transformée en objets LearningStep
  final List<LearningStep> steps = [
  // --- BASES ---
  LearningStep(title: "LES BASES", type: StepType.chapter),
  LearningStep(title: "Salutation", type: StepType.lesson, progress: 1.0, iconData: Icons.handshake),
  LearningStep(title: "Pronoms", type: StepType.lesson, progress: 0.8, iconData: Icons.people_alt),
  LearningStep(title: "Questions", type: StepType.lesson, iconData: Icons.help_center),
  LearningStep(title: "Nombre", type: StepType.lesson, iconData: Icons.format_list_numbered),
  LearningStep(title: "Nombre Ordinaux", type: StepType.lesson, iconData: Icons.looks_one),
  LearningStep(title: "Avoir", type: StepType.lesson, iconData: Icons.inventory_2),

  // --- VIE QUOTIDIENNE ---
   LearningStep(title: "VIE QUOTIDIENNE", type: StepType.chapter),
  LearningStep(title: "Famille", type: StepType.lesson, iconData: Icons.family_restroom),
  LearningStep(title: "Maison", type: StepType.lesson, iconData: Icons.home),
  LearningStep(title: "Habit", type: StepType.lesson, iconData: Icons.checkroom),
  LearningStep(title: "Corps", type: StepType.lesson, iconData: Icons.accessibility_new),
  LearningStep(title: "Médecine", type: StepType.lesson, iconData: Icons.medical_services),
  LearningStep(title: "Poste", type: StepType.lesson, iconData: Icons.local_post_office),

  // --- NOURRITURE ---
   LearningStep(title: "NOURRITURE", type: StepType.chapter),
  LearningStep(title: "Nourriture", type: StepType.lesson, iconData: Icons.restaurant),
  LearningStep(title: "Fruit", type: StepType.lesson, iconData: Icons.apple),
  LearningStep(title: "Légume", type: StepType.lesson, iconData: Icons.eco),
  LearningStep(title: "Dessert", type: StepType.lesson, iconData: Icons.icecream),
  LearningStep(title: "Boisson", type: StepType.lesson, iconData: Icons.local_drink),

  // --- NATURE & ANIMAUX ---
    LearningStep(title: "NATURE & ANIMAUX", type: StepType.chapter),
  LearningStep(title: "Nature", type: StepType.lesson, iconData: Icons.forest),
  LearningStep(title: "Animaux Domestiques", type: StepType.lesson, iconData: Icons.pets),
  LearningStep(title: "Animaux Sauvages", type: StepType.lesson, iconData: Icons.landscape),
  LearningStep(title: "Oiseau", type: StepType.lesson, iconData: Icons.flutter_dash),
  LearningStep(title: "Poisson", type: StepType.lesson, iconData: Icons.set_meal),
  LearningStep(title: "Insectes", type: StepType.lesson, iconData: Icons.bug_report),

  // --- TEMPS ET CLIMAT ---
    LearningStep(title: "TEMPS & CLIMAT", type: StepType.chapter),
  LearningStep(title: "Temps", type: StepType.lesson, iconData: Icons.schedule),
  LearningStep(title: "Jour", type: StepType.lesson, iconData: Icons.calendar_view_day),
  LearningStep(title: "Mois", type: StepType.lesson, iconData: Icons.calendar_month),
  LearningStep(title: "Saison", type: StepType.lesson, iconData: Icons.wb_twilight),
  LearningStep(title: "Climat", type: StepType.lesson, iconData: Icons.cloudy_snowing),
  LearningStep(title: "Phrase Climat", type: StepType.lesson, iconData: Icons.chat_bubble_outline),

  // --- SOCIÉTÉ & DIVERS ---
    LearningStep(title: "SOCIÉTÉ & DIVERS", type: StepType.chapter),
  LearningStep(title: "Ville", type: StepType.lesson, iconData: Icons.location_city),
  LearningStep(title: "Place", type: StepType.lesson, iconData: Icons.place),
  LearningStep(title: "Transport", type: StepType.lesson, iconData: Icons.directions_bus),
  LearningStep(title: "Géographie", type: StepType.lesson, iconData: Icons.public),
  LearningStep(title: "Couleur", type: StepType.lesson, iconData: Icons.palette),
  LearningStep(title: "Sport", type: StepType.lesson, iconData: Icons.sports_soccer),
  LearningStep(title: "Jeu", type: StepType.lesson, iconData: Icons.videogame_asset),
  LearningStep(title: "Métal", type: StepType.lesson, iconData: Icons.architecture),
];

  

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadingEdgeScrollView.fromScrollView(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 1. L'AppBar (TopBarWidget intégré ici)
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              backgroundColor: AppColors.primaryBlue,
              elevation: 1,
              title: TopBarWidget(),
            ),

            // 2. La liste serpentin
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  // Dans le SliverChildBuilderDelegate
                  (context, index) {
                    final step = steps[index];

                    if (step.type == StepType.chapter) {
                      return ChapterHeader(title: step.title);
                    }

                    // Ajuste la fréquence et l'amplitude selon l'effet désiré
                    final double frequency =
                        0.9; // plus élevé = oscillations plus rapides
                    final double amplitude =
                        80.0; // largeur du déplacement horizontal

                    final double offsetX = sin(index * frequency) * amplitude;

                    return RepaintBoundary(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Transform.translate(
                          offset: Offset(offsetX, 0),
                          child: SizedBox(
                            width: 120,
                            child: LessonNode(
                              step: step,
                              onTap: () {
                                // Action au clic
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: steps.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
