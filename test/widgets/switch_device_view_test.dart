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
      // Switch14P has 2-row layout so port 1 (odd row) and port 2 (even row)
      // have distinct y-positions and do not overlap.
      await tester.pumpWidget(wrapInApp(
        SwitchDeviceView(
          size: const Size(800, 400),
          format: const Switch14P(),
          onPortTap: (port) => tappedPort = port,
        ),
      ));
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
      // Lower body rect center is at approximately (750, 450) in the layout
      // coordinate space; this falls within the default 800x600 test viewport.
      await tester.tapAt(const Offset(750, 450));
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
