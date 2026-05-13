import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rice_nutri_sense/screens/dashboard/reset_account_dialog.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  final Box _profileBox = Hive.box('userProfile');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _profileBox.get('name', defaultValue: ''),
    );
    _locationController = TextEditingController(
      text: _profileBox.get('location', defaultValue: ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_nameController.text.isNotEmpty &&
        _locationController.text.isNotEmpty) {
      _profileBox.put('name', _nameController.text);
      _profileBox.put('location', _locationController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _resetAccount() {
    showDialog(
      context: context,
      builder: (context) => ResetAccountDialog(profileBox: _profileBox),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      const Text(
        "Edit Profile",
        style: TextStyle(fontSize: 16, fontWeight: .bold, color: Colors.grey),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: "Full Name",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _locationController,
        decoration: const InputDecoration(
          labelText: "Farm Location",
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      const SizedBox(height: 24),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          padding: const .symmetric(vertical: 16),
        ),
        onPressed: _saveChanges,
        child: const Text(
          "Save Changes",
          style: TextStyle(fontSize: 16, fontWeight: .bold),
        ),
      ),
      const SizedBox(height: 48),
      const Divider(),
      const SizedBox(height: 24),
      ..._dangerZoneControls(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Account Settings",
          style: TextStyle(fontWeight: .bold),
        ),
      ),
      body: ListView(padding: const .all(20), children: mainContent),
    );
  }

  List<Widget> _dangerZoneControls() => [
    const Text(
      "DANGER ZONE",
      style: TextStyle(fontSize: 16, fontWeight: .bold, color: Colors.red),
    ),
    const SizedBox(height: 12),
    OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const .symmetric(vertical: 16),
      ),
      icon: const Icon(Icons.delete_forever),
      label: const Text(
        "Reset Account & Credit Score",
        style: TextStyle(fontWeight: .bold),
      ),
      onPressed: _resetAccount,
    ),
  ];
}
