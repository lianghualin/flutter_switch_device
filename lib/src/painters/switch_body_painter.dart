import 'dart:math';
import 'package:flutter/material.dart';

/// Draws a generic network switch chassis.
///
/// Visual structure (left to right):
/// - Indicator LEDs (green power, yellow status, grey port indicators)
/// - Two horizontal status bars
/// - A display panel (light grey screen area)
///
/// Parameterized by [totalPorts] to scale the number of indicator LEDs.
/// When [isActive] is true, a green border is drawn around the chassis to
/// indicate the unit is the currently-selected (stacked active) switch.
class SwitchBodyPainter extends CustomPainter {
  final int totalPorts;
  final bool isActive;

  SwitchBodyPainter({required this.totalPorts, this.isActive = false});

  static const _bodyGradientStart = Color(0xFF5A5A6E);
  static const _bodyGradientEnd = Color(0xFF44445A);
  static const _activeColor = Color(0xFF2CC339);
  static const _darkDetail = Color(0xFF414142);
  static const _screenBorder = Color(0xFFEDEEF0);
  static const _screenFill = Color(0xFFE8E9EB);
  static const _ledGreen = Color(0xFF49B87D);
  static const _ledYellow = Color(0xFFF0CC18);

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
        colors: const [_bodyGradientStart, _bodyGradientEnd],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, h), Radius.circular(cornerR)),
      gradientPaint,
    );

    // -- Left panel metrics --
    final leftPanelW = w * 0.42;
    final int ledCount = min((totalPorts / 2).ceil(), 8);
    final ledRadius = h * 0.07;
    final ledStartX = w * 0.03;
    final ledSpacing = (leftPanelW - w * 0.06) / max(ledCount, 1);

    // -- Top LED row --
    final ledY = h * 0.26;
    for (int i = 0; i < ledCount; i++) {
      final cx = ledStartX + ledSpacing * (i + 0.5);
      final color = i == 0
          ? _ledGreen
          : i == 1
              ? _ledYellow
              : _darkDetail;
      canvas.drawCircle(Offset(cx, ledY), ledRadius, Paint()..color = color);
    }

    // -- Status bars --
    final barPaint = Paint()..color = _darkDetail;
    final barH = h * 0.06;
    final barX = w * 0.03;
    final barW = leftPanelW - w * 0.06;
    final barR = Radius.circular(barH / 2);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barX, h * 0.42, barW, barH), barR),
      barPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(barX, h * 0.56, barW, barH), barR),
      barPaint,
    );

    // -- Bottom LED row --
    final btmLedY = h * 0.76;
    final btmPaint = Paint()..color = _darkDetail;
    for (int i = 0; i < ledCount; i++) {
      final cx = ledStartX + ledSpacing * (i + 0.5);
      canvas.drawCircle(Offset(cx, btmLedY), ledRadius, btmPaint);
    }

    // -- Display screen --
    final screenX = leftPanelW + w * 0.02;
    final screenY = h * 0.12;
    final screenW = w - screenX - w * 0.02;
    final screenH = h - screenY * 2;
    final screenR = Radius.circular(h * 0.06);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(screenX - 1, screenY - 1, screenW + 2, screenH + 2),
        screenR,
      ),
      Paint()..color = _screenBorder,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(screenX, screenY, screenW, screenH),
        screenR,
      ),
      Paint()..color = _screenFill,
    );

    // Active border (stacked highlight) — drawn last so it appears on top
    if (isActive) {
      final borderPaint = Paint()
        ..color = _activeColor
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
      old.totalPorts != totalPorts || old.isActive != isActive;
}

/// Renders a switch body inside a [PhysicalShape] for elevation & shadow.
///
/// Pass [isActive] to highlight this unit with a green border (used when
/// this switch is the active unit in a stack view).
class SwitchBodyWidget extends StatelessWidget {
  final int totalPorts;
  final double elevation;
  final bool isActive;

  const SwitchBodyWidget({
    super.key,
    required this.totalPorts,
    this.elevation = 5,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: _RoundedRectClipper(),
      color: SwitchBodyPainter._bodyGradientEnd,
      elevation: elevation,
      shadowColor: Colors.black,
      child: CustomPaint(
        painter: SwitchBodyPainter(totalPorts: totalPorts, isActive: isActive),
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
