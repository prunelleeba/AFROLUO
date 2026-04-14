import 'package:afroduo/features/auth/firstPage.dart';
import 'package:afroduo/features/auth/startPage.dart';
import 'package:afroduo/features/auth/welcomePage.dart';
import 'package:afroduo/features/home/homePage.dart';
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
        return MaterialPageRoute(builder: (_) =>  HomePage());
      // Ajoute d'autres routes ici
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
