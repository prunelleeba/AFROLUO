import 'package:afroduo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:afroduo/features/splash/data/models/lesson.dart';
import 'package:afroduo/core/widgets/segment_circular_widget.dart';

class LessonNode extends StatefulWidget {
  final LearningStep step;
  final VoidCallback? onTap;

  const LessonNode({required this.step, this.onTap, super.key});

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) =>
      setState(() => _isPressed = true);
  void _handleTapUp(TapUpDetails details) => setState(() => _isPressed = false);
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed ? 0.9 : 1.0;

    const int totalSegments = 6;
    final int completedSegments = (widget.step.progress * totalSegments)
        .round();

    // Détermine quoi afficher au centre
    Widget centerContent;
    if (widget.step.imagePath != null && widget.step.imagePath!.isNotEmpty) {
      // Image depuis les assets
      centerContent = Image.asset(
        widget.step.imagePath!,
        height: 24,
        width: 24,
        // color: Colors.white, // retire si les images sont déjà colorées
      );
    } else {
      // Icône (par défaut une étoile si rien n'est précisé)
      final icon = widget.step.iconData ?? Icons.star;
      centerContent = Icon(icon, color: Colors.white, size: 24);
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: Transform.scale(
        scale: scale,
        child: Column(
          children: [
            SegmentedCircularProgress(
              totalSegments: totalSegments,
              completedSegments: completedSegments,
              radius: 40.0, // cercle de 60px de diamètre
              strokeWidth: 6.0,
              completedColor: const Color.fromARGB(255, 78, 201, 99),
              backgroundColor:
                  Colors.grey.shade400, // bien visible sur fond blanc
              centerWidget: Container(
                height:
                    60, // plus petit que le diamètre intérieur (60 - 5*2 = 50)
                width: 60,
                decoration: const BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color.fromARGB(0, 143, 142, 142), offset: Offset(0, 10)),
                  ],
                ),
                child: Center(child: centerContent),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.step.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}














// import 'package:afroduo/core/theme/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:afroduo/features/splash/data/models/lesson.dart';
// import 'package:afroduo/core/widgets/segment_circular_widget.dart';

// class LessonNode extends StatefulWidget {
//   final LearningStep step;
//   final VoidCallback? onTap;
//   final String? imagepath; // conservé pour compatibilité, mais optionnel

//   const LessonNode({
//     required this.step,
//     this.onTap,
//     this.imagepath,
//     super.key,
//   });

//   @override
//   State<LessonNode> createState() => _LessonNodeState();
// }

// class _LessonNodeState extends State<LessonNode> {
//   bool _isPressed = false;

//   void _handleTapDown(TapDownDetails details) => setState(() => _isPressed = true);
//   void _handleTapUp(TapUpDetails details) => setState(() => _isPressed = false);
//   void _handleTapCancel() => setState(() => _isPressed = false);

//   @override
//   Widget build(BuildContext context) {
//     final double scale = _isPressed ? 0.9 : 1.0;

//     // Définir le nombre total de segments (par exemple 6)
//     const int totalSegments = 6;
//     final int completedSegments = (widget.step.progress * totalSegments).round();

//     // Image à utiliser : priorité à step.imagePath, sinon imagepath passé en paramètre
//     final String imageToUse = widget.step.imagePath.isNotEmpty
//         ? widget.step.imagePath
//         : (widget.imagepath ?? "assets/icons/default_lesson_icon.png");

//     return GestureDetector(
//       onTapDown: _handleTapDown,
//       onTapUp: _handleTapUp,
//       onTapCancel: _handleTapCancel,
//       onTap: widget.onTap,
//       child: Transform.scale(
//         scale: scale,
//         child: Column(
//           children: [
//             SegmentedCircularProgress(
//               totalSegments: totalSegments,
//               completedSegments: completedSegments,
//               radius: 45.0,
//               strokeWidth: 6.0,
//               completedColor: Colors.green,
//               backgroundColor: Colors.grey.shade300,
//               centerWidget: Container(
//                 height: 70,
//                 width: 70,
//                 decoration: const BoxDecoration(
//                   color: AppColors.primaryBlue,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(color: Colors.black26, offset: Offset(0, 4))
//                   ],
//                 ),
//                 child: Image.asset(
//                   imageToUse,
//                   height: 35,
//                   width: 35,
//                   color: Colors.white, // retire si tes images sont déjà colorées
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.step.title,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }