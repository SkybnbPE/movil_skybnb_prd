import 'package:flutter_test/flutter_test.dart';
import 'package:skybnb/core/constants/app_strings.dart';
import 'package:skybnb/main.dart';

void main() {
  testWidgets('App loads LoginScreen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const SkybnbApp());
    expect(find.text(AppStrings.loginButton), findsOneWidget);
    expect(find.text(AppStrings.loginTitle), findsOneWidget);
  });
}
