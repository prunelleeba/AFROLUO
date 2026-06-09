import 'package:afroduo/features/auth/firstPage.dart';
import 'package:afroduo/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfroLuo',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Bascule auto selon le téléphone
      home: const Firstpage(),
      initialRoute: "/",
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
