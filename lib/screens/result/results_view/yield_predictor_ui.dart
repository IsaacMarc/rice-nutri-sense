import 'package:flutter/material.dart';

class YieldPredictorUI extends StatelessWidget {
  const YieldPredictorUI({
    super.key,
    required this.isHealthy,
    required this.advice,
  });

  final bool isHealthy;
  final Map<String, String> advice;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      _UntreatedYieldHeader(isHealthy: isHealthy),
      Text(
        advice['predicted']!,
        style: TextStyle(
          fontWeight: .w900,
          color: isHealthy ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 16,
        ),
      ),
    ];

    return Container(
      margin: const .only(top: 12),
      padding: const .symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isHealthy ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: .circular(12),
        border: .all(
          color: isHealthy ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(mainAxisAlignment: .spaceBetween, children: mainContent),
    );
  }
}

class _UntreatedYieldHeader extends StatelessWidget {
  const _UntreatedYieldHeader({required this.isHealthy});

  final bool isHealthy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.trending_down,
          size: 18,
          color: isHealthy ? Colors.green.shade700 : Colors.red.shade700,
        ),
        const SizedBox(width: 8),
        Text(
          "Untreated Yield Forecast:",
          style: TextStyle(
            fontWeight: .bold,
            color: isHealthy ? Colors.green.shade900 : Colors.red.shade900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
