// ignore: file_names
import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // Navigation selon l'index
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
        BottomNavigationBarItem(icon: Icon(Icons.translate), label: "Traduction"),
        BottomNavigationBarItem(icon: Icon(Icons.shield), label: "Protection"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    );
  }
}


// import 'package:flutter/material.dart';

// class CustomBottomNav extends StatelessWidget {
//   const CustomBottomNav({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: Colors.blue,
//       unselectedItemColor: Colors.grey,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
//         BottomNavigationBarItem(icon: Icon(Icons.translate), label: ""),
//         BottomNavigationBarItem(icon: Icon(Icons.shield), label: ""),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
//       ],
//     );
//   }
// }




