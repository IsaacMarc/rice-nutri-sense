import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final headerContent = [
      Icon(Icons.grass_rounded, color: Colors.green.shade700, size: 28),
      const SizedBox(width: 8),
      const Text(
        "RiceNutriSense",
        style: TextStyle(fontWeight: .w900, letterSpacing: 0.5),
      ),
    ];

    return AppBar(
      title: Row(mainAxisSize: .min, children: headerContent),
      centerTitle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0.5,
      shadowColor: Colors.black26,
    );
  }
}
