import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../dashboard/credit_dashboard_screen.dart';
import '../dashboard/profile_settings_screen.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('userProfile').listenable(),
      builder: (context, box, _) {
        String name = box.get('name', defaultValue: 'Farmer');
        int score = box.get('credit_score', defaultValue: 600);

        final mainContent = [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          _CreditScoreLabel(name: name, score: score),
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white,
            size: 28,
          ),
        ];

        return InteractableDashboardHeader(mainContents: mainContent);
      },
    );
  }
}

class _CreditScoreLabel extends StatelessWidget {
  const _CreditScoreLabel({required this.name, required this.score});

  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Text(
        "Hello, $name",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: .bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "Credit Score: $score",
        style: TextStyle(
          color: Colors.green.shade100,
          fontSize: 14,
          fontWeight: .w500,
        ),
      ),
    ];

    return Expanded(
      child: Column(crossAxisAlignment: .start, children: mainContent),
    );
  }
}

class InteractableDashboardHeader extends StatelessWidget {
  const InteractableDashboardHeader({super.key, required this.mainContents});

  final List<Widget> mainContents;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreditDashboardScreen()),
        );
      },
      child: Container(
        padding: const .all(16),
        margin: const .only(bottom: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.green.shade600],
          ),
          borderRadius: .circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [...mainContents, _ProfileSettingsButton()]),
      ),
    );
  }
}

class _ProfileSettingsButton extends StatelessWidget {
  const _ProfileSettingsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, color: Colors.white70),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
        );
      },
    );
  }
}
