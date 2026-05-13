import 'package:flutter/material.dart';
import 'formatted_text.dart';

class TreatmentPrescriptionCard extends StatelessWidget {
  const TreatmentPrescriptionCard({super.key, required this.advice});

  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    final rawText = advice['recommendation'] ?? '';
    final cleanText = rawText.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    final mainContent = [
      const _TreatmentPlanHeader(),
      const Divider(color: Colors.black12, height: 24, thickness: 1),

      FormattedText(
        text: cleanText,
        baseStyle: const TextStyle(
          fontSize: 16,
          fontWeight: .w500,
          color: Colors.black87,
          height: 1.3,
        ),
      ),

      const SizedBox(height: 16),
      _RequiredQuantityDisplay(advice: advice),
    ];

    return Container(
      padding: const .all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.green.shade100],
          begin: .topLeft,
          end: .bottomRight,
        ),
        borderRadius: .circular(16),
        border: .all(color: Colors.green.shade200, width: 1.5),
      ),
      child: Column(crossAxisAlignment: .start, children: mainContent),
    );
  }
}

class _RequiredQuantityDisplay extends StatelessWidget {
  const _RequiredQuantityDisplay({required this.advice});

  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      const Text(
        "REQUIRED QTY: ",
        style: TextStyle(
          fontSize: 14,
          fontWeight: .bold,
          color: Colors.black54,
        ),
      ),
      Text(
        advice['qty']!,
        style: TextStyle(
          fontSize: 20,
          fontWeight: .w900,
          color: Colors.orange.shade800,
        ),
      ),
    ];

    return Container(
      padding: const .symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(8),
      ),
      child: Row(mainAxisSize: .min, children: mainContent),
    );
  }
}

class _TreatmentPlanHeader extends StatelessWidget {
  const _TreatmentPlanHeader();

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Icon(Icons.medical_services_outlined, color: Colors.green.shade800),
      const SizedBox(width: 8),
      Text(
        "TREATMENT PLAN",
        style: TextStyle(
          fontWeight: .bold,
          fontSize: 14,
          color: Colors.green.shade800,
          letterSpacing: 1,
        ),
      ),
    ];
    return Row(children: mainContent);
  }
}
