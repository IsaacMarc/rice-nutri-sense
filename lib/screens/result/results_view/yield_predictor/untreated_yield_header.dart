import 'package:flutter/material.dart';

class UntreatedYieldHeader extends StatelessWidget {
  const UntreatedYieldHeader({super.key, required this.isHealthy});

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
            fontWeight: FontWeight.bold,
            color: isHealthy ? Colors.green.shade900 : Colors.red.shade900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
