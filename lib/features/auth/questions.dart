class QuizOption {
  final String label;
  final String imagePath; // Le chemin du drapeau ou de l'icône

  QuizOption({required this.label, required this.imagePath});
}

class Question {
  final String title;
  final String image;
  final List<QuizOption> options;

  Question({
    required this.title, 
    required this.image, 
    required this.options
  });
}
