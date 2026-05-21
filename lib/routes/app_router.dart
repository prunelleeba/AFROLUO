import 'package:afroduo/features/auth/RegisterPage.dart';
import 'package:afroduo/features/auth/firstPage.dart';
import 'package:afroduo/features/auth/loginPage.dart';
import 'package:afroduo/features/auth/startPage.dart';
import 'package:afroduo/features/auth/welcomePage.dart';
import 'package:afroduo/features/home/homePage.dart';
import 'package:afroduo/features/leaderboard/leaderboardPage.dart';
import 'package:afroduo/features/lessons/lessonPage.dart';
import 'package:afroduo/features/profile/profilPage.dart';
import 'package:afroduo/features/progress/progressPage.dart';
import 'package:afroduo/features/translation/translationPage.dart';
import 'package:flutter/material.dart';
import 'package:afroduo/features/auth/quizPage.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => const Firstpage());
      // Aj
      case "/welcome":
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      // Ajoute d'autres routes ici
      case "/start":
        return MaterialPageRoute(builder: (_) => const StartPage());
      // Ajoute d'autres routes ici
      case "/quiz":
        return MaterialPageRoute(builder: (_) => const QuizScreen());
      // Ajoute d'autres routes ici
      case "/home":
        return MaterialPageRoute(builder: (_) => HomePage());
      // Ajoute d'autres routes ici
      case "/lesson":
        // Récupère l'ID passé en argument
        final String lessonId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => LessonPage(lessonId: lessonId),
        );
      case "/translate":
        return MaterialPageRoute(builder: (_) => const ChatPage());

      case "/leaderboard":
        return MaterialPageRoute(builder: (_) => const LeaderboardPage());
      case "/progress":
        return MaterialPageRoute(builder: (_) => const ProgressPage());
      case "/profile":
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case "/login":
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case "/register":
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
