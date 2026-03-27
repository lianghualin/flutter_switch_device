import 'dart:math';
import 'dart:ui';

import '../models/port_data.dart';
import '../models/port_status.dart';
import '../models/switch_format.dart';

/// Result of a full layout computation, ready for rendering.
class SwitchLayoutResult {
  const SwitchLayoutResult({
    required this.portCenters,
    required this.portDataList,
    required this.bodyRects,
    required this.portWidth,
    required this.portHeight,
    required this.centerSize,
  });

  final Map<int, Offset> portCenters;
  final List<PortData> portDataList;
  final List<Rect> bodyRects;
  final double portWidth;
  final double portHeight;
  final double centerSize;
}

/// Pure-calculation layout engine.
class SwitchLayout {
  SwitchLayout._();

  /// Returns port center positions in viewport coordinates.
  static Map<int, Offset> computePortCenters(
    SwitchFormat format,
    Size viewportSize,
  ) {
    final cs = _centerSize(format, viewportSize);
    final origin = _origin(format, viewportSize, cs);
    return _buildPortCenters(format, cs, origin);
  }

  /// Full layout computation for rendering.
  static SwitchLayoutResult compute({
    required SwitchFormat format,
    required Size viewportSize,
    Map<int, PortStatus> portStatuses = const {},
    bool isConfig = false,
    int stackedPart = 0,
    Set<int> selectedPorts = const {},
    double unselectedPortOpacity = 0.15,
  }) {
    final cs = _centerSize(format, viewportSize);
    final origin = _origin(format, viewportSize, cs);
    final portCenters = _buildPortCenters(format, cs, origin);

    final portWidth = _computePortWidth(format, cs);
    final portHeight = portWidth * 0.75;

    final bodyRects = _computeBodyRects(format, cs, origin, portCenters);

    final portDataList = _buildPortDataList(
      format: format,
      portCenters: portCenters,
      portWidth: portWidth,
      portHeight: portHeight,
      portStatuses: portStatuses,
      isConfig: isConfig,
      stackedPart: stackedPart,
      selectedPorts: selectedPorts,
      unselectedPortOpacity: unselectedPortOpacity,
    );

    return SwitchLayoutResult(
      portCenters: portCenters,
      portDataList: portDataList,
      bodyRects: bodyRects,
      portWidth: portWidth,
      portHeight: portHeight,
      centerSize: cs,
    );
  }

  static double _centerSize(SwitchFormat format, Size viewportSize) {
    final scaleX = viewportSize.width / format.minWidth;
    final scaleY = viewportSize.height / format.minHeight;
    return 500.0 * min(scaleX, scaleY);
  }

  static Offset _origin(SwitchFormat format, Size viewportSize, double cs) {
    final centerX = (viewportSize.width - cs) / 2;

    double sumY = 0;
    int count = 0;
    for (final o in format.oddPortOffsetR) {
      sumY += o.dy;
      count++;
    }
    for (final o in format.evenPortOffsetR) {
      sumY += o.dy;
      count++;
    }
    final midNormY = count > 0 ? sumY / count : 0.5;
    final centerY = viewportSize.height / 2 - cs * midNormY;

    return Offset(centerX, centerY);
  }

  static Map<int, Offset> _buildPortCenters(
    SwitchFormat format,
    double cs,
    Offset origin,
  ) {
    final map = <int, Offset>{};

    for (int i = 0; i < format.oddPortOffsetR.length; i++) {
      final portNum = i * 2 + 1;
      if (portNum > format.totalPortsNum) break;
      final o = format.oddPortOffsetR[i];
      map[portNum] = Offset(origin.dx + cs * o.dx, origin.dy + cs * o.dy);
    }

    for (int i = 0; i < format.evenPortOffsetR.length; i++) {
      final portNum = i * 2 + 2;
      if (portNum > format.totalPortsNum) break;
      final o = format.evenPortOffsetR[i];
      map[portNum] = Offset(origin.dx + cs * o.dx, origin.dy + cs * o.dy);
    }

    return map;
  }

  static double _computePortWidth(SwitchFormat format, double cs) {
    // Merge all port X offsets and sort to find the true minimum spacing
    // between any two adjacent ports (not just odd-to-odd).
    final allX = <double>[
      for (final o in format.oddPortOffsetR) o.dx,
      for (final o in format.evenPortOffsetR) o.dx,
    ]..sort();

    if (allX.length < 2) return cs * 0.04;

    double minSpacing = double.infinity;
    for (int i = 1; i < allX.length; i++) {
      final spacing = allX[i] - allX[i - 1];
      if (spacing > 0 && spacing < minSpacing) {
        minSpacing = spacing;
      }
    }
    final rawWidth = cs * minSpacing * 0.8;
    return rawWidth.clamp(10.0, 25.0);
  }

  static List<Rect> _computeBodyRects(
    SwitchFormat format,
    double cs,
    Offset origin,
    Map<int, Offset> portCenters,
  ) {
    final bodyWidth = cs * format.wSizeFactor;
    final bodyLeft = origin.dx;

    if (!format.isStacked) {
      return [
        _bodyRectFromPorts(portCenters.values.toList(), bodyWidth, bodyLeft, cs)
      ];
    }

    final upperPorts = <Offset>[];
    final lowerPorts = <Offset>[];
    for (final entry in portCenters.entries) {
      if (entry.key <= 24) {
        upperPorts.add(entry.value);
      } else {
        lowerPorts.add(entry.value);
      }
    }

    return [
      _bodyRectFromPorts(upperPorts, bodyWidth, bodyLeft, cs),
      _bodyRectFromPorts(lowerPorts, bodyWidth, bodyLeft, cs),
    ];
  }

  static Rect _bodyRectFromPorts(
    List<Offset> ports,
    double bodyWidth,
    double bodyLeft,
    double cs,
  ) {
    if (ports.isEmpty) return Rect.zero;

    double minY = ports.first.dy;
    double maxY = ports.first.dy;
    for (final p in ports) {
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    final portSpan = maxY - minY;
    final padding = max(portSpan * 0.8, cs * 0.03);

    return Rect.fromLTWH(bodyLeft, minY - padding, bodyWidth, portSpan + padding * 2);
  }

  static List<PortData> _buildPortDataList({
    required SwitchFormat format,
    required Map<int, Offset> portCenters,
    required double portWidth,
    required double portHeight,
    required Map<int, PortStatus> portStatuses,
    required bool isConfig,
    required int stackedPart,
    required Set<int> selectedPorts,
    required double unselectedPortOpacity,
  }) {
    final validPorts = format.validPortsNum ?? format.totalPortsNum;
    final hasSelection = selectedPorts.isNotEmpty;

    return portCenters.entries.map((entry) {
      final portNum = entry.key;
      final center = entry.value;
      final isInvalid = portNum > validPorts;
      final isUpperBody = portNum <= 24;
      final isSelected = selectedPorts.contains(portNum);

      double opacity = 1.0;
      if (format.isStacked && stackedPart > 0) {
        final isActiveBody =
            (stackedPart == 1 && isUpperBody) || (stackedPart == 2 && !isUpperBody);
        opacity = isActiveBody ? 1.0 : 0.3;
      }
      // Spotlight mode: dim unselected ports when any ports are selected.
      if (hasSelection && !isSelected) {
        opacity *= unselectedPortOpacity;
      }

      return PortData(
        portNumber: portNum,
        position: Offset(center.dx - portWidth / 2, center.dy - portHeight / 2),
        width: portWidth,
        height: portHeight,
        status: isConfig
            ? PortStatus.down
            : (portStatuses[portNum] ?? PortStatus.unknown),
        isInvalid: isInvalid,
        opacity: opacity,
        isSelected: isSelected,
      );
    }).toList()
      ..sort((a, b) => a.portNumber.compareTo(b.portNumber));
  }
}
