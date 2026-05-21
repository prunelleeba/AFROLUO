// lib/features/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:afroduo/core/theme/app_colors.dart';
import 'package:afroduo/core/widgets/custombottomNavbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String userName = "Jean Ewondo";
  final String email = "jean@afroluo.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profil"),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            _buildOption(Icons.person_outline, "Modifier le profil", () {}),
            _buildOption(Icons.language, "Changer la langue", () {}),
            _buildOption(Icons.notifications_outlined, "Notifications", () {}),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Se déconnecter", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ).paddingOnly(bottom: 8);
  }
}

extension on Widget {
  Widget paddingOnly({double bottom = 0}) {
    return Padding(padding: EdgeInsets.only(bottom: bottom), child: this);
  }
}




// // lib/features/profile/profile_page.dart
// import 'package:flutter/material.dart';
// import 'package:afroduo/core/theme/app_colors.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final String userName = "Jean Ewondo";
//   final String email = "jean@afroluo.com";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text("Profil"),
//         backgroundColor: AppColors.primaryBlue,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//         child: Column(
//           children: [
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: AppColors.primaryBlue,
//               child: Icon(Icons.person, size: 60, color: Colors.white),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               userName,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               email,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 32),
//             _buildOption(Icons.person_outline, "Modifier le profil", () {
//               // TODO
//             }),
//             _buildOption(Icons.language, "Changer la langue", () {
//               // TODO
//             }),
//             _buildOption(Icons.notifications_outlined, "Notifications", () {
//               // TODO
//             }),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   // Déconnexion (retour à l'écran de login)
//                   Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//                 },
//                 icon: const Icon(Icons.logout, color: Colors.white),
//                 label: const Text("Se déconnecter",
//                     style: TextStyle(color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade400,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, color: AppColors.primaryBlue),
//       title: Text(title),
//       trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//       onTap: onTap,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       tileColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//     ).paddingOnly(bottom: 8);
//   }
// }

// extension on Widget {
//   Widget paddingOnly({double bottom = 0}) {
//     return Padding(padding: EdgeInsets.only(bottom: bottom), child: this);
//   }
// }