import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boxes;
  final ui.Image originalImage;

  BoundingBoxPainter(this.boxes, this.originalImage);

  @override
  void paint(Canvas canvas, Size size) {
    if (boxes.isEmpty) return;

    final double scaleX = size.width / originalImage.width;
    final double scaleY = size.height / originalImage.height;

    final Paint boxPaint = Paint()
      ..color = Colors.greenAccent
      ..style = .stroke
      ..strokeWidth = 3.0;

    final Paint textBgPaint = Paint()
      ..color = Colors.greenAccent
      ..style = .fill;

    for (var boxData in boxes) {
      List<dynamic> box = boxData['box'];

      double left = box[0] * scaleX;
      double top = box[1] * scaleY;
      double right = box[2] * scaleX;
      double bottom = box[3] * scaleY;

      double score = box[4] * 100;

      String tag = boxData['tag'] ?? "Leaf";

      final rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(rect, boxPaint);

      String label = "$tag: ${score.toStringAsFixed(1)}%";

      TextSpan span = TextSpan(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: .bold,
        ),
        text: label,
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: .left,
        textDirection: .ltr,
      );
      tp.layout();

      double labelTop = top - 18 < 0 ? 0 : top - 18;
      canvas.drawRect(
        Rect.fromLTWH(left, labelTop, tp.width + 4, 18),
        textBgPaint,
      );
      tp.paint(canvas, Offset(left + 2, labelTop + 1));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
