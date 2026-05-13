import 'package:flutter/material.dart';

class MetricBlock extends StatelessWidget {
  const MetricBlock({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Icon(icon, color: Colors.green.shade700, size: 28),
      const SizedBox(height: 8),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
    ];
    return Column(children: mainContent);
  }
}
