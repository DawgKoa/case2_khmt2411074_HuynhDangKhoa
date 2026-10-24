import 'package:flutter_test/flutter_test.dart';
import 'package:casestudy2/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    expect(find.byType(TaskManagerApp), findsOneWidget);
  });
}
