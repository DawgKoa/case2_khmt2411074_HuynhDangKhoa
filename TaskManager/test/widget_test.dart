import 'package:flutter_test/flutter_test.dart';
import 'package:casestudy2/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskManagerApp(isLoggedIn: false));
    expect(find.byType(TaskManagerApp), findsOneWidget);
  });
}
