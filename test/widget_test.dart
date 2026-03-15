import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ag_jobportal/main.dart';

void main() {
  testWidgets('App launches and shows LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: JobPortalApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome\nBack'), findsOneWidget);
    expect(find.text('Bypass: Candidate Dashboard'), findsOneWidget);
  });
}
