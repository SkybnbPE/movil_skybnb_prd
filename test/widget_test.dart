import 'package:flutter_test/flutter_test.dart';
import 'package:skybnb/main.dart';

void main() {
  testWidgets('App loads LoginScreen initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SkybnbApp());

    // Verify that our app starts on the Login Screen
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
