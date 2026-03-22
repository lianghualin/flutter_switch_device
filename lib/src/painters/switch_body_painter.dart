import 'package:flutter/material.dart';

import '../models/switch_device_theme.dart';

/// Draws a generic network switch chassis.
///
/// Visual structure (left to right):
/// - Narrow indicator panel with LEDs (power, status, inactive)
/// - Vertical divider
/// - Port area (gradient body background)
///
/// All colors are sourced from [theme].
class SwitchBodyPainter extends CustomPainter {
  SwitchBodyPainter({
    required this.totalPorts,
    required this.theme,
    this.isActive = false,
  });

  final int totalPorts;
  final bool isActive;
  final SwitchDeviceTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cornerR = h * 0.15;

    // Gradient background
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.bodyGradientStart, theme.bodyGradientEnd],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), Radius.circular(cornerR)),
      gradientPaint,
    );

    // -- Left indicator panel (~15% of body width) --
    final panelW = w * 0.15;
    final ledRadius = h * 0.08;
    final panelCenterX = panelW * 0.5;

    // Power LED (green)
    canvas.drawCircle(
      Offset(panelCenterX, h * 0.28),
      ledRadius,
      Paint()..color = theme.ledGreen,
    );

    // Status LED (yellow)
    canvas.drawCircle(
      Offset(panelCenterX, h * 0.50),
      ledRadius,
      Paint()..color = theme.ledYellow,
    );

    // Inactive LED
    canvas.drawCircle(
      Offset(panelCenterX, h * 0.72),
      ledRadius,
      Paint()..color = theme.ledInactive,
    );

    // -- Vertical divider between indicator panel and port area --
    final dividerX = panelW;
    canvas.drawLine(
      Offset(dividerX, h * 0.15),
      Offset(dividerX, h * 0.85),
      Paint()
        ..color = theme.dividerColor
        ..strokeWidth = 1.5,
    );

    // Active border (stacked highlight) — drawn last so it appears on top
    if (isActive) {
      final borderPaint = Paint()
        ..color = theme.activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1.5, 1.5, w - 3, h - 3),
          Radius.circular(cornerR),
        ),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SwitchBodyPainter old) =>
      old.totalPorts != totalPorts ||
      old.isActive != isActive ||
      old.theme != theme;
}

/// Renders a switch body inside a [PhysicalShape] for elevation & shadow.
class SwitchBodyWidget extends StatelessWidget {
  const SwitchBodyWidget({
    super.key,
    required this.totalPorts,
    required this.theme,
    this.elevation = 5,
    this.isActive = false,
  });

  final int totalPorts;
  final double elevation;
  final bool isActive;
  final SwitchDeviceTheme theme;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: _RoundedRectClipper(),
      color: theme.bodyGradientEnd,
      elevation: elevation,
      shadowColor: Colors.black.withValues(alpha: theme.shadowOpacity),
      child: CustomPaint(
        painter: SwitchBodyPainter(
          totalPorts: totalPorts,
          isActive: isActive,
          theme: theme,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RoundedRectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final r = size.height * 0.15;
    return Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(r),
      ));
  }

  @override
  bool shouldReclip(_RoundedRectClipper old) => false;
}
