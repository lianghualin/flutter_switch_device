import 'package:flutter/material.dart';

import '../models/switch_device_theme.dart';
import '../painters/switch_icon_painter.dart';

/// A compact switch device icon for use in topology views and device lists.
///
/// Renders a small switch chassis with 3 LEDs, a divider, and a 2x8 port grid.
/// Width is set by [size]; height is derived from a 2.5:1 aspect ratio.
///
/// If [theme] is omitted, the widget auto-detects from the ambient
/// [Theme.brightness].
class SwitchIconWidget extends StatelessWidget {
  const SwitchIconWidget({
    super.key,
    required this.size,
    this.elevation = 5,
    this.theme,
  });

  /// Icon width in logical pixels. Height = size / 2.5.
  final double size;

  /// Material elevation for the PhysicalShape shadow.
  final double elevation;

  /// Color theme. If null, auto-detected from [Theme.of(context).brightness].
  final SwitchDeviceTheme? theme;

  static const double _aspectRatio = 2.5;

  @override
  Widget build(BuildContext context) {
    final resolvedTheme = theme ??
        (Theme.of(context).brightness == Brightness.dark
            ? const SwitchDeviceTheme.dark()
            : const SwitchDeviceTheme.light());

    final height = size / _aspectRatio;

    return SizedBox(
      width: size,
      height: height,
      child: PhysicalShape(
        clipper: _IconRoundedRectClipper(),
        color: resolvedTheme.bodyGradientEnd,
        elevation: elevation,
        shadowColor:
            Colors.black.withValues(alpha: resolvedTheme.shadowOpacity),
        child: CustomPaint(
          painter: SwitchIconPainter(theme: resolvedTheme),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _IconRoundedRectClipper extends CustomClipper<Path> {
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
  bool shouldReclip(_IconRoundedRectClipper old) => false;
}
