import 'dart:ui' show Size, Offset;

import 'package:flutter/material.dart';
import '../layout/switch_layout.dart';
import '../models/port_status.dart';
import '../models/switch_format.dart';
import '../painters/switch_body_painter.dart';
import 'port_widget.dart';

/// Renders a network switch device with interactive ports.
///
/// For single-unit switches (6–28P), renders one body with ports overlaid.
/// For stacked switches (30–48P), renders two bodies vertically with a gap;
/// tap either body to toggle the active unit.
class SwitchDeviceView extends StatelessWidget {
  const SwitchDeviceView({
    super.key,
    required this.size,
    required this.format,
    this.portStatuses = const {},
    this.isConfig = false,
    this.onPortHover,
    this.onPortHoverExit,
    this.onPortTap,
    this.onSwitchHover,
    this.onSwitchHoverExit,
    this.stackedPart = 0,
    this.onStackedPartChanged,
  });

  final Size size;
  final SwitchFormat format;
  final Map<int, PortStatus> portStatuses;
  final bool isConfig;
  final ValueChanged<int>? onPortHover;
  final VoidCallback? onPortHoverExit;
  final ValueChanged<int>? onPortTap;
  final VoidCallback? onSwitchHover;
  final VoidCallback? onSwitchHoverExit;
  final int stackedPart;
  final ValueChanged<int>? onStackedPartChanged;

  /// Returns port center positions for the given format and viewport size.
  static Map<int, Offset> getPortPositions(
    SwitchFormat format,
    Size viewportSize,
  ) {
    return SwitchLayout.computePortCenters(format, viewportSize);
  }

  @override
  Widget build(BuildContext context) {
    final layout = SwitchLayout.compute(
      format: format,
      viewportSize: size,
      portStatuses: portStatuses,
      isConfig: isConfig,
      stackedPart: stackedPart,
    );

    return MouseRegion(
      onEnter: (_) => onSwitchHover?.call(),
      onExit: (_) => onSwitchHoverExit?.call(),
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Body/bodies
            for (int i = 0; i < layout.bodyRects.length; i++)
              _buildBody(layout, i),

            // Ports
            for (final portData in layout.portDataList)
              PortWidget(
                data: portData,
                isConfig: isConfig,
                onHover: () => onPortHover?.call(portData.portNumber),
                onHoverExit: onPortHoverExit,
                onTap: () => onPortTap?.call(portData.portNumber),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SwitchLayoutResult layout, int bodyIndex) {
    final rect = layout.bodyRects[bodyIndex];
    final isUpper = bodyIndex == 0;
    final portsPerBody = format.isStacked ? 24 : format.totalPortsNum;

    final bool isActive;
    final double opacity;
    if (!format.isStacked) {
      isActive = false;
      opacity = 1.0;
    } else {
      isActive = (stackedPart == 1 && isUpper) ||
          (stackedPart == 2 && !isUpper);
      opacity = (stackedPart == 0 || isActive) ? 1.0 : 0.3;
    }

    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: GestureDetector(
        onTap: format.isStacked
            ? () => onStackedPartChanged?.call(isUpper ? 1 : 2)
            : null,
        child: Opacity(
          opacity: opacity,
          child: SwitchBodyWidget(
            totalPorts: portsPerBody,
            isActive: isActive,
          ),
        ),
      ),
    );
  }
}
