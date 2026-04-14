import 'package:afroduo/features/auth/firstPage.dart';
import 'package:afroduo/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  // runApp(const MyApp());
   ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(
      color: Colors.red,
      child: Center(
        child: Text(
          'Erreur: ${details.exception}',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  };
  runApp(MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Afroluo',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme, 
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Bascule auto selon le téléphone
      home: Firstpage(),
      initialRoute: "/",
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

