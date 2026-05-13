import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CreditDashboardScreen extends StatelessWidget {
  const CreditDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Financial Profile",
          style: TextStyle(fontWeight: .bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      // ValueListenableBuilder automatically updates the UI when the Hive box changes!
      body: ValueListenableBuilder(
        valueListenable: Hive.box(
          'userProfile',
        ).listenable(keys: ['credit_score']),
        builder: (context, Box box, _) {
          // Fetch the score, default to a baseline of 600
          int creditScore = box.get('credit_score', defaultValue: 600);

          return SingleChildScrollView(
            padding: const .all(20),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                _buildScoreCard(creditScore),
                const SizedBox(height: 24),
                _buildLoanEligibilityCard(creditScore),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(int score) {
    // Math to convert 300-850 range into a 0.0 - 1.0 percentage for the progress bar
    double progress = ((score - 300) / 550).clamp(0.0, 1.0);

    Color scoreColor;
    if (score >= 700) {
      scoreColor = Colors.green;
    } else if (score >= 600) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

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
      child: Column(
        children: [
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
          Stack(
            alignment: .center,
            children: [
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanEligibilityCard(int score) {
    String tier;
    String description;
    IconData icon;
    Color color;

    if (score >= 750) {
      tier = "Tier 1: Pre-Approved";
      description =
          "Eligible for premium machinery loans and 0% interest fertilizer financing.";
      icon = Icons.diamond_outlined;
      color = Colors.blue.shade700;
    } else if (score >= 650) {
      tier = "Tier 2: Standard Rate";
      description =
          "Eligible for standard micro-loans and seasonal fertilizer packages.";
      icon = Icons.verified_outlined;
      color = Colors.green.shade700;
    } else {
      tier = "Tier 3: High Risk";
      description =
          "Loan eligibility restricted. Please improve crop health via recommended treatments to unlock financing.";
      icon = Icons.lock_outline;
      color = Colors.orange.shade800;
    }

    return Container(
      padding: const .all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: .all(color: color.withValues(alpha: 0.3), width: 1.5),
        borderRadius: .circular(16),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  tier,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: .bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
