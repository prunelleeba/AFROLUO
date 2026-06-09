// ignore: file_names
import 'package:flutter/material.dart';
import 'package:afroduo/features/auth/questions.dart';
import 'package:afroduo/core/widgets/progression_bar.dart';
import 'package:afroduo/core/widgets/gestureDetector.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<Question> questions = [
    Question(
      title: "Quelle langue voulez-vous apprendre ?",
      image: "assets/images/avatars/lion_moulle.png",
      options: [
        QuizOption(
          label: "Ewondo",
          imagePath: "assets/images/flags/Cameroon.png",
        ),
        QuizOption(
          label: "Ndemli",
          imagePath: "assets/images/flags/Cameroon.png",
        ),
        QuizOption(
          label: "Duala",
          imagePath: "assets/images/flags/Cameroon.png",
        ),
        QuizOption(
          label: "Ngiemboon",
          imagePath: "assets/images/flags/Cameroon.png",
        ),
        QuizOption(
          label: "Yemba",
          imagePath: "assets/images/flags/Cameroon.png",
        ),
        QuizOption(
          label: "Foufoulde",
          imagePath: "assets/images/flags/Cameroon.png",
        ),
      ],
    ),
    Question(
      title: "Quelle langue voulez-vous utilisez pour Afroluo ?",
      image: "assets/images/avatars/lion_moulle.png",
      options: [
        QuizOption(
          label: "English",
          imagePath: "assets/images/flags/Engleterre.png",
        ),
        QuizOption(
          label: "Français",
          imagePath: "assets/images/flags/france.png",
        ),
      ],
    ),
    Question(
      title: "Quelle est votre niveau en Ewondo ?",
      image: "assets/images/avatars/lion_moulle.png",
      options: [
        QuizOption(
          label: "Debutant",
          imagePath: "assets/images/illustrations/debutant.png",
        ),
        QuizOption(
          label: "Intermediaire",
          imagePath: "assets/images/illustrations/intermediaire.png",
        ),
        QuizOption(
          label: "Avancé",
          imagePath: "assets/images/illustrations/avance.png",
        ),
        QuizOption(
          label: "Expert",
          imagePath: "assets/images/illustrations/expert.png",
        ),
      ],
    ),
    Question(
      title: "Pourquoi apprendre l'Ewondo ?",
      image: "assets/images/avatars/lion_moulle.png",
      options: [
        QuizOption(
          label: "Voyage",
          imagePath: "assets/images/illustrations/avion.png",
        ),
        QuizOption(
          label: "Education",
          imagePath: "assets/images/illustrations/education.png",
        ),
        QuizOption(
          label: "Culture",
          imagePath: "assets/images/illustrations/culture.png",
        ),
        QuizOption(
          label: "Job",
          imagePath: "assets/images/illustrations/malette.png",
        ),
        QuizOption(
          label: "Fun",
          imagePath: "assets/images/illustrations/fun.png",
        ),
      ],
    ),
    Question(
      title: "Quel est ton principal challenge dans l'apprentissage ?",
      image: "assets/images/avatars/lion_moulle.png",
      options: [
        QuizOption(
          label: "Avoir du Temps",
          imagePath: "assets/images/illustrations/avion.png",
        ),
        QuizOption(
          label: "Rester motiver",
          imagePath: "assets/images/illustrations/education.png",
        ),
        QuizOption(
          label: "la grammaire",
          imagePath: "assets/images/illustrations/culture.png",
        ),
        QuizOption(
          label: "pratiquer avec quelqu'un",
          imagePath: "assets/images/illustrations/malette.png",
        ),
        QuizOption(
          label: "Difficulter à retenir",
          imagePath: "assets/images/illustrations/fun.png",
        ),
      ],
    ),
  ];

  int currentIndex = 0; // L'index de la question actuelle
  int? selectedOptionIndex; // Stocke l'index cliqué (null au début)

  @override
  Widget build(BuildContext context) {
    // Calcul automatique pour la barre de progression
    double currentProgress = (currentIndex + 1) / questions.length;
    String currentText = "${currentIndex + 1} / ${questions.length}";

    return QuizLayout(
      progress: currentProgress,
      progressText: currentText,

      // LOGIQUE DU BOUTON RETOUR
      onBackPressed: () {
        if (currentIndex > 0) {
          setState(() {
            currentIndex--;
            selectedOptionIndex = null;
          }); // Recule d'une question
        } else {
          Navigator.pop(context); // Quitte le quiz si on est à la première
        }
      },

      // LOGIQUE DU BOUTON CONTINUER
      onContinue: () {
        if (currentIndex < questions.length - 1) {
          setState(() {
            currentIndex++;
            selectedOptionIndex = null;
          }); // Avance à la question suivante
        } else {
          // Naviguer vers la page de fin (Succès)
          Navigator.pushNamed(context, '/register');
        }
      },

      // CONTENU DU MILIEU (Change selon currentIndex)
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [Color(0xFFFFFDF8), Color(0xFFFFF8EC)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 98),
                padding: const EdgeInsets.fromLTRB(18, 82, 18, 22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F1F1712),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      questions[currentIndex].title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1.18,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    // On génère la liste des options dynamiquement
                    ...List.generate(questions[currentIndex].options.length, (
                      index,
                    ) {
                      final option = questions[currentIndex].options[index];

                      return buildOptionItem(
                        option,
                        selectedOptionIndex == index,
                        () {
                          setState(() {
                            selectedOptionIndex = index;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              Image.asset(
                "assets/images/avatars/lionprimaire.png",
                height: 185,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
