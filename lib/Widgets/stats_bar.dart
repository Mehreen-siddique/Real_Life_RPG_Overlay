import 'package:flutter/material.dart';


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

    );
  }
}
