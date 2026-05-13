import 'package:flutter/material.dart';
import 'package:rice_nutri_sense/core/data_types.dart';

class TriageDialog extends StatelessWidget {
  const TriageDialog({super.key, required this.data});

  final StringDynamicMap data;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text("Uncertain Reading"),
        ],
      ),
      content: Text(
        "The local scanner confidence is only ${data['confidence']}%.\n\n"
        "Would you like to proceed with a Fast AI Analysis, or run a Deep "
        "Vision Verification (takes ~15 seconds)?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), // false = Fast
          child: const Text("Fast Analysis"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true), // true = Deep
          child: const Text("Deep Vision"),
        ),
      ],
    );
  }
}
