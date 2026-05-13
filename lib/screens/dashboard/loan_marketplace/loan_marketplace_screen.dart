import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'loan_card.dart';

class LoanMarketplaceScreen extends StatelessWidget {
  const LoanMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch the user's score to determine what they qualify for
    int userScore = Hive.box(
      'userProfile',
    ).get('credit_score', defaultValue: 600);

    final mainContent = [
      Text(
        "Available Financing",
        style: TextStyle(
          fontSize: 18,
          fontWeight: .bold,
          color: Colors.grey.shade800,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        "Loan terms and interest rates are dynamically adjusted based "
        "on your Plant Health Credit Score.",
      ),
      const SizedBox(height: 24),

      // TIER 1: Basic Emergency Loan (Unlocks at 600)
      LoanCard(
        userScore: userScore,
        requiredScore: 600,
        title: "Emergency Fertilizer Micro-Loan",
        amount: "₱ 5,000",
        term: "3 Months",
        // Better rates for better scores!
        interest: userScore > 700 ? "0% (Prime Rate)" : "3.5%",
        icon: Icons.eco_outlined,
        color: Colors.green,
      ),

      const SizedBox(height: 16),

      // TIER 2: Mid-size Seed Capital (Unlocks at 680)
      LoanCard(
        userScore: userScore,
        requiredScore: 680,
        title: "Pre-Season Seed Capital",
        amount: "₱ 15,000",
        term: "6 Months",
        interest: userScore > 750 ? "1.5%" : "4.0%",
        icon: Icons.agriculture_outlined,
        color: Colors.blue,
      ),

      const SizedBox(height: 16),

      // TIER 3: Heavy Machinery (Unlocks at 750)
      LoanCard(
        userScore: userScore,
        requiredScore: 750,
        title: "Machinery Lease (Tractor/Harvester)",
        amount: "₱ 85,000",
        term: "24 Months",
        interest: "2.5% (Subsidized)",
        icon: Icons.settings_applications_outlined,
        color: Colors.deepPurple,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Micro-Loan Marketplace",
          style: TextStyle(fontWeight: .bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const .all(20),
        physics: const BouncingScrollPhysics(),
        children: mainContent,
      ),
    );
  }
}
