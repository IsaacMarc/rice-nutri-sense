import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.score});

  final int score;

  Color getScoreColor(int score) {
    if (score >= 700) {
      return Colors.green;
    } else if (score >= 600) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Math to convert 300-850 range into a 0.0 - 1.0 percentage for the progress bar
    double progress = ((score - 300) / 550).clamp(0.0, 1.0);
    Color scoreColor = getScoreColor(score);

    final mainContent = [
      const Text(
        "PLANT HEALTH CREDIT SCORE",
        style: TextStyle(
          fontSize: 12,
          fontWeight: .bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 16),
      ScoreDisplay(progress: progress, scoreColor: scoreColor, score: score),
    ];

    return Container(
      padding: const .all(24),
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
      child: Column(children: mainContent),
    );
  }
}

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({
    super.key,
    required this.progress,
    required this.scoreColor,
    required this.score,
  });

  final double progress;
  final Color scoreColor;
  final int score;

  @override
  Widget build(BuildContext context) {
    final stackedContent = [
      SizedBox(
        height: 150,
        width: 150,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 12,
          backgroundColor: Colors.grey.shade200,
          color: scoreColor,
          strokeCap: .round,
        ),
      ),
      Column(
        mainAxisSize: .min,
        children: [
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: .w900,
              color: scoreColor,
              height: 1.0,
            ),
          ),
          const Text(
            "Out of 850",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    ];

    return Stack(alignment: .center, children: stackedContent);
  }
}
