import 'dart:ui';

import 'port_status.dart';

/// Computed layout data for a single port, ready to be rendered.
class PortData {
  const PortData({
    required this.portNumber,
    required this.position,
    required this.width,
    required this.height,
    this.status = PortStatus.unknown,
    this.isInvalid = false,
    this.opacity = 1.0,
    this.showLabel = true,
    this.label,
    this.isSelected = false,
  });

  /// 1-based port number.
  final int portNumber;

  /// Absolute top-left position within the parent Stack.
  final Offset position;

  /// Port icon width.
  final double width;

  /// Port icon height.
  final double height;

  /// Current port status.
  final PortStatus status;

  /// Whether this port exceeds the valid port count (greyed out).
  final bool isInvalid;

  /// Opacity (1.0 = visible, 0.3 = dimmed for stacked switches).
  final double opacity;

  /// Whether to show the port number label.
  final bool showLabel;

  /// Optional custom label (defaults to port number string).
  final String? label;

  /// Whether this port is currently selected (spotlight mode).
  final bool isSelected;
}
