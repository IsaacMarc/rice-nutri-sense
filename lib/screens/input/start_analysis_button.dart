import 'package:flutter/material.dart';

class StartAnalysisButton extends StatelessWidget {
  const StartAnalysisButton({super.key, required this.onStartAnalysis});

  final VoidCallback onStartAnalysis;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoratin(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 65),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: .circular(16)),
        ),
        onPressed: onStartAnalysis,
        child: const _StartAnalysisHeader(),
      ),
    );
  }

  BoxDecoration _boxDecoratin() => BoxDecoration(
    borderRadius: .circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.green.withValues(alpha: 0.3),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
    ],
    gradient: LinearGradient(
      colors: [Colors.green.shade600, Colors.green.shade800],
      begin: .topLeft,
      end: .bottomRight,
    ),
  );
}

class _StartAnalysisHeader extends StatelessWidget {
  const _StartAnalysisHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: .center,
      children: [
        Text(
          "START ANALYSIS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: .w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
