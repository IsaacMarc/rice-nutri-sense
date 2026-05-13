import 'package:flutter/material.dart';
import 'detail_column.dart';
import 'simulated_approval_dialog.dart';

class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.userScore,
    required this.requiredScore,
    required this.title,
    required this.amount,
    required this.term,
    required this.interest,
    required this.icon,
    required this.color,
  });

  final int userScore;
  final int requiredScore;
  final String title;
  final String amount;
  final String term;
  final String interest;
  final IconData icon;
  final MaterialColor color;

  bool get isLocked => userScore < requiredScore;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      _LoanCardHeader(
        isLocked: isLocked,
        color: color,
        icon: icon,
        title: title,
        amount: amount,
      ),
      const Padding(
        padding: .symmetric(vertical: 16),
        child: Divider(height: 1),
      ),
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          DetailColumn(label: "Interest", value: interest, isLocked: isLocked),
          DetailColumn(label: "Term", value: term, isLocked: isLocked),
          _ApplyLoanButton(
            isLocked: isLocked,
            color: color,
            amount: amount,
            requiredScore: requiredScore,
          ),
        ],
      ),
    ];

    return Container(
      padding: const .all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(16),
        border: Border.all(
          color: isLocked ? Colors.grey.shade300 : color.shade200,
          width: 1.5,
        ),
      ),
      child: Column(crossAxisAlignment: .start, children: mainContent),
    );
  }
}

class _LoanCardHeader extends StatelessWidget {
  const _LoanCardHeader({
    required this.isLocked,
    required this.color,
    required this.icon,
    required this.title,
    required this.amount,
  });

  final bool isLocked;
  final MaterialColor color;
  final IconData icon;
  final String title;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      CircleAvatar(
        backgroundColor: isLocked ? Colors.grey.shade200 : color.shade50,
        child: Icon(icon, color: isLocked ? Colors.grey : color.shade700),
      ),
      const SizedBox(width: 16),
      _LoanCardHeaderContent(
        title: title,
        isLocked: isLocked,
        amount: amount,
        color: color,
      ),
      if (isLocked) const Icon(Icons.lock_outline, color: Colors.grey),
    ];

    return Row(children: mainContent);
  }
}

class _LoanCardHeaderContent extends StatelessWidget {
  const _LoanCardHeaderContent({
    required this.title,
    required this.isLocked,
    required this.amount,
    required this.color,
  });

  final String title;
  final bool isLocked;
  final String amount;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Text(
        title,
        style: TextStyle(
          fontWeight: .bold,
          fontSize: 16,
          color: isLocked ? Colors.grey : Colors.black87,
        ),
      ),
      Text(
        "Up to $amount",
        style: TextStyle(
          color: isLocked ? Colors.grey : color.shade700,
          fontWeight: .w600,
        ),
      ),
    ];

    return Expanded(
      child: Column(crossAxisAlignment: .start, children: mainContent),
    );
  }
}

class _ApplyLoanButton extends StatelessWidget {
  const _ApplyLoanButton({
    required this.isLocked,
    required this.color,
    required this.amount,
    required this.requiredScore,
  });

  final bool isLocked;
  final MaterialColor color;
  final String amount;
  final int requiredScore;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isLocked ? Colors.grey.shade300 : color.shade600,
        foregroundColor: isLocked ? Colors.grey.shade600 : Colors.white,
        elevation: 0,
      ),
      onPressed: isLocked
          ? null
          : () => showDialog(
              context: context,
              builder: (_) => SimulatedApprovalDialog(amount: amount),
            ),
      child: Text(isLocked ? "Requires $requiredScore" : "Apply"),
    );
  }
}
