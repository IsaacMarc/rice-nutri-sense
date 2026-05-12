import 'package:flutter/material.dart';

class DeficiencyImpactBlock extends StatelessWidget {
  const DeficiencyImpactBlock({super.key, required this.advice});

  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Icon(
        Icons.warning_amber_rounded,
        color: Colors.orange.shade800,
        size: 24,
      ),
      const SizedBox(width: 12),
      _ArgonomicImpactHeader(advice: advice),
    ];

    return Container(
      padding: const .all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: .circular(12),
        border: .all(color: Colors.orange.shade200, width: 1.5),
      ),
      child: Row(crossAxisAlignment: .start, children: mainContent),
    );
  }
}

class _ArgonomicImpactHeader extends StatelessWidget {
  const _ArgonomicImpactHeader({required this.advice});

  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Text(
        "AGRONOMIC IMPACT",
        style: TextStyle(
          fontSize: 12,
          fontWeight: .w900,
          color: Colors.orange.shade900,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        advice['impact']!,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
          fontWeight: .w500,
        ),
      ),
    ];

    return Expanded(
      child: Column(crossAxisAlignment: .start, children: mainContent),
    );
  }
}
