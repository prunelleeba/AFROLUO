import 'package:afroduo/core/widgets/lesson_content_switvher.dart';
import 'package:afroduo/core/widgets/lesson_navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:afroduo/features/splash/data/models/lessonStepData.dart';
import 'package:afroduo/core/theme/app_colors.dart';
import 'package:just_audio/just_audio.dart';

class LessonPage extends StatefulWidget {
  final String lessonId;

  const LessonPage({super.key, required this.lessonId});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  bool _canProceed = true; // true par défaut pour les étapes d'apprentissage
  late List<LessonStepData> steps;
  int currentStepIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAutoPlaying = false;

  static const Map<String, List<LessonStepData>> _lessonsData = {
    "salutation_id": [
      LessonStepData.learning(
        ewondoWord: "mbəmbə kídí",
        frenchTranslation: "Bonjour",
        imagePath:
            "assets/images/illustrations/femme_1.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/bonjour.mp3",
        hintText: "Memorize salutations",
      ),
      LessonStepData.learning(
        ewondoWord: "Kíri mbeng",
        frenchTranslation: "Reponse à Bonjour",
        imagePath:
            "assets/images/illustrations/femme_1.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/réponse_bonjour.mp3",
        hintText: "Memorize salutations",
      ),


      LessonStepData.learning(
        ewondoWord: "mbəmbə ngogé",
        frenchTranslation: "Bonsoir",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/bonsoir.mp3",
        hintText: "Memorize salutations",
      ),
      LessonStepData.learning(
        ewondoWord: "Ngogē mbeng",
        frenchTranslation: "Reponse à Bonsoir",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/reponse_bonsoir.mp3",
        hintText: "Memorize salutations",
      ),
      LessonStepData.learning(
        ewondoWord: "mbəmbə alú",
        frenchTranslation: "Bonne nuit",
        imagePath:
            "assets/images/illustrations/femme_1.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/bonne-nuit.mp3",
        hintText: "Memorize salutations",
      ),
      LessonStepData.learning(
        ewondoWord: "mbəmbə asoán",
        frenchTranslation: "Bienvenue",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/bienvenue-venue.mp3",
        hintText: "Memorize salutations",
      ),
        LessonStepData.learning(
        ewondoWord: "yi o nё mvôe",
        frenchTranslation: "tu vas bien ?",
        imagePath:
            "assets/images/illustrations/femme_1.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/tu_vas_bien.mp3",
        hintText: "Memorize salutations",
      ),
      LessonStepData.learning(
        ewondoWord: "Owé, mene mvɔé",
        frenchTranslation: "Oui, je vais bien",
        imagePath:
            "assets/images/illustrations/femme_1.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/oui_je vais_bien.mp3",
        hintText: "Memorize salutations",
      ),
      LessonStepData.learning(
        ewondoWord: "bîbála",
        frenchTranslation: "au revoir",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/au_revoir.mp3",
        hintText: "Memorize salutations",
      ),
      LessonStepData.evaluation(
        avatarPath: "assets/images/avatars/liondonman.png",
        hintText: "Appuie sur les paires",
        evaluationPairs: [
          EvaluationPair(
            audioPath: "assets/audio/ew/bonjour.mp3",
            correctFrench: "Bonjour",
            ewondoWord: "mbəmbə kídí",
          ),
          EvaluationPair(
            audioPath: "assets/audio/ew/bonsoir.mp3",
            correctFrench: "Bonsoir",
            ewondoWord: "mbəmbə ngogé",
          ),
          EvaluationPair(
            audioPath: "assets/audio/ew/bonne-nuit.mp3",
            correctFrench: "Bonne nuit",
            ewondoWord: "mbəmbə alú",
          ),
          // Ajoute autant de paires que nécessaire
        ],
      ),
    ],
    "nombre_id":[
      LessonStepData.learning(
        ewondoWord: "fok",
        frenchTranslation: "Un",
        imagePath:
            "assets/images/illustrations/un.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/1.mp3",
        hintText: "Memorize Numbers",
      ),
       LessonStepData.learning(
        ewondoWord: "bè",
        frenchTranslation: "Deux",
        imagePath:
            "assets/images/illustrations/deux.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/2.mp3",
        hintText: "Memorize Numbers",
      ),
       LessonStepData.learning(
        ewondoWord: "la",
        frenchTranslation: "Trois",
        imagePath:
            "assets/images/illustrations/trois.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/3.mp3",
        hintText: "Memorize Numbers",
      ),
      LessonStepData.learning(
        ewondoWord: "nin",
        frenchTranslation: "Quatre",
        imagePath:
            "assets/images/illustrations/quatre.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/4.mp3",
        hintText: "Memorize Numbers",
      ),
       LessonStepData.learning(
        ewondoWord: "tan",
        frenchTranslation: "Cinq",
        imagePath:
            "assets/images/illustrations/cinq.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/5.mp3",
        hintText: "Memorize Numbers",
      ),
       LessonStepData.learning(
        ewondoWord: "saman",
        frenchTranslation: "Six",
        imagePath:
            "assets/images/illustrations/six.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/6.mp3",
        hintText: "Memorize Numbers",
      ),
      LessonStepData.learning(
        ewondoWord: "zambal",
        frenchTranslation: "Sept",
        imagePath:
            "assets/images/illustrations/sept.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/7.mp3",
        hintText: "Memorize Numbers",
      ),
      LessonStepData.learning(
        ewondoWord: "mwôm",
        frenchTranslation: "Huit",
        imagePath:
            "assets/images/illustrations/huit.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/8.mp3",
        hintText: "Memorize Numbers",
      ),
      LessonStepData.learning(
        ewondoWord: "ibu",
        frenchTranslation: "Neuf",
        imagePath:
            "assets/images/illustrations/neuf.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/9.mp3",
        hintText: "Memorize Numbers",
      ),
       LessonStepData.learning(
        ewondoWord: "awôm",
        frenchTranslation: "Dix",
        imagePath:
            "assets/images/illustrations/dix.jpg", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/10.mp3",
        hintText: "Memorize Numbers",
      ),
       LessonStepData.evaluation(
        avatarPath: "assets/images/avatars/liondonman.png",
        hintText: "Appuie sur les paires",
        evaluationPairs: [
          EvaluationPair(
            audioPath: "assets/audio/ew/10.mp3",
            correctFrench: "Dix",
            ewondoWord: "awôm",
          ),
          EvaluationPair(
            audioPath: "assets/audio/ew/8.mp3",
            correctFrench: "Huit",
            ewondoWord: "mwôm",
          ),
          EvaluationPair(
            audioPath: "assets/audio/ew/6.mp3",
            correctFrench: "Six",
            ewondoWord: "saman",
          ),
          EvaluationPair( 
                audioPath: "assets/audio/ew/1.mp3",
            correctFrench: "Un",
            ewondoWord: "fok",
          ),
          EvaluationPair(
            audioPath: "assets/audio/ew/5.mp3",
            correctFrench: "Cinq",
            ewondoWord: "tan",
          ),
          EvaluationPair(
            audioPath: "assets/audio/ew/2.mp3",
            correctFrench: "Deux",
            ewondoWord: "bè",
          ),
          // Ajoute autant de paires que nécessaire
        ],
      ),

    ],
"famille_id":[
 LessonStepData.learning(
        ewondoWord: "mema",
        frenchTranslation: "Mama",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/mama1.mp3",
        hintText: "Memorize family",
      ),
      LessonStepData.learning(
        ewondoWord: "ndoman",
        frenchTranslation: "Garçon",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/garçon.mp3",
        hintText: "Memorize family",
      ),
      LessonStepData.learning(
        ewondoWord: "ngōan",
        frenchTranslation: "Fille",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/fille.mp3",
        hintText: "Memorize family",
      ),
        LessonStepData.learning(
        ewondoWord: "minga",
        frenchTranslation: "Femme",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/femme.mp3",
        hintText: "Memorize family",
      ),
      
       LessonStepData.learning(
        ewondoWord: "fam",
        frenchTranslation: "Homme",
        imagePath:
            "assets/images/illustrations/femme_2.png", // illustration principale
        avatarPath: "assets/images/avatars/liondonman.png", // image de l'avatar
        audioPath: "assets/audio/ew/homme.mp3",
        hintText: "Memorize family",
      ),
       LessonStepData.evaluation(
        avatarPath: "assets/images/avatars/liondonman.png",
        hintText: "Appuie sur les paires",
        evaluationPairs: [
          EvaluationPair(
            audioPath: "assets/audio/ew/homme.mp3",
            correctFrench: "Homme",
            ewondoWord: "fem",
          ),
          EvaluationPair(
            audioPath: "assets/audio/ew/garçon.mp3",
            correctFrench: "  Garçon",
            ewondoWord: "ndoman",
          ),
            EvaluationPair(
              audioPath: "assets/audio/ew/fille.mp3",
              correctFrench: "Fille",
              ewondoWord: "ngōan",
            ),
            EvaluationPair(
              audioPath: "assets/audio/ew/femme.mp3",
              correctFrench: "Femme",
              ewondoWord: "minga",
            ),
            EvaluationPair(
                audioPath: "assets/audio/ew/mama1.mp3",
                correctFrench: "Mama",
                ewondoWord: "mema",
              ),
          
          // Ajoute autant de paires que nécessaire
        ],
      ),
     ],

    "culture_chefs": [
  LessonStepData.learning(
    ewondoWord: "Nnom Ngui",
    frenchTranslation: "Chef traditionnel Beti",
    // imagePath: "assets/images/culture/chef_beti.png",
    // avatarPath: "assets/images/avatars/liondonman.png",
    // audioPath: "assets/audio/culture/nnom_ngui.mp3",
    hintText: "Découvre les chefs traditionnels",
  ),
  // Tu peux ajouter d'autres étapes sur d'autres chefs
],
"culture_ngondo": [
  LessonStepData.learning(
    ewondoWord: "Ngondo",
    frenchTranslation: "Fête Sawa",
    // imagePath: "assets/images/culture/ngondo.png",
    // avatarPath: "assets/images/avatars/liondonman.png",
    // audioPath: "assets/audio/culture/ngondo.mp3",
    hintText: "Cérémonie annuelle en pays Sawa",
  ),
  // Autres étapes si souhaité
],
"culture_mariage": [
  LessonStepData.learning(
    ewondoWord: "Mariage coutumier",
    frenchTranslation: "Mariage traditionnel",
    // imagePath: "assets/images/culture/mariage.png",
    // avatarPath: "assets/images/avatars/liondonman.png",
    // audioPath: "assets/audio/culture/mariage.mp3",
    hintText: "Le mariage coutumier camerounais",
  ),
],

  };

  @override
  void initState() {
    super.initState();
    steps = _lessonsData[widget.lessonId] ?? [];
    _playCurrentAudio(autoRepeat: true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playCurrentAudio({bool autoRepeat = false}) async {
    if (steps.isEmpty) return;
    final step = steps[currentStepIndex];
    if (step.kind != StepKind.learning) return;

    try {
      await _audioPlayer.setAsset(step.audioPath!);
      await _audioPlayer.play();
      if (autoRepeat) {
        _isAutoPlaying = true;
        _audioPlayer.playerStateStream.listen((state) {
          if (_isAutoPlaying && state.processingState == ProcessingState.completed) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.play();
            _isAutoPlaying = false;
          }
        });
      }
    } catch (e) {
      debugPrint("Erreur audio : $e");
    }
  }

  //  // Quand on arrive à la DERNIÈRE étape et qu'on appuie "Next",
  // on renvoie TRUE à la homePage via Navigator.pop(context, true).
  // La homePage reçoit ce signal et marque la leçon comme terminée.
   void _nextStep() {
    if (!_canProceed) return;

    if (currentStepIndex < steps.length - 1) {
      // Pas encore à la fin : on avance normalement
      setState(() {
        currentStepIndex++;
        _canProceed = steps[currentStepIndex].kind == StepKind.learning;
      });
      _playCurrentAudio(autoRepeat: true);
    } else {
      // C'est la DERNIÈRE étape → leçon terminée !
      // On renvoie true à la homePage pour déclencher le déblocage
      Navigator.pop(context, true);
    }
  }

  // void _nextStep() {
  //   if (!_canProceed) return;
  //   if (currentStepIndex < steps.length - 1) {
  //     setState(() {
  //       currentStepIndex++;
  //       _canProceed = steps[currentStepIndex].kind == StepKind.learning;
  //     });
  //     _playCurrentAudio(autoRepeat: true);
  //   } else {
  //     Navigator.pop(context);
  //   }
  // }
   void _previousStep() {
    if (currentStepIndex > 0) {
      setState(() {
        currentStepIndex--;
        _canProceed = steps[currentStepIndex].kind == StepKind.learning;
      });
      _playCurrentAudio(autoRepeat: true);
    } else {
      // Ferme sans signaler une complétion (on renvoie false)
      Navigator.pop(context, false);
    }
  }

  // void _previousStep() {
  //   if (currentStepIndex > 0) {
  //     setState(() {
  //       currentStepIndex--;
  //       _canProceed = steps[currentStepIndex].kind == StepKind.learning;
  //     });
  //     _playCurrentAudio(autoRepeat: true);
  //   } else {
  //     Navigator.pop(context);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Leçon vide")),
        body: const Center(child: Text("Aucune donnée pour cette leçon.")),
      );
    }

    final stepData = steps[currentStepIndex];
    final double progress = (currentStepIndex + 1) / steps.length;
    final String progressText = "${currentStepIndex + 1}/${steps.length}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.grey700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.grey100,
                  color: AppColors.primaryBlue,
                  minHeight: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              progressText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LessonContentSwitcher(
                stepData: stepData,
                onAudioPressed: () => _playCurrentAudio(autoRepeat: false),
                onCanProceedChanged: (canProceed) {
                  setState(() => _canProceed = canProceed);
                },
              ),
            ),
          ),
          LessonNavigationButtons(
            onBack: _previousStep,
            onNext: _nextStep,
            canProceed: _canProceed,
          ),
        ],
      ),
    );
  }
}






//   @override
//   void initState() {
//     super.initState();
//     steps = _lessonsData[widget.lessonId] ?? [];
//     _playCurrentAudio(autoRepeat: true);
//   }

//   void _playCurrentAudio({bool autoRepeat = false}) async {
//     if (steps.isEmpty) return;
//     final step = steps[currentStepIndex];
//     if (step.kind != StepKind.learning) return; // Pas d'audio pour l'évaluation

//     try {
//       await _audioPlayer.setAsset(step.audioPath!);
//       await _audioPlayer.play();
//       if (autoRepeat) {
//         _isAutoPlaying = true;
//         _audioPlayer.playerStateStream.listen((state) {
//           if (_isAutoPlaying &&
//               state.processingState == ProcessingState.completed) {
//             _audioPlayer.seek(Duration.zero);
//             _audioPlayer.play();
//             _isAutoPlaying = false;
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint("Erreur audio : $e");
//     }
//   }

//   void _nextStep() {
//     if (!_canProceed)
//       return; // Empêche le passage tant que l'évaluation n'est pas finie
//     if (currentStepIndex < steps.length - 1) {
//       setState(() {
//         currentStepIndex++;
//         _canProceed =
//             steps[currentStepIndex].kind ==
//             StepKind.learning; // réinitialise pour learning
//       });
//       _playCurrentAudio(autoRepeat: true);
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   void _previousStep() {
//     if (currentStepIndex > 0) {
//       setState(() {
//         currentStepIndex--;
//         _canProceed = steps[currentStepIndex].kind == StepKind.learning;
//       });
//       _playCurrentAudio(autoRepeat: true);
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (steps.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text("Leçon vide")),
//         body: const Center(child: Text("Aucune donnée pour cette leçon.")),
//       );
//     }

//     final stepData = steps[currentStepIndex];
//     final double progress = (currentStepIndex + 1) / steps.length;
//     final String progressText = "${currentStepIndex + 1}/${steps.length}";

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: AppColors.grey700),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: LinearProgressIndicator(
//                   value: progress,
//                   backgroundColor: AppColors.grey100,
//                   color: AppColors.primaryBlue,
//                   minHeight: 12,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               progressText,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//            Expanded(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: stepData.kind == StepKind.learning
//                 ? _buildLearningContent(stepData)
//                 : _buildEvaluationContent(stepData),
//           ),
//         ),
          
//                 _buildBottomButtons(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
