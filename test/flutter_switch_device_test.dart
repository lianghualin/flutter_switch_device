import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_switch_device/flutter_switch_device.dart';

void main() {
  test('public API exports are accessible', () {
    expect(PortStatus.up, isNotNull);
    expect(const Switch24P(), isA<SwitchFormat>());
    expect(switchFormatForPortCount(6), isA<SwitchFormat>());
  });
}
