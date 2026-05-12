import 'package:flutter/material.dart';
import 'history_entry.dart';

class HistoryDialog extends StatelessWidget {
  const HistoryDialog({super.key, required this.history});

  final List<dynamic> history;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      const Text(
        "Recent Scans",
        style: TextStyle(
          fontSize: 20,
          fontWeight: .bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 10),
      history.isEmpty
          ? const _EmptyHistoryView()
          : HistoryEntry(history: history),
    ];
    return Container(
      // Limits the max height to 80% of the screen so it doesn't cover the app bar
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const .all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(20),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: mainContent,
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: .all(20.0),
      child: Text(
        "No previous scans found.",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
