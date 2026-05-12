import 'package:flutter/material.dart';

class StyledTextField extends StatelessWidget {
  const StyledTextField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.icon,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final IconData icon;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: const .numberWithOptions(decimal: true),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: .circular(12),
            borderSide: .none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: .circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: .circular(12),
            borderSide: BorderSide(color: Colors.green.shade400, width: 2),
          ),
        ),
      ),
    );
  }
}
