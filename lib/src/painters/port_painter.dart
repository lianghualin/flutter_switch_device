import 'package:flutter/material.dart';
import '../models/port_status.dart';

/// Draws a single port icon as a rounded rectangle with pin detail lines.
class PortPainter extends CustomPainter {
  PortPainter({required this.color});

  final Color color;

  /// Maps [PortStatus] to the appropriate display color.
  static Color colorForStatus(
    PortStatus status, {
    bool isConfig = false,
    bool isInvalid = false,
  }) {
    if (isConfig) return const Color(0xFF9E9E9E);
    if (isInvalid) return const Color(0xFF333333);
    return switch (status) {
      PortStatus.up => const Color(0xFF2CC339),
      PortStatus.down => const Color(0xFF9E9E9E),
      PortStatus.unknown => const Color(0xFF333333),
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = Radius.circular(h * 0.15);

    // Port body
    final bodyRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), r);
    canvas.drawRRect(bodyRect, Paint()..color = color);

    // Pin detail lines (subtle darker lines inside the port)
    final linePaint = Paint()
      ..color = Color.lerp(color, Colors.black, 0.25)!
      ..strokeWidth = 1.0;

    const lineCount = 3;
    for (int i = 1; i <= lineCount; i++) {
      final y = h * (i / (lineCount + 1));
      canvas.drawLine(
        Offset(w * 0.2, y),
        Offset(w * 0.8, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(PortPainter oldDelegate) => oldDelegate.color != color;
}
