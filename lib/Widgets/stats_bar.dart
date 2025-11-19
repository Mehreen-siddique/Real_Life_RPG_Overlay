import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart';


class StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final IconData icon;

  const StatBar({
    Key? key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    required this.icon,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    double progress = current / max;
    return Container(
     child: Column(
       children: [
         // Label and value
         Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Row(
               children: [
                 Icon(icon, color: color, size: 20),
                 const SizedBox(width: 8),
                 Text(label, style: AppTextStyles.body),
               ],
             ),
             Text(
               '$current/$max',
               style: AppTextStyles.statValue.copyWith(color: color),
             ),
           ],
         ),
         const SizedBox(height: 8),

         // Progress bar
         Container(
           height: 12,
           decoration: BoxDecoration(
             color: AppColors.cardBackground,
             borderRadius: BorderRadius.circular(6),
           ),
           child: Stack(
             children: [
               // Background
               Container(
                 decoration: BoxDecoration(
                   color: AppColors.cardBackground,
                   borderRadius: BorderRadius.circular(6),
                 ),
               ),

               // Progress fill
               FractionallySizedBox(
                 widthFactor: progress,
                 child: Container(
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       colors: [
                         color.withOpacity(0.6),
                         color,
                       ],
                     ),
                     borderRadius: BorderRadius.circular(6),
                     boxShadow: [
                       BoxShadow(
                         color: color.withOpacity(0.3),
                         blurRadius: 8,
                         spreadRadius: 1,
                       ),
                     ],
                   ),
                 ),
               ),
             ],
           ),
         ),
       ],
     ),
    );
  }
}
