import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/src/models/port_status.dart';
import 'package:flutter_switch_device/src/models/switch_device_theme.dart';
import 'package:flutter_switch_device/src/painters/port_painter.dart';

void main() {
  const dark = SwitchDeviceTheme.dark();
  const light = SwitchDeviceTheme.light();

  group('SwitchDeviceTheme.portColorForStatus', () {
    test('up returns green (dark)', () {
      expect(dark.portColorForStatus(PortStatus.up), const Color(0xFF2CC339));
    });

    test('down returns grey (dark)', () {
      expect(dark.portColorForStatus(PortStatus.down), const Color(0xFF9E9E9E));
    });

    test('unknown returns dark grey (dark)', () {
      expect(dark.portColorForStatus(PortStatus.unknown), const Color(0xFF333333));
    });

    test('config mode always returns down color', () {
      expect(
        dark.portColorForStatus(PortStatus.up, isConfig: true),
        const Color(0xFF9E9E9E),
      );
    });

    test('invalid port returns unknown color', () {
      expect(
        dark.portColorForStatus(PortStatus.up, isInvalid: true),
        const Color(0xFF333333),
      );
    });

    test('light theme up returns adjusted green', () {
      expect(light.portColorForStatus(PortStatus.up), const Color(0xFF34A853));
    });

    test('light theme down returns light grey', () {
      expect(light.portColorForStatus(PortStatus.down), const Color(0xFFBDBDBD));
    });
  });

  group('SwitchDeviceTheme.labelColorFor', () {
    test('dark port gets light label', () {
      expect(dark.labelColorFor(const Color(0xFF333333)), const Color(0xFFFFFFFF));
    });

    test('light port gets dark label', () {
      expect(light.labelColorFor(const Color(0xFFE0E0E0)), const Color(0xFF444444));
    });

    test('green port gets white label', () {
      expect(light.labelColorFor(const Color(0xFF34A853)), const Color(0xFFFFFFFF));
    });
  });

  group('SwitchDeviceTheme equality', () {
    test('same named constructors are equal', () {
      expect(const SwitchDeviceTheme.dark(), const SwitchDeviceTheme.dark());
    });

    test('dark and light are not equal', () {
      expect(const SwitchDeviceTheme.dark() == const SwitchDeviceTheme.light(), isFalse);
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
