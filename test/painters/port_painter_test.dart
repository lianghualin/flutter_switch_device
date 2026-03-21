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
