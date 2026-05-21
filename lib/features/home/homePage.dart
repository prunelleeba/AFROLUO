import 'package:afroduo/core/theme/app_colors.dart';
import "package:flutter/material.dart";
import 'package:afroduo/core/widgets/chapterHeader.dart';
import 'package:afroduo/core/widgets/custombottomNavbar.dart';
import 'package:afroduo/core/widgets/topbarWidget.dart';
import 'package:afroduo/features/splash/data/models/lesson.dart';
import 'package:afroduo/core/widgets/lesson_node.dart';
import 'package:afroduo/features/lessons/lessonPage.dart';   // ← FIX 5 : import correct
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // Set des leçons terminées
  final Set<String> _completedLessons = {};

  // ─── FIX 1 : UNE SEULE déclaration de _scrollController ───────
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<String> _currentChapterNotifier =
      ValueNotifier<String>("LES BASES");
  final ValueNotifier<Color> _currentChapterColorNotifier =
      ValueNotifier<Color>(const Color.fromARGB(255, 78, 201, 99));

  final Map<String, Color> chapterColors = {
    "LES BASES":        const Color.fromARGB(255, 78, 201, 99),
    "VIE QUOTIDIENNE":  Colors.orange,
    "NOURRITURE":       const Color.fromARGB(255, 99, 82, 255),
    "NATURE & ANIMAUX": Colors.green,
    "TEMPS & CLIMAT":   const Color.fromARGB(255, 225, 228, 94),
    "SOCIÉTÉ & DIVERS": Colors.purple,
  };

  // ─── FIX 2 : liste nommée `_steps` partout (plus de `steps`) ──
  final List<LearningStep> _steps = [
    // --- BASES ---
    LearningStep(id: "bases_id",          title: "LES BASES",          type: StepType.chapter),
    LearningStep(id: "salutation_id",     title: "Salutation",         type: StepType.lesson, iconData: Icons.handshake),
    LearningStep(id: "nombre_id",         title: "Nombre",             type: StepType.lesson, iconData: Icons.format_list_numbered),
    LearningStep(id: "famille_id",        title: "Famille",            type: StepType.lesson, iconData: Icons.family_restroom),
    LearningStep(id: "culture_chefs",     title: "Chefs traditionnels",type: StepType.lesson, iconData: Icons.account_balance),
    LearningStep(id: "culture_ngondo",    title: "Le Ngondo",          type: StepType.lesson, iconData: Icons.water),
    LearningStep(id: "culture_mariage",   title: "Mariage coutumier",  type: StepType.lesson, iconData: Icons.favorite),
    LearningStep(id: "nombre_ordinaux_id",title: "Nombre Ordinaux",    type: StepType.lesson, iconData: Icons.looks_one),
    LearningStep(id: "pronom_id",         title: "Pronoms",            type: StepType.lesson, iconData: Icons.people_alt),
    LearningStep(id: "questions_id",      title: "Questions",          type: StepType.lesson, iconData: Icons.help_center),
    LearningStep(id: "avoir_id",          title: "Avoir",              type: StepType.lesson, iconData: Icons.inventory_2),

    // --- VIE QUOTIDIENNE ---
    LearningStep(id: "vie_quotidienne_id",          title: "VIE QUOTIDIENNE", type: StepType.chapter),
    LearningStep(id: "maison_id", title: "Maison",   type: StepType.lesson, iconData: Icons.home),
    LearningStep(id: "habit_id",  title: "Habit",    type: StepType.lesson, iconData: Icons.checkroom),
    LearningStep(id: "corps_id",  title: "Corps",    type: StepType.lesson, iconData: Icons.accessibility_new),
    LearningStep(id: "medecine_id",title: "Médecine",type: StepType.lesson, iconData: Icons.medical_services),
    LearningStep(id: "poste_id",  title: "Poste",    type: StepType.lesson, iconData: Icons.local_post_office),

    // --- NOURRITURE ---
    LearningStep(id: "nourriture_id", title: "Nourriture", type: StepType.chapter),
    LearningStep(id: "nourriture_id", title: "Nourriture", type: StepType.lesson, iconData: Icons.restaurant),
    LearningStep(id: "fruit_id",      title: "Fruit",      type: StepType.lesson, iconData: Icons.apple),
    LearningStep(id: "legume_id",     title: "Légume",     type: StepType.lesson, iconData: Icons.eco),
    LearningStep(id: "dessert_id",    title: "Dessert",    type: StepType.lesson, iconData: Icons.icecream),
    LearningStep(id: "boisson_id",    title: "Boisson",    type: StepType.lesson, iconData: Icons.local_drink),

    // --- NATURE & ANIMAUX ---
    LearningStep(id: "nature_animaux_id",      title: "NATURE & ANIMAUX",    type: StepType.chapter),
    LearningStep(id: "nature_id",             title: "Nature",              type: StepType.lesson, iconData: Icons.forest),
    LearningStep(id: "animaux_domestiques_id",title: "Animaux Domestiques", type: StepType.lesson, iconData: Icons.pets),
    LearningStep(id: "animaux_sauvages_id",   title: "Animaux Sauvages",    type: StepType.lesson, iconData: Icons.landscape),
    LearningStep(id: "oiseau_id",             title: "Oiseau",              type: StepType.lesson, iconData: Icons.flutter_dash),
    LearningStep(id: "poisson_id",            title: "Poisson",             type: StepType.lesson, iconData: Icons.set_meal),
    LearningStep(id: "insectes_id",           title: "Insectes",            type: StepType.lesson, iconData: Icons.bug_report),

    // --- TEMPS ET CLIMAT ---
    LearningStep(id: "temps_id",                title: "TEMPS & CLIMAT", type: StepType.chapter),
    LearningStep(id: "temps_id",        title: "Temps",          type: StepType.lesson, iconData: Icons.schedule),
    LearningStep(id: "jour_id",         title: "Jour",           type: StepType.lesson, iconData: Icons.calendar_view_day),
    LearningStep(id: "mois_id",         title: "Mois",           type: StepType.lesson, iconData: Icons.calendar_month),
    LearningStep(id: "saison_id",       title: "Saison",         type: StepType.lesson, iconData: Icons.wb_twilight),
    LearningStep(id: "climat_id",       title: "Climat",         type: StepType.lesson, iconData: Icons.cloudy_snowing),
    LearningStep(id: "phrase_climat_id",title: "Phrase Climat",  type: StepType.lesson, iconData: Icons.chat_bubble_outline),

    // --- SOCIÉTÉ & DIVERS ---
    LearningStep(id: "societe_divers_id",             title: "SOCIÉTÉ & DIVERS", type: StepType.chapter),
    LearningStep(id: "ville_id",     title: "Ville",      type: StepType.lesson, iconData: Icons.location_city),
    LearningStep(id: "place_id",     title: "Place",      type: StepType.lesson, iconData: Icons.place),
    LearningStep(id: "transport_id", title: "Transport",  type: StepType.lesson, iconData: Icons.directions_bus),
    LearningStep(id: "geographie_id",title: "Géographie", type: StepType.lesson, iconData: Icons.public),
    LearningStep(id: "couleur_id",   title: "Couleur",    type: StepType.lesson, iconData: Icons.palette),
    LearningStep(id: "sport_id",     title: "Sport",      type: StepType.lesson, iconData: Icons.sports_soccer),
    LearningStep(id: "jeu_id",       title: "Jeu",        type: StepType.lesson, iconData: Icons.videogame_asset),
    LearningStep(id: "metal_id",     title: "Métal",      type: StepType.lesson, iconData: Icons.architecture),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateCurrentChapter);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCurrentChapter);
    _scrollController.dispose();
    _currentChapterNotifier.dispose();
    _currentChapterColorNotifier.dispose();
    super.dispose();
  }

  // ─── Chapitre courant selon le scroll ─────────────────────────
  // On travaille directement sur _steps (avec chapitres) pour
  // trouver quel chapitre précède la leçon visible à l'écran.
  String _getChapterForStep(int stepIndex) {
    for (int i = stepIndex; i >= 0; i--) {
      if (_steps[i].type == StepType.chapter) return _steps[i].title;
    }
    return "LES BASES";
  }

  void _updateCurrentChapter() {
    if (!_scrollController.hasClients) return;
    const double itemHeight = 130.0;
    int estimated = (_scrollController.offset / itemHeight).floor().clamp(0, _steps.length - 1);
    final String chapter = _getChapterForStep(estimated);
    if (_currentChapterNotifier.value != chapter) {
      _currentChapterNotifier.value = chapter;
      _currentChapterColorNotifier.value =
          chapterColors[chapter] ?? const Color.fromARGB(255, 78, 201, 99);
    }
  }

  // ─── FIX 2+3 : _isLocked utilise bien `_steps` ────────────────
  // IMPORTANT : index ici est l'index dans _steps (avec chapitres)
  bool _isLocked(int stepsIndex) {
    if (_steps[stepsIndex].type == StepType.chapter) return false;
    for (int i = stepsIndex - 1; i >= 0; i--) {
      if (_steps[i].type == StepType.lesson) {
        return !_completedLessons.contains(_steps[i].title);
      }
    }
    return false; // première leçon → toujours débloquée
  }

  double _progressOf(LearningStep step) {
    if (_completedLessons.contains(step.title)) return 1.0;
    return 0.0;
  }

  // ─── FIX 5 : Navigator.push<bool> pour récupérer le résultat ──
  Future<void> _openLesson(LearningStep step) async {
    if (step.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("\"${step.title}\" arrive bientôt !"),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    final bool? completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => LessonPage(lessonId: step.id)),
    );
    if (completed == true) {
      setState(() => _completedLessons.add(step.title));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadingEdgeScrollView.fromScrollView(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [

            // ── AppBar avec image de fond ────────────────────────
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const TopBarWidget(),
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/logo/afrique.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ── Header de chapitre dynamique ────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _ChapterHeaderDelegate(
                titleNotifier: _currentChapterNotifier,
                colorNotifier: _currentChapterColorNotifier,
              ),
            ),

            // ── Liste des étapes (chapitres + leçons) ────────────
            // FIX 4 : on itère sur _steps (pas lessonOnlySteps)
            // pour que les index de _isLocked() soient corrects.
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final step = _steps[index];

                    // Affiche le ChapterHeader inline dans la liste
                    if (step.type == StepType.chapter) {
                      // On retourne null pour masquer les séparateurs de chapitre
                      // (le chapitre courant est affiché dans le header persistant)
                      return const SizedBox.shrink();
                    }

                    final bool locked = _isLocked(index); // ← index = index dans _steps ✓

                    final double offsetX = sin(index * 0.9) * 80.0;

                    final LearningStep stepWithProgress = LearningStep(
                      id: step.id,
                      title: step.title,
                      type: step.type,
                      iconData: step.iconData,
                      imagePath: step.imagePath,
                      progress: _progressOf(step),
                    );

                    return RepaintBoundary(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Transform.translate(
                          offset: Offset(offsetX, 0),
                          child: SizedBox(
                            width: 120,
                            child: LessonNode(
                              step: stepWithProgress,
                              locked: locked,
                              // ── FIX 3+5 : appelle _openLesson ──
                              onTap: locked ? null : () => _openLesson(step),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _steps.length,
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

// ─── Délégué pour le header persistant ───────────────────────────
// FIX 6 : ChapterHeader ne reçoit que `title` (pas backgroundColor)
// On applique la couleur via le Container parent.
class _ChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final ValueNotifier<String> titleNotifier;
  final ValueNotifier<Color> colorNotifier;

  _ChapterHeaderDelegate({
    required this.titleNotifier,
    required this.colorNotifier,
  });

  @override double get minExtent => 60.0;
  @override double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ValueListenableBuilder<String>(
      valueListenable: titleNotifier,
      builder: (context, title, _) {
        return ValueListenableBuilder<Color>(
          valueListenable: colorNotifier,
          builder: (context, color, _) {
            return Container(
              color: Colors.white,
              // ── FIX 6 : on enveloppe ChapterHeader dans un
              // Container coloré au lieu de lui passer backgroundColor
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,                          // ← couleur ici
                  borderRadius: BorderRadius.circular(15),
                ),
                width: double.infinity,
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant _ChapterHeaderDelegate old) =>
      old.titleNotifier != titleNotifier || old.colorNotifier != colorNotifier;
}









// import 'package:afroduo/core/theme/app_colors.dart';
// import "package:flutter/material.dart";
// import 'package:afroduo/core/widgets/chapterHeader.dart';
// import 'package:afroduo/core/widgets/custombottomNavbar.dart';
// import 'package:afroduo/core/widgets/topbarWidget.dart';
// import 'package:afroduo/features/splash/data/models/lesson.dart';
// import 'package:afroduo/core/widgets/lesson_node.dart';
// import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
// import 'dart:math';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // Liste complète (inclut les chapitres, mais on les filtrera pour l'affichage)
//   final List<LearningStep> steps = [
//     // --- BASES ---
//     LearningStep(id: "bases_id", title: "LES BASES", type: StepType.chapter),
//     LearningStep(id: "salutation_id", title: "Salutation", type: StepType.lesson, progress: 1.0, iconData: Icons.handshake),
//     LearningStep(id: "nombre_id", title: "Nombre", type: StepType.lesson, iconData: Icons.format_list_numbered),
//     LearningStep(id: "famille_id", title: "Famille", type: StepType.lesson, iconData: Icons.family_restroom),
//     LearningStep(id: "culture_chefs",title: "Chefs traditionnels",type: StepType.lesson, iconData: Icons.account_balance),
//     LearningStep(id: "culture_ngondo",title: "Le Ngondo",type: StepType.lesson,iconData: Icons.water),
//     LearningStep(id: "culture_mariage",title: "Mariage coutumier",type: StepType.lesson,iconData: Icons.favorite,),
//     LearningStep(id: "nombre_ordinaux_id", title: "Nombre Ordinaux", type: StepType.lesson, iconData: Icons.looks_one),
//     LearningStep(id: "pronom_id", title: "Pronoms", type: StepType.lesson, progress: 0.8, iconData: Icons.people_alt),
//     LearningStep(id: "questions_id", title: "Questions", type: StepType.lesson, iconData: Icons.help_center),
//     LearningStep(id: "avoir_id", title: "Avoir", type: StepType.lesson, iconData: Icons.inventory_2),

//     // --- VIE QUOTIDIENNE ---vie_quotidienne_id
//     LearningStep(id: "", title: "VIE QUOTIDIENNE", type: StepType.chapter),
//     LearningStep(id: "maison_id", title: "Maison", type: StepType.lesson, iconData: Icons.home),
//     LearningStep(id: "habit_id", title: "Habit", type: StepType.lesson, iconData: Icons.checkroom),
//     LearningStep(id: "corps_id", title: "Corps", type: StepType.lesson, iconData: Icons.accessibility_new),
//     LearningStep(id: "medecine_id", title: "Médecine", type: StepType.lesson, iconData: Icons.medical_services),
//     LearningStep(id: "poste_id", title: "Poste", type: StepType.lesson, iconData: Icons.local_post_office),

//     // --- NOURRITURE ---nourriture_id
//     LearningStep(id: "", title: "NOURRITURE", type: StepType.chapter),
//     LearningStep(id: "nourriture_id", title: "Nourriture", type: StepType.lesson, iconData: Icons.restaurant),
//     LearningStep(id: "fruit_id", title: "Fruit", type: StepType.lesson, iconData: Icons.apple),
//     LearningStep(id: "legume_id", title: "Légume", type: StepType.lesson, iconData: Icons.eco),
//     LearningStep(id: "dessert_id", title: "Dessert", type: StepType.lesson, iconData: Icons.icecream),
//     LearningStep(id: "boisson_id", title: "Boisson", type: StepType.lesson, iconData: Icons.local_drink),

//     // --- NATURE & ANIMAUX ---nature_animaux_id
//     LearningStep(id: "", title: "NATURE & ANIMAUX", type: StepType.chapter),
//     LearningStep(id: "nature_id", title: "Nature", type: StepType.lesson, iconData: Icons.forest),
//     LearningStep(id: "animaux_domestiques_id", title: "Animaux Domestiques", type: StepType.lesson, iconData: Icons.pets),
//     LearningStep(id: "animaux_sauvages_id", title: "Animaux Sauvages", type: StepType.lesson, iconData: Icons.landscape),
//     LearningStep(id: "oiseau_id", title: "Oiseau", type: StepType.lesson, iconData: Icons.flutter_dash),
//     LearningStep(id: "poisson_id", title: "Poisson", type: StepType.lesson, iconData: Icons.set_meal),
//     LearningStep(id: "insectes_id", title: "Insectes", type: StepType.lesson, iconData: Icons.bug_report),

//     // --- TEMPS ET CLIMAT ---temps_climat_id"
//     LearningStep(id: "", title: "TEMPS & CLIMAT", type: StepType.chapter),
//     LearningStep(id: "temps_id", title: "Temps", type: StepType.lesson, iconData: Icons.schedule),
//     LearningStep(id: "jour_id", title: "Jour", type: StepType.lesson, iconData: Icons.calendar_view_day),
//     LearningStep(id: "mois_id", title: "Mois", type: StepType.lesson, iconData: Icons.calendar_month),
//     LearningStep(id: "saison_id", title: "Saison", type: StepType.lesson, iconData: Icons.wb_twilight),
//     LearningStep(id: "climat_id", title: "Climat", type: StepType.lesson, iconData: Icons.cloudy_snowing),
//     LearningStep(id: "phrase_climat_id", title: "Phrase Climat", type: StepType.lesson, iconData: Icons.chat_bubble_outline),

//     // --- SOCIÉTÉ & DIVERS --- societe_divers_id
//     LearningStep(id: "", title: "SOCIÉTÉ & DIVERS", type: StepType.chapter),
//     LearningStep(id: "ville_id", title: "Ville", type: StepType.lesson, iconData: Icons.location_city),
//     LearningStep(id: "place_id", title: "Place", type: StepType.lesson, iconData: Icons.place),
//     LearningStep(id: "transport_id", title: "Transport", type: StepType.lesson, iconData: Icons.directions_bus),
//     LearningStep(id: "geographie_id", title: "Géographie", type: StepType.lesson, iconData: Icons.public),
//     LearningStep(id: "couleur_id", title: "Couleur", type: StepType.lesson, iconData: Icons.palette),
//     LearningStep(id: "sport_id", title: "Sport", type: StepType.lesson, iconData: Icons.sports_soccer),
//     LearningStep(id: "jeu_id", title: "Jeu", type: StepType.lesson, iconData: Icons.videogame_asset),
//     LearningStep(id: "metal_id", title: "Métal", type: StepType.lesson, iconData: Icons.architecture),

//     // -- CULTURE CAMEROUNAISE---
//     // LearningStep(id: "culture_id", title: "CULTURE CAMEROUNAISE", type: StepType.chapter),
    
//   ];

//   // Liste filtrée (seulement les leçons, sans les chapitres)
//   late final List<LearningStep> lessonOnlySteps = steps.where((s) => s.type == StepType.lesson).toList();

//   final ScrollController _scrollController = ScrollController();
//   final ValueNotifier<String> _currentChapterNotifier = ValueNotifier<String>("LES BASES");
//   final ValueNotifier<Color> _currentChapterColorNotifier = ValueNotifier<Color>(const Color.fromARGB(255, 78, 201, 99));

//   // Couleurs pour chaque chapitre (peut être enrichi)
//   final Map<String, Color> chapterColors = {
//     "LES BASES": const Color.fromARGB(255, 78, 201, 99),
//     "VIE QUOTIDIENNE": Colors.orange,
//     "NOURRITURE": const Color.fromARGB(255, 99, 82, 255),
//     "NATURE & ANIMAUX": Colors.green,
//     "TEMPS & CLIMAT": const Color.fromARGB(255, 225, 228, 94),
//     "SOCIÉTÉ & DIVERS": Colors.purple,
//   };

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_updateCurrentChapter);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_updateCurrentChapter);
//     _scrollController.dispose();
//     _currentChapterNotifier.dispose();
//     _currentChapterColorNotifier.dispose();
//     super.dispose();
//   }

//   // Détermine le chapitre correspondant à un index de leçon
//   String _getChapterForLessonIndex(int lessonIndex) {
//     // Trouver le chapitre précédant cette leçon dans la liste originale
//     int originalIndex = steps.indexOf(lessonOnlySteps[lessonIndex]);
//     for (int i = originalIndex; i >= 0; i--) {
//       if (steps[i].type == StepType.chapter) {
//         return steps[i].title;
//       }
//     }
//     return "LES BASES"; // fallback
//   }

//   void _updateCurrentChapter() {
//     if (!_scrollController.hasClients) return;

//     // Trouver le premier élément de leçon visible
//     final double scrollOffset = _scrollController.offset;
//     // Estimation approximative de l'index visible (améliorable avec RenderBox)
//     // On peut utiliser le package scrollable_positioned_list pour plus de précision,
//     // mais on va faire simple : on considère que chaque leçon occupe ~130px de hauteur.
//     const double itemHeight = 130.0;
//     int estimatedIndex = (scrollOffset / itemHeight).floor();
//     if (estimatedIndex < 0) estimatedIndex = 0;
//     if (estimatedIndex >= lessonOnlySteps.length) estimatedIndex = lessonOnlySteps.length - 1;

//     final String chapter = _getChapterForLessonIndex(estimatedIndex);
//     if (_currentChapterNotifier.value != chapter) {
//       _currentChapterNotifier.value = chapter;
//       _currentChapterColorNotifier.value = chapterColors[chapter] ?? Colors.green;
//     }
//   }

//   // Vérrouillage (comme avant)
//   bool _isLessonLocked(int index) {
//     if (index == 0) return false;
//     final prevLesson = lessonOnlySteps[index - 1];
//     return prevLesson.progress < 1.0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: FadingEdgeScrollView.fromScrollView(
//         child: CustomScrollView(
//           controller: _scrollController,
//           slivers: [
//             // AppBar existante
//             SliverAppBar(
//   automaticallyImplyLeading: false,
//   pinned: true,
//   backgroundColor: Colors.transparent,   // indispensable pour voir l'image
//   elevation: 0,                           // si tu veux enlever l'ombre
//   title: TopBarWidget(),
//   flexibleSpace: Container(
//     decoration: BoxDecoration(
//       image: DecorationImage(
//         image: AssetImage("assets/images/logo/afrique.jpg"), // ton image
//         fit: BoxFit.cover,                  // couvre tout l'espace
//       ),
//     ),
//   ),
// ),
//             // SliverAppBar(
//             //   automaticallyImplyLeading: false,
//             //   pinned: true,
//             //   backgroundColor: Colors.transparent,
//             //   elevation: 2,
//             //   title: TopBarWidget(),
//             // ),

//             // Nouveau header dynamique de chapitre
//             SliverPersistentHeader(
//               pinned: true,
//               delegate: _ChapterHeaderDelegate(
//                 titleNotifier: _currentChapterNotifier,
//                 colorNotifier: _currentChapterColorNotifier,
//               ),
//             ),

//             // Liste des leçons (sans les chapitres)
//             SliverPadding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               sliver: SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final step = lessonOnlySteps[index];
//                     final bool locked = _isLessonLocked(index);

//                     final double frequency = 0.9;
//                     final double amplitude = 80.0;
//                     final double offsetX = sin(index * frequency) * amplitude;

//                     return RepaintBoundary(
//                       child: Padding(
//                         padding: const EdgeInsets.only(bottom: 25),
//                         child: Transform.translate(
//                           offset: Offset(offsetX, 0),
//                           child: SizedBox(
//                             width: 120,
//                             child: LessonNode(
//                               step: step,
//                               locked: locked,
//                               onTap: locked ? null : () {
//                                 Navigator.pushNamed(context, '/lesson', arguments: step.id);
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   childCount: lessonOnlySteps.length,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: const CustomBottomNav(),
//     );
//   }
// }

// // Délégué pour le header persistant
// class _ChapterHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final ValueNotifier<String> titleNotifier;
//   final ValueNotifier<Color> colorNotifier;

//   _ChapterHeaderDelegate({
//     required this.titleNotifier,
//     required this.colorNotifier,
//   });

//   @override
//   double get minExtent => 60.0;
//   @override
//   double get maxExtent => 60.0;

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return ValueListenableBuilder<String>(
//       valueListenable: titleNotifier,
//       builder: (context, title, _) {
//         return ValueListenableBuilder<Color>(
//           valueListenable: colorNotifier,
//           builder: (context, color, _) {
//             return Container(
//               color: Colors.white, // fond blanc pour éviter superposition
//               child: ChapterHeader(
//                 title: title,
//                 backgroundColor: color,
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   bool shouldRebuild(covariant _ChapterHeaderDelegate oldDelegate) {
//     return oldDelegate.titleNotifier != titleNotifier || oldDelegate.colorNotifier != colorNotifier;
//   }
// }

