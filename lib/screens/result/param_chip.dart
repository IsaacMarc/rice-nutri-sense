import 'package:flutter/material.dart';

class ParamChip extends StatelessWidget {
  const ParamChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Icon(icon, size: 16, color: Colors.blueGrey.shade600),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          fontWeight: .bold,
          color: Colors.blueGrey.shade900,
          fontSize: 13,
        ),
      ),
    ];

    return Row(mainAxisSize: .min, children: mainContent);
  }
}
