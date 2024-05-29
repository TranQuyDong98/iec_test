import 'package:flutter/material.dart';

class DrawPainter extends CustomPainter {
  final List<MapEntry<Path, Paint>> mapPathPaints;
  final List<Path> paths;

  DrawPainter({
    required this.paths,
    required this.mapPathPaints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (mapPathPaints.isNotEmpty) {
      for (var path in mapPathPaints) {
        canvas.drawPath(path.key, path.value);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
