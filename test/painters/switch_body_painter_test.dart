import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/models/switch_device_theme.dart';
import 'package:flutter_switch_device/src/painters/switch_body_painter.dart';

void main() {
  const dark = SwitchDeviceTheme.dark();
  const light = SwitchDeviceTheme.light();

  group('SwitchBodyWidget', () {
    testWidgets('renders with dark theme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 80,
              child: SwitchBodyWidget(totalPorts: 24, theme: dark),
            ),
          ),
        ),
      );
      expect(find.byType(SwitchBodyWidget), findsOneWidget);
    });

    testWidgets('renders with light theme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 80,
              child: SwitchBodyWidget(totalPorts: 24, theme: light),
            ),
          ),
        ),
      );
      expect(find.byType(SwitchBodyWidget), findsOneWidget);
    });

    testWidgets('renders with isActive true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 80,
              child: SwitchBodyWidget(
                totalPorts: 24,
                isActive: true,
                theme: dark,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(SwitchBodyWidget), findsOneWidget);
    });
  });

  group('SwitchBodyPainter', () {
    test('shouldRepaint returns true when isActive changes', () {
      final a = SwitchBodyPainter(totalPorts: 24, isActive: false, theme: dark);
      final b = SwitchBodyPainter(totalPorts: 24, isActive: true, theme: dark);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns true when theme changes', () {
      final a = SwitchBodyPainter(totalPorts: 24, theme: dark);
      final b = SwitchBodyPainter(totalPorts: 24, theme: light);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns false when params are same', () {
      final a = SwitchBodyPainter(totalPorts: 24, theme: dark);
      final b = SwitchBodyPainter(totalPorts: 24, theme: dark);
      expect(a.shouldRepaint(b), isFalse);
    });
  });
}
