import 'package:flutter/material.dart';

class NewHistoryButton extends StatelessWidget {
  const NewHistoryButton({super.key, required this.onShowHistory});

  final VoidCallback onShowHistory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onShowHistory,
        icon: const Icon(Icons.history, color: Colors.blueGrey),
        label: const Text(
          "View Recent Scans",
          style: TextStyle(color: Colors.blueGrey, fontWeight: .bold),
        ),
      ),
    );
  }
}
