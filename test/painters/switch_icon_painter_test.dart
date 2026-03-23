import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/models/switch_device_theme.dart';
import 'package:flutter_switch_device/src/painters/switch_icon_painter.dart';

void main() {
  const dark = SwitchDeviceTheme.dark();
  const light = SwitchDeviceTheme.light();

  group('SwitchIconPainter', () {
    test('shouldRepaint returns true when theme changes', () {
      final a = SwitchIconPainter(theme: dark);
      final b = SwitchIconPainter(theme: light);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('shouldRepaint returns false when theme is same', () {
      final a = SwitchIconPainter(theme: dark);
      final b = SwitchIconPainter(theme: dark);
      expect(a.shouldRepaint(b), isFalse);
    });

    test('can paint without errors at 72x28 (plain size)', () {
      final painter = SwitchIconPainter(theme: dark);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      // Should not throw
      painter.paint(canvas, const Size(72, 28));
      recorder.endRecording();
    });

    test('can paint without errors at 38x16 (compact size)', () {
      final painter = SwitchIconPainter(theme: dark);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(38, 16));
      recorder.endRecording();
    });

    test('can paint with light theme', () {
      final painter = SwitchIconPainter(theme: light);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(72, 28));
      recorder.endRecording();
    });
  });
}
