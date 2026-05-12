import 'package:flutter/material.dart';

class AlternativeMinimalCard extends StatelessWidget {
  const AlternativeMinimalCard({super.key, required this.advice});

  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(16),
        border: .all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          advice['recommendation']!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: .w500,
            color: Colors.black87,
          ),
          textAlign: .center,
        ),
      ),
    );
  }
}
