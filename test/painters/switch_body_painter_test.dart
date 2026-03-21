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
