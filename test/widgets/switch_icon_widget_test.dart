import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/models/switch_device_theme.dart';
import 'package:flutter_switch_device/src/painters/switch_icon_painter.dart';
import 'package:flutter_switch_device/src/widgets/switch_icon_widget.dart';

void main() {
  const dark = SwitchDeviceTheme.dark();
  const light = SwitchDeviceTheme.light();

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('SwitchIconWidget', () {
    testWidgets('renders at plain size (72px width)', (tester) async {
      await tester.pumpWidget(wrap(
        const SwitchIconWidget(size: 72, theme: dark),
      ));
      expect(find.byType(SwitchIconWidget), findsOneWidget);

      final box =
          tester.renderObject<RenderBox>(find.byType(SwitchIconWidget));
      expect(box.size.width, 72);
      expect(box.size.height, closeTo(28.8, 0.1)); // 72 / 2.5
    });

    testWidgets('renders at compact size (38px width)', (tester) async {
      await tester.pumpWidget(wrap(
        const SwitchIconWidget(size: 38, theme: dark),
      ));
      expect(find.byType(SwitchIconWidget), findsOneWidget);

      final box =
          tester.renderObject<RenderBox>(find.byType(SwitchIconWidget));
      expect(box.size.width, 38);
      expect(box.size.height, closeTo(15.2, 0.1)); // 38 / 2.5
    });

    testWidgets('renders with light theme', (tester) async {
      await tester.pumpWidget(wrap(
        const SwitchIconWidget(size: 68, theme: light),
      ));
      expect(find.byType(SwitchIconWidget), findsOneWidget);
    });

    testWidgets('renders with custom elevation', (tester) async {
      await tester.pumpWidget(wrap(
        const SwitchIconWidget(size: 72, elevation: 10, theme: dark),
      ));
      final shape = tester.widget<PhysicalShape>(find.byType(PhysicalShape));
      expect(shape.elevation, 10);
    });

    testWidgets('uses default elevation of 5', (tester) async {
      await tester.pumpWidget(wrap(
        const SwitchIconWidget(size: 72, theme: dark),
      ));
      final shape = tester.widget<PhysicalShape>(find.byType(PhysicalShape));
      expect(shape.elevation, 5);
    });

    testWidgets('auto-detects dark theme from context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SwitchIconWidget(size: 72),
          ),
        ),
      );
      expect(find.byType(SwitchIconWidget), findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(find.descendant(
        of: find.byType(SwitchIconWidget),
        matching: find.byType(CustomPaint),
      ));
      final painter = customPaint.painter! as SwitchIconPainter;
      expect(painter.theme, const SwitchDeviceTheme.dark());
    });

    testWidgets('auto-detects light theme from context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: SwitchIconWidget(size: 72),
          ),
        ),
      );
      expect(find.byType(SwitchIconWidget), findsOneWidget);

      final customPaint = tester.widget<CustomPaint>(find.descendant(
        of: find.byType(SwitchIconWidget),
        matching: find.byType(CustomPaint),
      ));
      final painter = customPaint.painter! as SwitchIconPainter;
      expect(painter.theme, const SwitchDeviceTheme.light());
    });
  });
}
