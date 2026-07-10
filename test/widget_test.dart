import 'package:flutter_test/flutter_test.dart';

import 'package:studio3/main.dart';

void main() {
  testWidgets('Studio3App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Studio3App());
    await tester.pump();
  });
}
