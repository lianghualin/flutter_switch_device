# flutter_switch_device Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement all remaining components of the `flutter_switch_device` package — layout engine, port painter, port widget, main widget, barrel export, and example app — so the package renders programmatic network switches with interactive ports.

**Architecture:** Pure-calculation layout engine converts `SwitchFormat` normalized offsets into absolute pixel positions. `PortPainter` (CustomPainter) draws individual port icons. `PortWidget` wraps the painter with hover animation. `SwitchDeviceView` composes body + ports in a Stack, managing hover/tap state and stacked toggle logic.

**Tech Stack:** Flutter (dart), `flutter_test` for unit/widget tests. No external packages.

**Spec:** `docs/superpowers/specs/2026-03-20-flutter-switch-device-design.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Modify | `lib/src/presets/switch_presets.dart` | Update 6–12P presets to single-row Y offsets |
| Create | `lib/src/layout/switch_layout.dart` | Pure calculation: format + viewport → port positions + body rects |
| Create | `test/layout/switch_layout_test.dart` | Unit tests for layout engine |
| Create | `lib/src/painters/port_painter.dart` | CustomPainter for one port icon + `colorForStatus()` |
| Create | `test/painters/port_painter_test.dart` | Unit tests for color mapping |
| Modify | `lib/src/painters/switch_body_painter.dart` | Add gradient background + `isActive` green border |
| Create | `lib/src/widgets/port_widget.dart` | Port with hover float animation, tap handler, label |
| Create | `test/widgets/port_widget_test.dart` | Widget tests for interactions |
| Create | `lib/src/widgets/switch_device_view.dart` | Main public widget composing body + ports |
| Create | `test/widgets/switch_device_view_test.dart` | Widget tests for rendering + callbacks |
| Modify | `lib/flutter_switch_device.dart` | Barrel export (replace Calculator placeholder) |
| Modify | `test/flutter_switch_device_test.dart` | Replace Calculator test with import smoke test |
| Modify | `example/lib/main.dart` | Interactive demo app |

---

### Task 1: Update Presets for Tier 1 Single-Row Layout

**Files:**
- Modify: `lib/src/presets/switch_presets.dart:9-87` (Switch6P through Switch12P)

Per spec, 6–12P switches use a single row (all ports at the same Y). Currently odd/even have different Y values (0.185 vs 0.223). Update both to share a single Y value (0.204, the midpoint).

- [ ] **Step 1: Update Switch6P–Switch12P odd/even Y values to 0.204**

In `lib/src/presets/switch_presets.dart`, change all `oddPortOffsetR` and `evenPortOffsetR` entries for Switch6P, Switch8P, Switch10P, and Switch12P so both use Y = 0.204. Keep X values unchanged.

Example for Switch6P (apply same pattern to 8P, 10P, 12P):
```dart
class Switch6P extends SwitchFormat {
  const Switch6P()
      : super(
          evenPortOffsetR: const [
            Offset(0.53, 0.204),
            Offset(0.58, 0.204),
            Offset(0.63, 0.204),
          ],
          oddPortOffsetR: const [
            Offset(0.53, 0.204),
            Offset(0.58, 0.204),
            Offset(0.63, 0.204),
          ],
          totalPortsNum: 6,
        );
}
```

- [ ] **Step 2: Verify project compiles**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter analyze`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add lib/src/presets/switch_presets.dart
git commit -m "refactor: update 6-12P presets to single-row layout (Tier 1)"
```

---

### Task 2: Layout Engine

**Files:**
- Create: `lib/src/layout/switch_layout.dart`
- Create: `test/layout/switch_layout_test.dart`

Pure calculation module. Takes `SwitchFormat` + viewport `Size`, returns port center positions and body rects. No widget dependencies.

- [ ] **Step 1: Write failing tests for `SwitchLayout.computePortCenters`**

Create `test/layout/switch_layout_test.dart`:

```dart
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/layout/switch_layout.dart';
import 'package:flutter_switch_device/src/presets/switch_presets.dart';

void main() {
  group('SwitchLayout.computePortCenters', () {
    test('returns correct number of ports for Switch6P', () {
      final positions = SwitchLayout.computePortCenters(
        const Switch6P(),
        const Size(800, 400),
      );
      expect(positions.length, 6);
      expect(positions.keys, containsAll([1, 2, 3, 4, 5, 6]));
    });

    test('returns correct number of ports for Switch24P', () {
      final positions = SwitchLayout.computePortCenters(
        const Switch24P(),
        const Size(800, 400),
      );
      expect(positions.length, 24);
    });

    test('returns correct number of ports for stacked 48P', () {
      final positions = SwitchLayout.computePortCenters(
        const Switch48PStacked(),
        const Size(1500, 800),
      );
      expect(positions.length, 48);
    });

    test('odd ports have lower Y than even ports for 2-row layout', () {
      final positions = SwitchLayout.computePortCenters(
        const Switch24P(),
        const Size(800, 400),
      );
      // Odd ports (top row) should have smaller Y than even ports (bottom row)
      expect(positions[1]!.dy, lessThan(positions[2]!.dy));
    });

    test('single-row layout has same Y for odd and even ports', () {
      final positions = SwitchLayout.computePortCenters(
        const Switch6P(),
        const Size(800, 400),
      );
      expect(positions[1]!.dy, positions[2]!.dy);
    });

    test('port X increases with port number within same row', () {
      final positions = SwitchLayout.computePortCenters(
        const Switch24P(),
        const Size(800, 400),
      );
      // Odd ports should increase in X: port 1 < port 3 < port 5
      expect(positions[1]!.dx, lessThan(positions[3]!.dx));
      expect(positions[3]!.dx, lessThan(positions[5]!.dx));
    });

    test('all port positions are within viewport bounds', () {
      final size = const Size(800, 400);
      final positions = SwitchLayout.computePortCenters(
        const Switch24P(),
        size,
      );
      for (final pos in positions.values) {
        expect(pos.dx, greaterThanOrEqualTo(0));
        expect(pos.dx, lessThanOrEqualTo(size.width));
        expect(pos.dy, greaterThanOrEqualTo(0));
        expect(pos.dy, lessThanOrEqualTo(size.height));
      }
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/layout/switch_layout_test.dart`
Expected: FAIL — `switch_layout.dart` does not exist.

- [ ] **Step 3: Implement `SwitchLayout`**

Create `lib/src/layout/switch_layout.dart`:

```dart
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

  /// Port number → center position in viewport coordinates.
  final Map<int, Offset> portCenters;

  /// Full render data for every port.
  final List<PortData> portDataList;

  /// Body rectangle(s): 1 for single, 2 for stacked.
  final List<Rect> bodyRects;

  /// Computed port icon width.
  final double portWidth;

  /// Computed port icon height.
  final double portHeight;

  /// The computed center device size.
  final double centerSize;
}

/// Pure-calculation layout engine.
///
/// Converts [SwitchFormat] normalized offsets + viewport [Size] into absolute
/// pixel positions for ports and body rectangles.
class SwitchLayout {
  SwitchLayout._();

  /// Returns port center positions in viewport coordinates.
  ///
  /// Synchronous and deterministic — safe to call from a static context.
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

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Compute the center device size from the viewport.
  static double _centerSize(SwitchFormat format, Size viewportSize) {
    final scaleX = viewportSize.width / format.minWidth;
    final scaleY = viewportSize.height / format.minHeight;
    return 500.0 * min(scaleX, scaleY);
  }

  /// Compute the top-left origin of the coordinate space.
  ///
  /// Horizontally: the body is centered in the viewport.
  /// Vertically: the port area midpoint aligns with the viewport center.
  static Offset _origin(SwitchFormat format, Size viewportSize, double cs) {
    final centerX = (viewportSize.width - cs) / 2;

    // Find the vertical midpoint of all port offsets.
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

  /// Build the port-number → center-offset map.
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

  /// Derive port width from the minimum horizontal spacing between adjacent
  /// ports in the same row.
  static double _computePortWidth(SwitchFormat format, double cs) {
    final offsets = format.oddPortOffsetR;
    if (offsets.length < 2) return cs * 0.04;

    double minSpacing = double.infinity;
    for (int i = 1; i < offsets.length; i++) {
      final spacing = (offsets[i].dx - offsets[i - 1].dx).abs();
      if (spacing > 0 && spacing < minSpacing) {
        minSpacing = spacing;
      }
    }
    // Port occupies ~80% of the spacing, clamped to a reasonable range.
    final rawWidth = cs * minSpacing * 0.8;
    return rawWidth.clamp(10.0, 25.0);
  }

  /// Compute body rect(s). Single → 1 rect, stacked → 2 rects.
  static List<Rect> _computeBodyRects(
    SwitchFormat format,
    double cs,
    Offset origin,
    Map<int, Offset> portCenters,
  ) {
    final bodyWidth = cs * format.wSizeFactor;
    final bodyLeft = origin.dx;

    if (!format.isStacked) {
      return [_bodyRectFromPorts(portCenters.values.toList(), bodyWidth, bodyLeft, cs)];
    }

    // Stacked: split ports into upper (1–24) and lower (25–48).
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

  /// Compute a body rect that contains the given port centers with padding.
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

  /// Build [PortData] list for rendering.
  static List<PortData> _buildPortDataList({
    required SwitchFormat format,
    required Map<int, Offset> portCenters,
    required double portWidth,
    required double portHeight,
    required Map<int, PortStatus> portStatuses,
    required bool isConfig,
    required int stackedPart,
  }) {
    final validPorts = format.validPortsNum ?? format.totalPortsNum;

    return portCenters.entries.map((entry) {
      final portNum = entry.key;
      final center = entry.value;
      final isInvalid = portNum > validPorts;
      final isUpperBody = portNum <= 24;

      // Determine opacity for stacked switches.
      double opacity = 1.0;
      if (format.isStacked && stackedPart > 0) {
        final isActiveBody =
            (stackedPart == 1 && isUpperBody) || (stackedPart == 2 && !isUpperBody);
        opacity = isActiveBody ? 1.0 : 0.3;
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
      );
    }).toList()
      ..sort((a, b) => a.portNumber.compareTo(b.portNumber));
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/layout/switch_layout_test.dart`
Expected: All PASS.

- [ ] **Step 5: Write additional tests for `SwitchLayout.compute`**

Append to `test/layout/switch_layout_test.dart`:

```dart
  group('SwitchLayout.compute', () {
    test('returns one body rect for single switch', () {
      final result = SwitchLayout.compute(
        format: const Switch24P(),
        viewportSize: const Size(800, 400),
      );
      expect(result.bodyRects.length, 1);
    });

    test('returns two body rects for stacked switch', () {
      final result = SwitchLayout.compute(
        format: const Switch48PStacked(),
        viewportSize: const Size(1500, 800),
      );
      expect(result.bodyRects.length, 2);
      // Upper body should be above lower body
      expect(result.bodyRects[0].top, lessThan(result.bodyRects[1].top));
    });

    test('portDataList length matches totalPortsNum', () {
      final result = SwitchLayout.compute(
        format: const Switch24P(),
        viewportSize: const Size(800, 400),
      );
      expect(result.portDataList.length, 24);
    });

    test('invalid ports are marked for stacked switch with validPortsNum', () {
      final result = SwitchLayout.compute(
        format: const Switch30PStacked(),
        viewportSize: const Size(1500, 800),
      );
      final validPorts = result.portDataList.where((p) => !p.isInvalid);
      final invalidPorts = result.portDataList.where((p) => p.isInvalid);
      expect(validPorts.length, 30);
      expect(invalidPorts.length, 18); // 48 - 30
    });

    test('config mode sets all port statuses to down', () {
      final result = SwitchLayout.compute(
        format: const Switch6P(),
        viewportSize: const Size(800, 400),
        portStatuses: {1: PortStatus.up, 2: PortStatus.up},
        isConfig: true,
      );
      for (final port in result.portDataList) {
        expect(port.status, PortStatus.down);
      }
    });

    test('stacked active part has full opacity, inactive has 0.3', () {
      final result = SwitchLayout.compute(
        format: const Switch48PStacked(),
        viewportSize: const Size(1500, 800),
        stackedPart: 1, // upper active
      );
      final upperPort = result.portDataList.firstWhere((p) => p.portNumber == 1);
      final lowerPort = result.portDataList.firstWhere((p) => p.portNumber == 25);
      expect(upperPort.opacity, 1.0);
      expect(lowerPort.opacity, 0.3);
    });

    test('portWidth and portHeight are positive', () {
      final result = SwitchLayout.compute(
        format: const Switch24P(),
        viewportSize: const Size(800, 400),
      );
      expect(result.portWidth, greaterThan(0));
      expect(result.portHeight, greaterThan(0));
    });
  });
```

- [ ] **Step 6: Run all layout tests**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/layout/switch_layout_test.dart`
Expected: All PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/src/layout/switch_layout.dart test/layout/switch_layout_test.dart
git commit -m "feat: add layout engine (SwitchLayout) with unit tests"
```

---

### Task 3: Port Painter

**Files:**
- Create: `lib/src/painters/port_painter.dart`
- Create: `test/painters/port_painter_test.dart`

CustomPainter for a single port icon. Includes `colorForStatus()` static helper.

- [ ] **Step 1: Write failing tests for `PortPainter.colorForStatus`**

Create `test/painters/port_painter_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/models/port_status.dart';
import 'package:flutter_switch_device/src/painters/port_painter.dart';

void main() {
  group('PortPainter.colorForStatus', () {
    test('up returns green', () {
      expect(PortPainter.colorForStatus(PortStatus.up), const Color(0xFF2CC339));
    });

    test('down returns grey', () {
      expect(PortPainter.colorForStatus(PortStatus.down), const Color(0xFF9E9E9E));
    });

    test('unknown returns dark grey', () {
      expect(PortPainter.colorForStatus(PortStatus.unknown), const Color(0xFF333333));
    });

    test('config mode always returns grey', () {
      expect(
        PortPainter.colorForStatus(PortStatus.up, isConfig: true),
        const Color(0xFF9E9E9E),
      );
    });

    test('invalid port returns dark grey', () {
      expect(
        PortPainter.colorForStatus(PortStatus.up, isInvalid: true),
        const Color(0xFF333333),
      );
    });
  });

  group('PortPainter', () {
    test('shouldRepaint returns true when color changes', () {
      final a = PortPainter(color: Colors.green);
      final b = PortPainter(color: Colors.red);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns false when color is same', () {
      final a = PortPainter(color: Colors.green);
      final b = PortPainter(color: Colors.green);
      expect(a.shouldRepaint(b), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/painters/port_painter_test.dart`
Expected: FAIL — `port_painter.dart` does not exist.

- [ ] **Step 3: Implement `PortPainter`**

Create `lib/src/painters/port_painter.dart`:

```dart
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

    final lineCount = 3;
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/painters/port_painter_test.dart`
Expected: All PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/painters/port_painter.dart test/painters/port_painter_test.dart
git commit -m "feat: add PortPainter with colorForStatus helper"
```

---

### Task 4: Enhance SwitchBodyPainter

**Files:**
- Modify: `lib/src/painters/switch_body_painter.dart`

Add gradient background (#5a5a6e → #44445a) and `isActive` green border for stacked active unit.

- [ ] **Step 1: Add `isActive` parameter and gradient to `SwitchBodyPainter`**

In `lib/src/painters/switch_body_painter.dart`, update `SwitchBodyPainter`:

1. Add `isActive` field (default `false`).
2. At the start of `paint()`, draw a gradient fill over the full rect.
3. At the end of `paint()`, if `isActive`, draw a green border.
4. Update `shouldRepaint` to check `isActive`.

Updated class (key changes):

```dart
class SwitchBodyPainter extends CustomPainter {
  final int totalPorts;
  final bool isActive;

  SwitchBodyPainter({required this.totalPorts, this.isActive = false});

  // Colors updated per spec
  static const _bodyGradientStart = Color(0xFF5A5A6E);
  static const _bodyGradientEnd = Color(0xFF44445A);
  static const _activeColor = Color(0xFF2CC339);
  // Keep existing detail colors...

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cornerR = h * 0.15;

    // Gradient background
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_bodyGradientStart, _bodyGradientEnd],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), Radius.circular(cornerR)),
      gradientPaint,
    );

    // ... existing LED + screen painting (unchanged) ...

    // Active border (stacked highlight)
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
```

- [ ] **Step 2: Update `SwitchBodyWidget` to accept and pass `isActive`**

```dart
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
      color: SwitchBodyPainter._bodyGradientEnd, // base color for shadow
      elevation: elevation,
      shadowColor: Colors.black,
      child: CustomPaint(
        painter: SwitchBodyPainter(totalPorts: totalPorts, isActive: isActive),
        child: const SizedBox.expand(),
      ),
    );
  }
}
```

- [ ] **Step 3: Add widget test for SwitchBodyWidget with isActive**

Create `test/painters/switch_body_painter_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/painters/switch_body_painter.dart';

void main() {
  group('SwitchBodyWidget', () {
    testWidgets('renders without error with isActive false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 80,
              child: SwitchBodyWidget(totalPorts: 24),
            ),
          ),
        ),
      );
      expect(find.byType(SwitchBodyWidget), findsOneWidget);
    });

    testWidgets('renders without error with isActive true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 80,
              child: SwitchBodyWidget(totalPorts: 24, isActive: true),
            ),
          ),
        ),
      );
      expect(find.byType(SwitchBodyWidget), findsOneWidget);
    });
  });

  group('SwitchBodyPainter', () {
    test('shouldRepaint returns true when isActive changes', () {
      final a = SwitchBodyPainter(totalPorts: 24, isActive: false);
      final b = SwitchBodyPainter(totalPorts: 24, isActive: true);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns false when params are same', () {
      final a = SwitchBodyPainter(totalPorts: 24);
      final b = SwitchBodyPainter(totalPorts: 24);
      expect(a.shouldRepaint(b), isFalse);
    });
  });
}
```

- [ ] **Step 4: Run tests**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/painters/switch_body_painter_test.dart`
Expected: All PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/painters/switch_body_painter.dart test/painters/switch_body_painter_test.dart
git commit -m "feat: add gradient background and active border to SwitchBodyPainter"
```

---

### Task 5: Port Widget

**Files:**
- Create: `lib/src/widgets/port_widget.dart`
- Create: `test/widgets/port_widget_test.dart`

Wraps `PortPainter` with hover float animation (300ms easeInOut), tap handler, and port number label overlay.

- [ ] **Step 1: Write failing widget tests**

Create `test/widgets/port_widget_test.dart`:

```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/models/port_data.dart';
import 'package:flutter_switch_device/src/models/port_status.dart';
import 'package:flutter_switch_device/src/widgets/port_widget.dart';

void main() {
  PortData makePort({
    int portNumber = 1,
    PortStatus status = PortStatus.up,
    bool showLabel = true,
  }) {
    return PortData(
      portNumber: portNumber,
      position: const Offset(100, 100),
      width: 20,
      height: 15,
      status: status,
      showLabel: showLabel,
    );
  }

  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: Stack(children: [child])));
  }

  group('PortWidget', () {
    testWidgets('renders port number label', (tester) async {
      await tester.pumpWidget(wrapInApp(
        PortWidget(data: makePort(portNumber: 7)),
      ));
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('hides label when showLabel is false', (tester) async {
      await tester.pumpWidget(wrapInApp(
        PortWidget(data: makePort(portNumber: 7, showLabel: false)),
      ));
      expect(find.text('7'), findsNothing);
    });

    testWidgets('fires onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(wrapInApp(
        PortWidget(
          data: makePort(),
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(PortWidget));
      expect(tapped, isTrue);
    });

    testWidgets('fires onHover callback on mouse enter', (tester) async {
      bool hovered = false;
      await tester.pumpWidget(wrapInApp(
        PortWidget(
          data: makePort(),
          onHover: () => hovered = true,
        ),
      ));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(PortWidget)));
      await tester.pump();
      expect(hovered, isTrue);
    });

    testWidgets('fires onHoverExit callback on mouse exit', (tester) async {
      bool exited = false;
      await tester.pumpWidget(wrapInApp(
        PortWidget(
          data: makePort(),
          onHoverExit: () => exited = true,
        ),
      ));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(PortWidget)));
      await tester.pump();
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(exited, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/widgets/port_widget_test.dart`
Expected: FAIL — `port_widget.dart` does not exist.

- [ ] **Step 3: Implement `PortWidget`**

Create `lib/src/widgets/port_widget.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/port_data.dart';
import '../painters/port_painter.dart';

/// Renders a single port with hover float animation and tap handling.
class PortWidget extends StatefulWidget {
  const PortWidget({
    super.key,
    required this.data,
    this.onHover,
    this.onHoverExit,
    this.onTap,
    this.isConfig = false,
  });

  final PortData data;
  final VoidCallback? onHover;
  final VoidCallback? onHoverExit;
  final VoidCallback? onTap;
  final bool isConfig;

  @override
  State<PortWidget> createState() => _PortWidgetState();
}

class _PortWidgetState extends State<PortWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _floatOffset = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final color = PortPainter.colorForStatus(
      d.status,
      isConfig: widget.isConfig,
      isInvalid: d.isInvalid,
    );

    return Positioned(
      left: d.position.dx,
      top: d.position.dy,
      child: MouseRegion(
        onEnter: (_) {
          _controller.forward();
          widget.onHover?.call();
        },
        onExit: (_) {
          _controller.reverse();
          widget.onHoverExit?.call();
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _floatOffset,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatOffset.value),
              child: child,
            ),
            child: Opacity(
              opacity: d.opacity * (d.isInvalid ? 0.4 : 1.0),
              child: SizedBox(
                width: d.width,
                height: d.height,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: PortPainter(color: color),
                      child: const SizedBox.expand(),
                    ),
                    if (d.showLabel)
                      Center(
                        child: Text(
                          d.label ?? '${d.portNumber}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: (d.width * 0.38).clamp(6, 12),
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/widgets/port_widget_test.dart`
Expected: All PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/port_widget.dart test/widgets/port_widget_test.dart
git commit -m "feat: add PortWidget with hover animation and tap handling"
```

---

### Task 6: SwitchDeviceView (Main Widget)

**Files:**
- Create: `lib/src/widgets/switch_device_view.dart`
- Create: `test/widgets/switch_device_view_test.dart`

Main public widget. Composes body + ports in a Stack. Manages hover/tap state, stacked toggle logic, adaptive tier selection, and exposes `getPortPositions()` static method.

- [ ] **Step 1: Write failing widget tests**

Create `test/widgets/switch_device_view_test.dart`:

```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/models/port_status.dart';
import 'package:flutter_switch_device/src/presets/switch_presets.dart';
import 'package:flutter_switch_device/src/widgets/switch_device_view.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('SwitchDeviceView', () {
    testWidgets('renders without error for Switch24P', (tester) async {
      await tester.pumpWidget(wrapInApp(
        SwitchDeviceView(
          size: const Size(800, 400),
          format: const Switch24P(),
        ),
      ));
      expect(find.byType(SwitchDeviceView), findsOneWidget);
    });

    testWidgets('renders without error for Switch6P', (tester) async {
      await tester.pumpWidget(wrapInApp(
        SwitchDeviceView(
          size: const Size(800, 400),
          format: const Switch6P(),
        ),
      ));
      expect(find.byType(SwitchDeviceView), findsOneWidget);
    });

    testWidgets('renders without error for stacked Switch48P', (tester) async {
      await tester.pumpWidget(wrapInApp(
        SwitchDeviceView(
          size: const Size(1500, 800),
          format: const Switch48PStacked(),
          stackedPart: 1,
        ),
      ));
      expect(find.byType(SwitchDeviceView), findsOneWidget);
    });

    testWidgets('fires onPortTap callback', (tester) async {
      int? tappedPort;
      await tester.pumpWidget(wrapInApp(
        SwitchDeviceView(
          size: const Size(800, 400),
          format: const Switch6P(),
          onPortTap: (port) => tappedPort = port,
        ),
      ));
      // Find port label "1" and tap it
      await tester.tap(find.text('1'));
      expect(tappedPort, 1);
    });

    testWidgets('fires onStackedPartChanged when body tapped', (tester) async {
      int? newPart;
      await tester.pumpWidget(wrapInApp(
        SwitchDeviceView(
          size: const Size(1500, 800),
          format: const Switch48PStacked(),
          stackedPart: 1,
          onStackedPartChanged: (part) => newPart = part,
        ),
      ));
      // Find GestureDetectors wrapping bodies — there should be 2 for stacked.
      // Tap the second body (lower) to toggle to part 2.
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);
      // The lower body GestureDetector — tap a point in the lower half.
      await tester.tapAt(const Offset(750, 600));
      expect(newPart, 2);
    });
  });

  group('SwitchDeviceView.getPortPositions', () {
    test('returns correct port count', () {
      final positions = SwitchDeviceView.getPortPositions(
        const Switch24P(),
        const Size(800, 400),
      );
      expect(positions.length, 24);
    });

    test('returns correct port count for stacked', () {
      final positions = SwitchDeviceView.getPortPositions(
        const Switch48PStacked(),
        const Size(1500, 800),
      );
      expect(positions.length, 48);
    });

    test('is deterministic — same inputs produce same outputs', () {
      const format = Switch24P();
      const size = Size(800, 400);
      final a = SwitchDeviceView.getPortPositions(format, size);
      final b = SwitchDeviceView.getPortPositions(format, size);
      for (final key in a.keys) {
        expect(a[key], b[key]);
      }
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/widgets/switch_device_view_test.dart`
Expected: FAIL — `switch_device_view.dart` does not exist.

- [ ] **Step 3: Implement `SwitchDeviceView`**

Create `lib/src/widgets/switch_device_view.dart`:

```dart
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

  /// Viewport size for the switch device.
  final Size size;

  /// Switch format preset defining port layout.
  final SwitchFormat format;

  /// Port number → status map.
  final Map<int, PortStatus> portStatuses;

  /// When true, all ports render as grey (config/setup mode).
  final bool isConfig;

  /// Called when a port is hovered with the port number.
  final ValueChanged<int>? onPortHover;

  /// Called when the pointer exits a port.
  final VoidCallback? onPortHoverExit;

  /// Called when a port is tapped with the port number.
  final ValueChanged<int>? onPortTap;

  /// Called when the switch body is hovered.
  final VoidCallback? onSwitchHover;

  /// Called when the pointer exits the switch body.
  final VoidCallback? onSwitchHoverExit;

  /// Which stacked unit is active (1 = upper, 2 = lower, 0 = none).
  final int stackedPart;

  /// Called when the user taps a stacked body to toggle active unit.
  final ValueChanged<int>? onStackedPartChanged;

  /// Returns port center positions for the given format and viewport size.
  ///
  /// Synchronous and deterministic — no layout timing dependency.
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

    // Determine active state for stacked switches.
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
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test test/widgets/switch_device_view_test.dart`
Expected: All PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/src/widgets/switch_device_view.dart test/widgets/switch_device_view_test.dart
git commit -m "feat: add SwitchDeviceView main widget with stacked support"
```

---

### Task 7: Barrel Export and Test Cleanup

**Files:**
- Modify: `lib/flutter_switch_device.dart`
- Modify: `test/flutter_switch_device_test.dart`

Replace the placeholder `Calculator` class with proper barrel exports.

- [ ] **Step 1: Replace barrel export**

Rewrite `lib/flutter_switch_device.dart`:

```dart
/// A Flutter widget that renders network switch devices with ports,
/// fully programmatic — no SVG assets required.
library flutter_switch_device;

export 'src/models/port_status.dart';
export 'src/models/switch_format.dart';
export 'src/presets/switch_presets.dart';
export 'src/widgets/switch_device_view.dart';
```

- [ ] **Step 2: Replace placeholder test**

Rewrite `test/flutter_switch_device_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/flutter_switch_device.dart';

void main() {
  test('public API exports are accessible', () {
    // Verify key types are importable from the barrel.
    expect(PortStatus.up, isNotNull);
    expect(const Switch24P(), isA<SwitchFormat>());
    expect(switchFormatForPortCount(6), isA<SwitchFormat>());
  });
}
```

- [ ] **Step 3: Run full test suite**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test`
Expected: All tests PASS across all test files.

- [ ] **Step 4: Commit**

```bash
git add lib/flutter_switch_device.dart test/flutter_switch_device_test.dart
git commit -m "chore: replace placeholder with barrel exports and smoke test"
```

---

### Task 8: Example App

**Files:**
- Modify: `example/lib/main.dart`

Interactive demo with dropdown scenario selector, status randomizer, config toggle, stacked part toggle, and event log.

- [ ] **Step 1: Implement the example app**

Rewrite `example/lib/main.dart`:

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_switch_device/flutter_switch_device.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_switch_device demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  static const _scenarios = <String, SwitchFormat>{
    '6P': Switch6P(),
    '12P': Switch12P(),
    '24P': Switch24P(),
    '28P': Switch28P(),
    '48P Stacked': Switch48PStacked(),
    '30P Stacked': Switch30PStacked(),
  };

  String _selectedScenario = '24P';
  Map<int, PortStatus> _portStatuses = {};
  bool _isConfig = false;
  int _stackedPart = 1;
  final List<String> _eventLog = [];

  SwitchFormat get _format => _scenarios[_selectedScenario]!;

  void _randomizeStatuses() {
    final rng = Random();
    final statuses = <int, PortStatus>{};
    final total = _format.totalPortsNum;
    for (int i = 1; i <= total; i++) {
      statuses[i] = PortStatus.values[rng.nextInt(PortStatus.values.length)];
    }
    setState(() => _portStatuses = statuses);
  }

  void _log(String event) {
    setState(() {
      _eventLog.insert(0, event);
      if (_eventLog.length > 20) _eventLog.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isStacked = _format.isStacked;

    return Scaffold(
      appBar: AppBar(title: const Text('flutter_switch_device demo')),
      body: Column(
        children: [
          // Controls
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<String>(
                  value: _selectedScenario,
                  items: _scenarios.keys
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedScenario = v!;
                    _portStatuses = {};
                    _stackedPart = _format.isStacked ? 1 : 0;
                  }),
                ),
                ElevatedButton(
                  onPressed: _randomizeStatuses,
                  child: const Text('Randomize statuses'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Config mode'),
                    Switch(
                      value: _isConfig,
                      onChanged: (v) => setState(() => _isConfig = v),
                    ),
                  ],
                ),
                if (isStacked)
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('Upper')),
                      ButtonSegment(value: 2, label: Text('Lower')),
                    ],
                    selected: {_stackedPart},
                    onSelectionChanged: (s) =>
                        setState(() => _stackedPart = s.first),
                  ),
              ],
            ),
          ),

          // Switch view
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewSize = Size(
                    constraints.maxWidth.clamp(400, 1500),
                    constraints.maxHeight.clamp(200, 800),
                  );
                  return SwitchDeviceView(
                    size: viewSize,
                    format: _format,
                    portStatuses: _portStatuses,
                    isConfig: _isConfig,
                    stackedPart: _stackedPart,
                    onStackedPartChanged: (part) {
                      setState(() => _stackedPart = part);
                      _log('Stacked part changed: $part');
                    },
                    onPortHover: (port) => _log('Hover: port $port'),
                    onPortHoverExit: () {},
                    onPortTap: (port) => _log('Tap: port $port'),
                    onSwitchHover: () {},
                    onSwitchHoverExit: () {},
                  );
                },
              ),
            ),
          ),

          // Event log
          Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Event Log',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView(
                    children: _eventLog
                        .map((e) => Text(e,
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace')))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run the example app to verify**

Run: `cd /Users/hualinliang/Project/flutter_switch_device/example && flutter run -d macos`
Manual verification: dropdown works, switch renders, ports show labels, hover/tap logs events.

- [ ] **Step 3: Run full test suite one final time**

Run: `cd /Users/hualinliang/Project/flutter_switch_device && flutter test`
Expected: All PASS.

- [ ] **Step 4: Commit**

```bash
git add example/lib/main.dart
git commit -m "feat: add interactive example app with scenario selector and event log"
```

---

## Execution Notes

- **Task 1 must complete first** (presets update) — Task 2's tests depend on the updated single-row Y values.
- After Task 1, Tasks 2, 3, 4 are independent and can be parallelized (layout engine, port painter, body painter enhancement).
- Task 5 (PortWidget) depends on Task 3 (PortPainter).
- Task 6 (SwitchDeviceView) depends on Tasks 2, 4, 5.
- Task 7 (barrel export) depends on Task 6.
- Task 8 (example app) depends on Task 7.
