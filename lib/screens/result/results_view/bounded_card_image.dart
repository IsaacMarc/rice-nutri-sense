import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:rice_nutri_sense/bounding_box_painter.dart';
import '../result_screen/result_screen.dart';

class BoundedCardImage extends StatelessWidget {
  const BoundedCardImage({
    super.key,
    required this.nativeImage,
    required this.widget,
    required this.detectedBoxes,
  });

  final ui.Image? nativeImage;
  final ResultScreen widget;
  final List<Map<String, dynamic>> detectedBoxes;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: .circular(16)),
      clipBehavior: .antiAlias,
      child: Container(
        height: 240,
        decoration: const BoxDecoration(color: Colors.black),
        child: nativeImage == null
            ? Image.file(File(widget.imageFile.path), fit: .cover)
            : _customPaint(),
      ),
    );
  }

  CustomPaint _customPaint() {
    return CustomPaint(
      foregroundPainter: BoundingBoxPainter(detectedBoxes, nativeImage!),
      child: Image.file(File(widget.imageFile.path), fit: .cover),
    );
  }
}
