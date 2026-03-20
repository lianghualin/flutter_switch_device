import 'dart:ui';

/// Describes the physical layout of a network switch — port positions,
/// dimensions, and stacking configuration.
///
/// Port offsets are **normalized** (0.0–1.0) and scaled by the center device
/// size at render time.
class SwitchFormat {
  const SwitchFormat({
    required this.evenPortOffsetR,
    required this.oddPortOffsetR,
    required this.totalPortsNum,
    this.validPortsNum,
    this.isStacked = false,
    this.hSizeFactor = 0.15,
    this.wSizeFactor = 1.0,
    this.minWidth = 1500.0,
    this.minHeight = 800.0,
  });

  /// Normalized (x, y) positions for even-numbered ports (2, 4, 6 …).
  final List<Offset> evenPortOffsetR;

  /// Normalized (x, y) positions for odd-numbered ports (1, 3, 5 …).
  final List<Offset> oddPortOffsetR;

  /// Total port slots (48 for stacked configurations).
  final int totalPortsNum;

  /// Actual valid ports (null for single-unit switches).
  final int? validPortsNum;

  /// Whether this is a stacked (two-unit) switch.
  final bool isStacked;

  /// Height of the switch body as a fraction of the center device size.
  final double hSizeFactor;

  /// Width of the switch body as a fraction of the center device size.
  final double wSizeFactor;

  /// Minimum viewport width for this layout.
  final double minWidth;

  /// Minimum viewport height for this layout.
  final double minHeight;
}
