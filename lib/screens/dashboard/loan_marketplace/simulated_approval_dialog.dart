import 'package:flutter/material.dart';

class SimulatedApprovalDialog extends StatelessWidget {
  const SimulatedApprovalDialog({super.key, required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text("Application Sent"),
        ],
      ),
      content: Text(
        "Your application for $amount has been securely transmitted to our "
        "lending partners. Based on your excellent Plant Health Credit Score, "
        "approval is highly likely.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Done"),
        ),
      ],
    );
  }
}
