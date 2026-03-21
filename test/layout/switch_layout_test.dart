import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/layout/switch_layout.dart';
import 'package:flutter_switch_device/src/models/port_status.dart';
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
      expect(invalidPorts.length, 18);
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
        stackedPart: 1,
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
}
