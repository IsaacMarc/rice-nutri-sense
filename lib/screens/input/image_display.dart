import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageDisplay extends StatelessWidget {
  const ImageDisplay({
    super.key,
    required this.imageFile,
    required this.onTapImage,
  });

  final VoidCallback onTapImage;
  final XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: .circular(16),
      border: Border.all(
        color: imageFile == null ? Colors.green.shade300 : Colors.transparent,
        width: 2,
        style: .solid,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTapImage,
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: boxDecoration,
        child: imageFile == null
            ? const _NoImagePreviewDisplay()
            : _CapturedImagePreviewDisplay(imageFile: imageFile),
      ),
    );
  }
}

class _CapturedImagePreviewDisplay extends StatelessWidget {
  const _CapturedImagePreviewDisplay({required this.imageFile});

  final XFile? imageFile;

  @override
  Widget build(BuildContext context) {
    final stackedContent = [
      Image.file(File(imageFile!.path), fit: .cover),
      Positioned(
        top: 10,
        right: 10,
        child: Container(
          padding: const .all(6),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: .circle,
          ),
          child: const Icon(Icons.edit, color: Colors.white, size: 20),
        ),
      ),
    ];

    return ClipRRect(
      borderRadius: .circular(14),
      child: Stack(fit: .expand, children: stackedContent),
    );
  }
}

class _NoImagePreviewDisplay extends StatelessWidget {
  const _NoImagePreviewDisplay();

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Container(
        padding: const .all(16),
        decoration: BoxDecoration(color: Colors.green.shade50, shape: .circle),
        child: Icon(
          Icons.add_a_photo_rounded,
          size: 40,
          color: Colors.green.shade600,
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        "Tap to Capture Image",
        style: TextStyle(fontWeight: .bold, fontSize: 16),
      ),
      const SizedBox(height: 4),
      Text(
        "or use the gallery button below",
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
    ];

    return Column(mainAxisAlignment: .center, children: mainContent);
  }
}
