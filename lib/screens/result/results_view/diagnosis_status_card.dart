import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class DiagnosisStatusCard extends StatelessWidget {
  const DiagnosisStatusCard({
    super.key,
    required this.statusIcon,
    required this.primaryStatusColor,
    required this.advice,
  });

  final IconData statusIcon;
  final ui.Color primaryStatusColor;
  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Icon(statusIcon, color: primaryStatusColor, size: 32),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          advice['diagnosis']!.toUpperCase(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: .w900,
            color: primaryStatusColor,
            letterSpacing: 0.5,
          ),
          textAlign: .center,
        ),
      ),
    ];

    return Container(
      padding: const .all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(mainAxisAlignment: .center, children: mainContent),
    );
  }
}
