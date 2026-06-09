import 'package:afroduo/core/theme/app_colors.dart';
import 'package:afroduo/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              " Bonjour, c'est parti !",
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 11),
            Image.asset(
              "assets/images/avatars/liodebut.png",
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 8),
            // Text(
            //   "Afroduo",
            //   style: Theme.of(context).textTheme.displayMedium,
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 8),
            Text(
              "Apprenez une langue en vous amusant.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            GradientButton(
              label: "COMMENCER",
              onPressed: () {
                Navigator.pushNamed(context, "/start");
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: WidgetStateProperty.all(AppColors.grey100),
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              child: Text(
                "DEJA UN COMPTE ?",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
