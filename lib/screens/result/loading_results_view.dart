import 'package:flutter/material.dart';

class LoadingResultsView extends StatelessWidget {
  const LoadingResultsView({super.key, required this.debugLog});

  final String debugLog;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      const CircularProgressIndicator(color: Colors.green),
      const SizedBox(height: 24),
      Text(
        debugLog,
        style: TextStyle(
          fontSize: 16,
          color: Colors.green.shade700,
          fontWeight: .w500,
        ),
      ),
    ];

    return Center(
      child: Column(mainAxisAlignment: .center, children: mainContent),
    );
  }
}
