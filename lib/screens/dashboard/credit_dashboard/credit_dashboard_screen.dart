import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'load_eligibility_card.dart';
import 'score_card.dart';
import 'data_validity_metrics.dart';
import '../loan_marketplace/loan_marketplace_screen.dart';

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
        builder: (context, box, _) => _CreditDashboardView(box: box),
      ),
    );
  }
}

class _CreditDashboardView extends StatelessWidget {
  const _CreditDashboardView({required this.box});

  final Box box;

  @override
  Widget build(BuildContext context) {
    // Fetch the score, default to a baseline of 600
    int creditScore = box.get('credit_score', defaultValue: 600);

    return SingleChildScrollView(
      padding: const .all(20),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          ScoreCard(score: creditScore),
          const SizedBox(height: 24),
          LoadEligibilityCard(score: creditScore),
          const SizedBox(height: 24),
          DataValidityMetrics(profileBox: box),
          const SizedBox(height: 32),
          const _BrowseLoansButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _BrowseLoansButton extends StatelessWidget {
  const _BrowseLoansButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        padding: const .symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      ),
      icon: const Icon(Icons.storefront),
      label: const Text(
        "Browse Micro-Loans",
        style: TextStyle(fontSize: 16, fontWeight: .bold),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoanMarketplaceScreen()),
        );
      },
    );
  }
}
