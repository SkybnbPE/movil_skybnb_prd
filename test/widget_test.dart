import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skybnb/core/service_locator.dart';
import 'package:skybnb/presentation/screens/login/login_screen.dart';

void main() {
  testWidgets('LoginScreen muestra el formulario de login', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ServiceLocator.createAuthProvider(),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Inicio de Sesión de Usuario'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Contraseña (DNI)'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
