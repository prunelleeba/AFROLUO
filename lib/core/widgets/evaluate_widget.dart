
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:afroduo/core/theme/app_colors.dart';
import 'package:afroduo/features/splash/data/models/lessonStepData.dart';

class EvaluationWidget extends StatefulWidget {
  final List<EvaluationPair> pairs;
  final String avatarPath;
  final String hintText;
  final ValueChanged<bool> onCanProceedChanged;

  const EvaluationWidget({
    Key? key,
    required this.pairs,
    required this.avatarPath,
    required this.hintText,
    required this.onCanProceedChanged,
  }) : super(key: key);

  @override
  State<EvaluationWidget> createState() => _EvaluationWidgetState();
}

class _EvaluationWidgetState extends State<EvaluationWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  late List<bool> _pairCompleted;
  int? _selectedPairIndex;
  int? _errorTranslationIndex;
  late List<String> _shuffledTranslations;

  @override
  void initState() {
    super.initState();
    _pairCompleted = List.filled(widget.pairs.length, false);
    _shuffledTranslations = widget.pairs.map((p) => p.correctFrench).toList()
      ..shuffle();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }

  bool get _allCompleted => _pairCompleted.every((c) => c);

  void _playAudio(String path) async {
    try {
      await _audioPlayer.setAsset(path);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Erreur audio évaluation: $e");
    }
  }

  void _playErrorSound() async {
    try {
      await _effectPlayer.setAsset('assets/audio/effects/errors.mp3');
      _effectPlayer.play();
    } catch (_) {}
  }

  void _playSuccessSound() async {
    try {
      await _effectPlayer.setAsset('assets/audio/effects/success.mp3');
      _effectPlayer.play();
    } catch (_) {}
  }

  void _onTranslationTap(String translation) {
    if (_selectedPairIndex == null) return;
    if (_pairCompleted[_selectedPairIndex!]) return;

    final correct = widget.pairs[_selectedPairIndex!].correctFrench;
    final isCorrect = (translation == correct);

    if (isCorrect) {
      _playSuccessSound();
      setState(() {
        _pairCompleted[_selectedPairIndex!] = true;
        _selectedPairIndex = null;
      });
      widget.onCanProceedChanged(_allCompleted);
    } else {
      _playErrorSound();
      setState(() {
        _errorTranslationIndex = _shuffledTranslations.indexOf(translation);
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _errorTranslationIndex = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Avatar + hintText
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                widget.avatarPath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.hintText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 45),
        // Disposition en deux colonnes
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonne de gauche : les boutons audio
            Expanded(
              flex: 2,
              child: Column(
                children: List.generate(widget.pairs.length, (index) {
                  final pair = widget.pairs[index];
                  final isCompleted = _pairCompleted[index];
                  final isSelected = _selectedPairIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: isCompleted
                          ? null
                          : () {
                              setState(() => _selectedPairIndex = index);
                              _playAudio(pair.audioPath);
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.shade100
                              : (isSelected
                                  ? AppColors.primaryBlue.withOpacity(0.15)
                                  : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCompleted ? Colors.green : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle : Icons.volume_up,
                              color: isCompleted ? Colors.green : AppColors.primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isCompleted ? pair.ewondoWord : "Écouter",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted ? Colors.green.shade800 : Colors.black87,
                                ),
                              ),
                            ),
                            if (isSelected && !isCompleted)
                              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 25),
            // Colonne de droite : les choix de traduction (vertical)
            Expanded(
              flex: 2,
              child: Column(
                children: List.generate(_shuffledTranslations.length, (idx) {
                  final translation = _shuffledTranslations[idx];
                  final isError = _errorTranslationIndex == idx;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isError ? Colors.red.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isError ? Colors.red : AppColors.primaryBlue,
                          width: 2,
                        ),
                        boxShadow: isError
                            ? [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onTranslationTap(translation),
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            child: Text(
                              translation,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isError ? Colors.red : AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}