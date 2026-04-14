import 'package:afroduo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:async'; 

class Firstpage extends StatefulWidget {
  // ignore: use_super_parameters
  const Firstpage({Key? key}) : super(key: key);

  @override
  _FirstpageState createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {

  @override
  void initState() {

    super.initState();

    Future.delayed( const Duration(seconds: 5), () {
      if (mounted) { // Vérifie que le widget est toujours dans l'arbre
      context;
      Navigator.pushReplacementNamed(context, "/welcome");
  }});
  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/avatars/lion_1.png", width: 350,height: 350,),
            const SizedBox(height: 8),
            Text("Afroluo", style: textTheme.displayMedium, ),
            const SizedBox(height: 13),
            Padding(
              padding:EdgeInsets.all(37),
              child:CircularProgressIndicator(
              color: AppColors.secondaryBlue, // La couleur du trait qui tourne
              backgroundColor:
                  AppColors.grey100, // La couleur du cercle de fond (optionnel)
              strokeWidth: 5.0, // L'épaisseur du trait
            
            ),)
          ],
        ),
      ),
    );
  }
}
