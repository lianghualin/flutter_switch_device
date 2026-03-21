import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Example app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('flutter_switch_device demo'), findsWidgets);
  });
}
