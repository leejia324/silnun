import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('앱이 정상적으로 렌더링된다', (WidgetTester tester) async {
    await tester.pumpWidget(const SilnunApp());
    expect(find.byType(SilnunApp), findsOneWidget);
  });
}
