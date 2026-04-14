import 'package:flutter/material.dart';

class StartPage extends StatefulWidget{
  const StartPage({Key? key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // title: IconButton(
        //   onPressed: () => Navigator.pop(context),
        //   icon: Icon(Icons.arrow_back_ios_, color: Colors.black),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0,bottom: 16,top:0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Avant la lesson, commençons par quelques questions pour personnaliser ton expérience !",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          
            Image.asset(  
              "assets/images/avatars/lion_moulle.png",
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quiz');
              },
              child: const Text("Continuer"),
            ),
            
            
          ],
        ),
        )// Affiche un indicateur de chargement
      );
  }
}
  
