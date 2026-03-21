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
