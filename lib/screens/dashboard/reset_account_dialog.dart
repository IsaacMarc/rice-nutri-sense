import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ResetAccountDialog extends StatelessWidget {
  const ResetAccountDialog({super.key, required this.profileBox});

  final Box<dynamic> profileBox;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Reset Account",
        style: TextStyle(color: Colors.red, fontWeight: .bold),
      ),
      content: const Text(
        "This action will permanently delete your scan history and reset your "
        "Plant Health Credit Score back to 600. You cannot undo this. Lenders "
        "will see your account age reset to 0 days.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // Wipe the slate clean to prevent spoofing
            Hive.box('scanHistory').clear();
            profileBox.clear();

            // Close dialog and screen
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text("WIPE DATA"),
        ),
      ],
    );
  }
}
