import 'package:flutter/material.dart';

class BrowseGalleryButton extends StatelessWidget {
  const BrowseGalleryButton({super.key, required this.onBrowseGallery});

  final VoidCallback onBrowseGallery;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      TextButton.icon(
        onPressed: onBrowseGallery,
        icon: Icon(Icons.photo_library_rounded, color: Colors.green.shade700),
        label: Text(
          "Browse Gallery",
          style: TextStyle(color: Colors.green.shade700, fontWeight: .bold),
        ),
        style: TextButton.styleFrom(
          padding: const .symmetric(horizontal: 20, vertical: 12),
          backgroundColor: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: .circular(30)),
        ),
      ),
    ];

    return Row(mainAxisAlignment: .center, children: mainContent);
  }
}
