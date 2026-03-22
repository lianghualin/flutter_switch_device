import 'package:flutter/material.dart';

import 'port_status.dart';

/// Color theme for [SwitchDeviceView].
///
/// Provides two built-in themes via [SwitchDeviceTheme.dark] and
/// [SwitchDeviceTheme.light]. Custom themes can be created by passing
/// values to the default constructor.
@immutable
class SwitchDeviceTheme {
  const SwitchDeviceTheme({
    required this.bodyGradientStart,
    required this.bodyGradientEnd,
    required this.portUp,
    required this.portDown,
    required this.portUnknown,
    required this.portLabelOnLight,
    required this.portLabelOnDark,
    required this.activeColor,
    required this.ledGreen,
    required this.ledYellow,
    required this.ledInactive,
    required this.dividerColor,
    required this.shadowOpacity,
  });

  /// Dark theme — matches the original hardcoded colors.
  const SwitchDeviceTheme.dark()
      : bodyGradientStart = const Color(0xFF5A5A6E),
        bodyGradientEnd = const Color(0xFF44445A),
        portUp = const Color(0xFF2CC339),
        portDown = const Color(0xFF9E9E9E),
        portUnknown = const Color(0xFF333333),
        portLabelOnLight = const Color(0xFFFFFFFF),
        portLabelOnDark = const Color(0xFFFFFFFF),
        activeColor = const Color(0xFF2CC339),
        ledGreen = const Color(0xFF49B87D),
        ledYellow = const Color(0xFFF0CC18),
        ledInactive = const Color(0xFF414142),
        dividerColor = const Color(0xFF414142),
        shadowOpacity = 0.4;

  /// Light theme — lighter body, adjusted port colors for contrast.
  const SwitchDeviceTheme.light()
      : bodyGradientStart = const Color(0xFFD8DAE0),
        bodyGradientEnd = const Color(0xFFC2C4CC),
        portUp = const Color(0xFF34A853),
        portDown = const Color(0xFFBDBDBD),
        portUnknown = const Color(0xFFE0E0E0),
        portLabelOnLight = const Color(0xFF444444),
        portLabelOnDark = const Color(0xFFFFFFFF),
        activeColor = const Color(0xFF34A853),
        ledGreen = const Color(0xFF34A853),
        ledYellow = const Color(0xFFE8A317),
        ledInactive = const Color(0xFFB0B2BA),
        dividerColor = const Color(0xFFB0B2BA),
        shadowOpacity = 0.12;

  final Color bodyGradientStart;
  final Color bodyGradientEnd;
  final Color portUp;
  final Color portDown;
  final Color portUnknown;

  /// Label text color used on light-colored ports (down/unknown in light theme).
  final Color portLabelOnLight;

  /// Label text color used on dark-colored ports (up, or down/unknown in dark theme).
  final Color portLabelOnDark;

  final Color activeColor;
  final Color ledGreen;
  final Color ledYellow;
  final Color ledInactive;
  final Color dividerColor;
  final double shadowOpacity;

  /// Returns the appropriate label color for a port with the given [portColor].
  Color labelColorFor(Color portColor) {
    return portColor.computeLuminance() > 0.5
        ? portLabelOnLight
        : portLabelOnDark;
  }

  /// Returns the port color for the given status, respecting config/invalid flags.
  Color portColorForStatus(
    PortStatus status, {
    bool isConfig = false,
    bool isInvalid = false,
  }) {
    if (isConfig) return portDown;
    if (isInvalid) return portUnknown;
    return switch (status) {
      PortStatus.up => portUp,
      PortStatus.down => portDown,
      PortStatus.unknown => portUnknown,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwitchDeviceTheme &&
          bodyGradientStart == other.bodyGradientStart &&
          bodyGradientEnd == other.bodyGradientEnd &&
          portUp == other.portUp &&
          portDown == other.portDown &&
          portUnknown == other.portUnknown &&
          portLabelOnLight == other.portLabelOnLight &&
          portLabelOnDark == other.portLabelOnDark &&
          activeColor == other.activeColor &&
          ledGreen == other.ledGreen &&
          ledYellow == other.ledYellow &&
          ledInactive == other.ledInactive &&
          dividerColor == other.dividerColor &&
          shadowOpacity == other.shadowOpacity;

  @override
  int get hashCode => Object.hash(
        bodyGradientStart,
        bodyGradientEnd,
        portUp,
        portDown,
        portUnknown,
        portLabelOnLight,
        portLabelOnDark,
        activeColor,
        ledGreen,
        ledYellow,
        ledInactive,
        dividerColor,
        shadowOpacity,
      );
}
