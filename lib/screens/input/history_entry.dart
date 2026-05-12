import 'package:flutter/material.dart';

class HistoryEntry extends StatelessWidget {
  const HistoryEntry({super.key, required this.history});

  final List<dynamic> history;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      // Wraps the list to make it scrollable without overflowing
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: history.length,
        itemBuilder: _buildHistoryListTile,
      ),
    );
  }

  Widget? _buildHistoryListTile(_, int index) {
    var scan = history[index];
    return ListTile(
      contentPadding: .zero,
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Icon(Icons.history, color: Colors.green.shade800),
      ),
      title: Text(scan['diagnosis'], style: const TextStyle(fontWeight: .bold)),
      subtitle: Text(
        "Date: ${scan['date']}\nYield Target: ${scan['yield']} T/Ha",
      ),
      isThreeLine: true,
    );
  }
}
