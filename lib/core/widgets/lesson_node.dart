import 'package:flutter/material.dart';
import 'package:afroduo/features/splash/data/models/lesson.dart';
import 'package:afroduo/core/widgets/segment_circular_widget.dart';
import 'package:afroduo/core/theme/app_colors.dart';

class LessonNode extends StatefulWidget {
  final LearningStep step;
  final bool locked;
  final VoidCallback? onTap;

  const LessonNode({
    required this.step,
    required this.locked,
    this.onTap,
    super.key,
  });

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode>
  with TickerProviderStateMixin {
  bool _isPressed = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Pour le saut de l'icône (seulement leçons en cours)
  late AnimationController _iconJumpController;
  late Animation<double> _iconJumpAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _iconJumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _iconJumpAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _iconJumpController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _iconJumpController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.locked) setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.locked) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (!widget.locked) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = !widget.locked;
    final bool isInProgress = isUnlocked && widget.step.progress > 0.0 && widget.step.progress < 1.0;
    final double pressScale = _isPressed ? 0.9 : 1.0;

    const int totalSegments = 6;
    final int completedSegments = widget.locked
        ? 0
        : (widget.step.progress * totalSegments).round();

    // Icône de base (cadenas si verrouillée)
    Widget baseIcon;
    if (widget.locked) {
      baseIcon = const Icon(Icons.lock, color: Colors.white, size: 28);
    } else if (widget.step.imagePath != null && widget.step.imagePath!.isNotEmpty) {
      baseIcon = Image.asset(widget.step.imagePath!, height: 28, width: 28);
    } else {
      baseIcon = Icon(widget.step.displayIcon, color: Colors.white, size: 28);
    }

    // Icône avec ou sans saut
    final Widget centerIcon = isInProgress
        ? AnimatedBuilder(
            animation: _iconJumpAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _iconJumpAnimation.value),
              child: child,
            ),
            child: baseIcon,
          )
        : baseIcon;

    final Color buttonColor = widget.locked ? Colors.grey.shade400 : Colors.orangeAccent;
    final Color completedColor = widget.locked ? Colors.grey : AppColors.primaryBlue;
    final Color backgroundColor = widget.locked ? Colors.grey.shade300 : Colors.grey.shade400;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: pressScale,
        duration: const Duration(milliseconds: 150),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                final double pulse = isUnlocked ? _pulseAnimation.value : 1.0;
                return Transform.scale(
                  scale: pulse,
                  child: SegmentedCircularProgress(
                    totalSegments: totalSegments,
                    completedSegments: completedSegments,
                    radius: 40.0,
                    strokeWidth: 6.0,
                    completedColor: completedColor,
                    backgroundColor: backgroundColor,
                    centerWidget: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: buttonColor,
                        shape: BoxShape.circle,
                        boxShadow: widget.locked
                            ? null
                            : const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 6,
                                )
                              ],
                      ),
                      child: Center(child: centerIcon),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              widget.step.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.locked ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// // lesson_node.dart
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:afroduo/features/splash/data/models/lesson.dart';
// import 'package:afroduo/core/widgets/segment_circular_widget.dart';
// import 'package:afroduo/core/theme/app_colors.dart';

// class LessonNode extends StatefulWidget {
//   final LearningStep step;
//   final bool locked;
//   final VoidCallback? onTap;

//   const LessonNode({
//     required this.step,
//     required this.locked,
//     this.onTap,
//     super.key,
//   });

//   @override
//   State<LessonNode> createState() => _LessonNodeState();
// }

// class _LessonNodeState extends State<LessonNode>
//     with SingleTickerProviderStateMixin {
//   bool _isPressed = false;
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
  

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat(reverse: true);
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   void _handleTapDown(TapDownDetails details) {
//     if (!widget.locked) setState(() => _isPressed = true);
//   }

//   void _handleTapUp(TapUpDetails details) {
//     if (!widget.locked) setState(() => _isPressed = false);
//   }

//   void _handleTapCancel() {
//     if (!widget.locked) setState(() => _isPressed = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isUnlockedAndStarted = !widget.locked && widget.step.progress > 0.0;
//     final double pressScale = _isPressed ? 0.9 : 1.0;

//     const int totalSegments = 6;
//     final int completedSegments = widget.locked
//         ? 0
//         : (widget.step.progress * totalSegments).round();

//     // Icône à afficher
//     Widget centerContent;
//     if (widget.locked) {
//       centerContent = const Icon(Icons.lock, color: Colors.white, size: 28);
//     } else if (widget.step.imagePath != null && widget.step.imagePath!.isNotEmpty) {
//       centerContent = Image.asset(widget.step.imagePath!, height: 28, width: 28);
//     } else {
//       centerContent = Icon(widget.step.displayIcon, color: Colors.white, size: 28);
//     }

//     // Couleur du fond du bouton (gris si verrouillé)
//     final Color buttonColor = widget.locked ? Colors.grey.shade400 : Colors.orangeAccent;

//     // Cercle de progression (masqué ou grisé si verrouillé)
//     final Color completedColor = widget.locked ? Colors.grey : AppColors.primaryBlue;
//     final Color backgroundColor = widget.locked
//         ? Colors.grey.shade300
//         : Colors.grey.shade400;

//     return GestureDetector(
//       onTapDown: _handleTapDown,
//       onTapUp: _handleTapUp,
//       onTapCancel: _handleTapCancel,
//       onTap: widget.onTap,
//       child: AnimatedScale(
//         scale: pressScale,
//         duration: const Duration(milliseconds: 150),
//         child: Column(
//           children: [
//             // Animation de pulsation si déverrouillé ET commencé
//             AnimatedBuilder(
//               animation: _pulseAnimation,
//               builder: (context, child) {
//                 final double pulse = isUnlockedAndStarted ? _pulseAnimation.value : 1.0;
//                 return Transform.scale(
//                   scale: pulse,
//                   child: SegmentedCircularProgress(
//                     totalSegments: totalSegments,
//                     completedSegments: completedSegments,
//                     radius: 40.0,
//                     strokeWidth: 6.0,
//                     completedColor: completedColor,
//                     backgroundColor: backgroundColor,
//                     centerWidget: Container(
//                       height: 60,
//                       width: 60,
//                       decoration: BoxDecoration(
//                         color: buttonColor,
//                         shape: BoxShape.circle,
//                         boxShadow: widget.locked
//                             ? null
//                             : const [
//                                 BoxShadow(
//                                   color: Colors.black26,
//                                   offset: Offset(0, 4),
//                                   blurRadius: 6,
//                                 )
//                               ],
//                       ),
//                       child: Center(child: child),
//                     ),
//                   ),
//                 );
//               },
//               child: centerContent,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               widget.step.title,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: widget.locked ? Colors.grey : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

