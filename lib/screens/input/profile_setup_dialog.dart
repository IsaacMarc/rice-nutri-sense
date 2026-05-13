import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileSetupDialog extends StatefulWidget {
  const ProfileSetupDialog({super.key});

  @override
  State<ProfileSetupDialog> createState() => _ProfileSetupDialogState();
}

class _ProfileSetupDialogState extends State<ProfileSetupDialog> {
  String name = "";
  String location = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _DialogTitle(),
      content: _dialogContent(),
      actions: _dialogActions(context),
    );
  }

  List<Widget> _dialogActions(BuildContext context) => [
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        if (name.isNotEmpty && location.isNotEmpty) {
          Box<dynamic> box = Hive.box('userProfile');
          box.put('name', name);
          box.put('location', location);
          box.put('created_at', DateTime.now().toIso8601String());
          Navigator.pop(context);
        }
      },
      child: const Text("Save Profile"),
    ),
  ];

  Column _dialogContent() => Column(
    mainAxisSize: .min,
    children: [
      const Text(
        "Welcome! Please set up your profile to start building your "
        "Plant Health Credit Score.",
      ),
      const SizedBox(height: 16),
      TextField(
        decoration: const InputDecoration(
          labelText: "Full Name",
          border: OutlineInputBorder(),
        ),
        onChanged: (val) => name = val,
      ),
      const SizedBox(height: 12),
      TextField(
        decoration: const InputDecoration(
          labelText: "Farm Location (City/Province)",
          border: OutlineInputBorder(),
        ),
        onChanged: (val) => location = val,
      ),
    ],
  );
}

class _DialogTitle extends StatelessWidget {
  const _DialogTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.person_add_alt_1, color: Colors.green),
        SizedBox(width: 8),
        Text("Farmer Profile"),
      ],
    );
  }
}
