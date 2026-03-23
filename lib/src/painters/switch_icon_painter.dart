import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/switch_device_theme.dart';

/// Draws a compact switch icon for use as a small device indicator.
///
/// Visual structure (left to right):
/// - Narrow panel with 3 vertically-stacked LEDs (power, status, inactive)
/// - Vertical divider
/// - Port area: 2 rows x 8 columns of small squares, grouped 4+4
///
/// All colors are sourced from [theme].
class SwitchIconPainter extends CustomPainter {
  SwitchIconPainter({required this.theme});

  final SwitchDeviceTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cornerR = h * 0.15;

    _drawBody(canvas, w, h, cornerR);
    _drawLeds(canvas, w, h);
    _drawDivider(canvas, w, h);
    _drawPortGrid(canvas, w, h);
    _drawEdgeHighlight(canvas, w, h, cornerR);
  }

  void _drawBody(Canvas canvas, double w, double h, double cornerR) {
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.bodyGradientStart, theme.bodyGradientEnd],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(cornerR),
      ),
      gradientPaint,
    );
  }

  void _drawLeds(Canvas canvas, double w, double h) {
    final panelW = w * 0.15;
    final cx = panelW * 0.5;
    final ledR = h * 0.08;

    final leds = [
      (y: h * 0.28, color: theme.ledGreen, glowRadius: 3.0),
      (y: h * 0.50, color: theme.ledYellow, glowRadius: 2.0),
      (y: h * 0.72, color: theme.ledInactive, glowRadius: 0.0),
    ];

    for (final led in leds) {
      // Glow effect
      if (led.glowRadius > 0) {
        canvas.drawCircle(
          Offset(cx, led.y),
          ledR + led.glowRadius,
          Paint()
            ..color = led.color.withValues(alpha: 0.3)
            ..maskFilter = MaskFilter.blur(
              BlurStyle.normal,
              led.glowRadius,
            ),
        );
      }
      // LED circle
      canvas.drawCircle(
        Offset(cx, led.y),
        ledR,
        Paint()..color = led.color,
      );
    }
  }

  void _drawDivider(Canvas canvas, double w, double h) {
    final dividerX = w * 0.15;
    canvas.drawLine(
      Offset(dividerX, h * 0.15),
      Offset(dividerX, h * 0.85),
      Paint()
        ..color = theme.dividerColor
        ..strokeWidth = 1.0,
    );
  }

  void _drawPortGrid(Canvas canvas, double w, double h) {
    // Port area starts after LED panel + small padding
    final portAreaLeft = w * 0.19;
    final portAreaRight = w * 0.95;
    final portAreaTop = h * 0.20;
    final portAreaBottom = h * 0.80;

    final portAreaW = portAreaRight - portAreaLeft;
    final portAreaH = portAreaBottom - portAreaTop;

    // 2 rows, 8 columns per row, grouped 4+4
    const rows = 2;
    const colsPerGroup = 4;
    const groups = 2;

    final gapW = portAreaW * 0.06; // gap between the two groups of 4
    final groupW = (portAreaW - gapW) / groups;
    final portSize = groupW / (colsPerGroup + 1); // even spacing within group
    final spacingX = (groupW - colsPerGroup * portSize) / (colsPerGroup + 1);
    final spacingY = (portAreaH - rows * portSize) / (rows + 1);

    // Theme-aware port color: use divider color at 40% opacity so ports
    // remain visible on both dark and light body backgrounds.
    final portPaint = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.4);

    for (int row = 0; row < rows; row++) {
      final y = portAreaTop + spacingY * (row + 1) + portSize * row;
      for (int g = 0; g < groups; g++) {
        final groupLeft = portAreaLeft + g * (groupW + gapW);
        for (int c = 0; c < colsPerGroup; c++) {
          final x = groupLeft + spacingX * (c + 1) + portSize * c;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, portSize, portSize),
              const Radius.circular(0.5),
            ),
            portPaint,
          );
        }
      }
    }
  }

  void _drawEdgeHighlight(Canvas canvas, double w, double h, double cornerR) {
    final highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(w * 0.2, 0),
        Offset(w * 0.8, 0),
        [
          Colors.transparent,
          const Color(0x1FFFFFFF), // rgba(255,255,255,0.12)
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      )
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(cornerR, 0.5)
      ..lineTo(w - cornerR, 0.5);
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(SwitchIconPainter old) => old.theme != theme;
}
