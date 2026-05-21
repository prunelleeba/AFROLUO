enum StepKind { learning, evaluation }

class LessonStepData {
  final StepKind kind;
  final String? ewondoWord;
  final String? frenchTranslation;
  final String? imagePath;
  final String? avatarPath;
  final String? audioPath;
  final String? hintText;
  // Pour l'évaluation : liste de paires {audioPath, correctFrenchTranslation}
  final List<EvaluationPair>? evaluationPairs;

  const LessonStepData({
    required this.kind,
    this.ewondoWord,
    this.frenchTranslation,
    this.imagePath,
    this.avatarPath,
    this.audioPath,
    this.hintText,
    this.evaluationPairs,
  });

  // Constructeur pour une étape d'apprentissage classique
  const LessonStepData.learning({
    required this.ewondoWord,
    required this.frenchTranslation,
    this.imagePath,
    this.avatarPath,
    this.audioPath,
    required this.hintText,
  })  : kind = StepKind.learning,
        evaluationPairs = null;

  // Constructeur pour une étape d'évaluation
  const LessonStepData.evaluation({
    required this.evaluationPairs,
    this.avatarPath,
    this.hintText = "Trouve la bonne traduction",
  })  : kind = StepKind.evaluation,
        ewondoWord = null,
        frenchTranslation = null,
        imagePath = null,
        audioPath = null;
}

class EvaluationPair {
  final String audioPath;
  final String correctFrench;
  final String ewondoWord; // affiché une fois la paire trouvée

  const EvaluationPair({
    required this.audioPath,
    required this.correctFrench,
    required this.ewondoWord,
  });
}