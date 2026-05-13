import 'package:flutter/material.dart';
import 'formatted_text.dart';

class AgentAssessmentCard extends StatelessWidget {
  final Map<String, String> advice;

  const AgentAssessmentCard({super.key, required this.advice});

  @override
  Widget build(BuildContext context) {
    // If the proxy failed or didn't run, don't show the card at all
    if (!advice.containsKey('ai_assessment') ||
        advice['ai_assessment']!.isEmpty) {
      return const SizedBox.shrink();
    }

    final isConfident = advice['ai_confidence'] == 'confident';

    // Dynamically adjust title and colors based on whether it was a fast/deep scan
    final title = isConfident
        ? "AGRITECH YIELD & LOAN PREDICTION"
        : "AGENT DIAGNOSIS & RISK ASSESSMENT";
    final icon = isConfident ? Icons.account_balance : Icons.smart_toy_outlined;
    final color = isConfident ? Colors.blue : Colors.deepPurple;

    // Clean up excessive newlines from the AI
    final cleanText = advice['ai_assessment']!
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();

    final mainContent = [
      _CardHeader(icon: icon, color: color, title: title),
      const Padding(
        padding: .symmetric(vertical: 12),
        child: Divider(height: 1, thickness: 1, color: Colors.black12),
      ),
      FormattedText(
        text: cleanText,
        baseStyle: const TextStyle(
          fontSize: 15,
          fontWeight: .w500,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    ];

    return Container(
      margin: const .only(top: 16),
      padding: const .all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: .circular(16),
        border: .all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(crossAxisAlignment: .start, children: mainContent),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.color,
    required this.title,
  });

  final IconData icon;
  final MaterialColor color;
  final String title;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Icon(icon, color: color.shade700),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: .bold,
            fontSize: 14,
            color: color.shade800,
            letterSpacing: 1,
          ),
        ),
      ),
    ];
    return Row(children: mainContent);
  }
}
