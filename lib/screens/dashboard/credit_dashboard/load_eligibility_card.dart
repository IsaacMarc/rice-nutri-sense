import 'package:flutter/material.dart';

class LoadEligibilityData {
  final String tier;
  final String description;
  final IconData icon;
  final Color color;

  const LoadEligibilityData({
    required this.tier,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class LoadEligibilityCard extends StatelessWidget {
  const LoadEligibilityCard({super.key, required this.score});

  final int score;

  LoadEligibilityData _getData(int score) {
    if (score >= 750) {
      return LoadEligibilityData(
        tier: "Tier 1: Pre-Approved",
        description:
            "Eligible for premium machinery loans and 0% interest "
            "fertilizer financing.",
        icon: Icons.diamond_outlined,
        color: Colors.blue.shade700,
      );
    } else if (score >= 650) {
      return LoadEligibilityData(
        tier: "Tier 2: Standard Rate",
        description:
            "Eligible for standard micro-loans and seasonal fertilizer packages.",
        icon: Icons.verified_outlined,
        color: Colors.green.shade700,
      );
    } else {
      return LoadEligibilityData(
        tier: "Tier 3: High Risk",
        description:
            "Loan eligibility restricted. Please improve crop health via "
            "recommended treatments to unlock financing.",
        icon: Icons.lock_outline,
        color: Colors.orange.shade800,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getData(score);

    final mainContent = [
      Icon(data.icon, size: 36, color: data.color),
      const SizedBox(width: 16),
      _LoadTierLabel(
        tier: data.tier,
        color: data.color,
        description: data.description,
      ),
    ];

    return Container(
      padding: const .all(20),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.1),
        border: .all(color: data.color.withValues(alpha: 0.3), width: 1.5),
        borderRadius: .circular(16),
      ),
      child: Row(crossAxisAlignment: .start, children: mainContent),
    );
  }
}

class _LoadTierLabel extends StatelessWidget {
  const _LoadTierLabel({
    required this.tier,
    required this.color,
    required this.description,
  });

  final String tier;
  final Color color;
  final String description;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Text(
        tier,
        style: TextStyle(fontSize: 18, fontWeight: .bold, color: color),
      ),
      const SizedBox(height: 8),
      Text(
        description,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    ];

    return Expanded(
      child: Column(crossAxisAlignment: .start, children: mainContent),
    );
  }
}
