// lib/features/leaderboard/leaderboard_page.dart
import 'package:afroduo/core/widgets/custombottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:afroduo/core/theme/app_colors.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final List<Map<String, dynamic>> _users = [
    {"name": "Alice", "score": 3420, "avatar": Icons.person},
    {"name": "Bob", "score": 2890, "avatar": Icons.person_outline},
    {"name": "Charlie", "score": 2710, "avatar": Icons.face},
    {"name": "Diana", "score": 2200, "avatar": Icons.favorite},
    {"name": "Eve", "score": 1980, "avatar": Icons.star},
  ];
  late final List<_RankedUser> _ranked;

  @override
  void initState() {
    super.initState();
    _ranked = List.generate(
      _users.length,
      (i) => _RankedUser(
        index: i + 1,
        name: _users[i]["name"],
        score: _users[i]["score"],
        icon: _users[i]["avatar"],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Leaderboard"),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top 5 de la semaine",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _ranked.length,
                itemBuilder: (context, index) {
                  return _LeaderboardCard(entry: _ranked[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(),

    );
  }
}

class _RankedUser {
  final int index;
  final String name;
  final int score;
  final IconData icon;
  _RankedUser({required this.index, required this.name, required this.score, required this.icon});
}

class _LeaderboardCard extends StatelessWidget {
  final _RankedUser entry;
  const _LeaderboardCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final Color medalColor;
    switch (entry.index) {
      case 1:
        medalColor = Colors.amber;
        break;
      case 2:
        medalColor = Colors.grey.shade400;
        break;
      case 3:
        medalColor = Colors.brown.shade300;
        break;
      default:
        medalColor = Colors.blueGrey;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: medalColor.withOpacity(0.2),
            child: Icon(entry.icon, color: medalColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${entry.score} pts",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "#${entry.index}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
      
    );
  }
}