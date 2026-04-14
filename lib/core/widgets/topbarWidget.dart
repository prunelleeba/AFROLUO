import 'package:afroduo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TopBarWidget extends StatelessWidget {
  const TopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
       
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            radius: 15,
            backgroundImage: const AssetImage(
              "assets/images/flags/Cameroon.png",
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
        SizedBox(width: 50),
        const Text(
          "Afroluo",
          style: TextStyle(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
         SizedBox(width: 50),
 _buildStat(Icons.local_fire_department, "12", Colors.orange),
            _buildStat(Icons.diamond, "450", const Color.fromARGB(255, 182, 224, 243)),
            _buildStat(Icons.favorite, "5", Colors.red),
          
        
       
           
      ],
    );
  }

  Widget _buildStat(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
