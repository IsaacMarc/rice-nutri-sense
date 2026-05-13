import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'metric_block.dart';

class DataValidityMetrics extends StatelessWidget {
  const DataValidityMetrics({super.key, required this.profileBox});

  final Box profileBox;

  @override
  Widget build(BuildContext context) {
    // Calculate Account Age
    String createdAtStr = profileBox.get(
      'created_at',
      defaultValue: DateTime.now().toIso8601String(),
    );
    DateTime createdAt = DateTime.parse(createdAtStr);
    int daysActive = DateTime.now().difference(createdAt).inDays;

    // Calculate Backing Data
    Box historyBox = Hive.box('scanHistory');
    int totalScans = historyBox.get('scans', defaultValue: []).length;

    final mainContent = [
      const Text(
        "DATA VALIDITY METRICS",
        style: TextStyle(
          fontSize: 12,
          fontWeight: .bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          MetricBlock(
            icon: Icons.calendar_month,
            label: "Account Age",
            value: "$daysActive Days",
          ),
          MetricBlock(
            icon: Icons.history,
            label: "History Logs",
            value: "$totalScans Scans",
          ),
          MetricBlock(
            icon: Icons.verified_user,
            label: "Status",
            value: daysActive > 7 && totalScans > 3 ? "Verified" : "Pending",
          ),
        ],
      ),
    ];

    return Container(
      padding: const .all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(16),
        border: .all(color: Colors.grey.shade300),
      ),
      child: Column(crossAxisAlignment: .start, children: mainContent),
    );
  }
}
