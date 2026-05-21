class TranslationResult {
  final String ewondo;
  final String explanation;
  final String? audioUrl;

  TranslationResult({
    required this.ewondo,
    required this.explanation,
    this.audioUrl,
  });
}