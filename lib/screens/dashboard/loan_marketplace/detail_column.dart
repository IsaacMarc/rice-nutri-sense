import 'package:flutter/material.dart';

class DetailColumn extends StatelessWidget {
  const DetailColumn({
    super.key,
    required this.label,
    required this.value,
    required this.isLocked,
  });

  final String label;
  final String value;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      Text(
        value,
        style: TextStyle(
          fontWeight: .bold,
          color: isLocked ? Colors.grey : Colors.black87,
        ),
      ),
    ];
    return Column(crossAxisAlignment: .start, children: mainContent);
  }
}
