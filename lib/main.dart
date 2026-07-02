import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/service_locator.dart';
import 'presentation/screens/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handler global de errores de Flutter
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
  };

  await dotenv.load();
  await initializeDateFormatting('es', null);
  await ServiceLocator.loadSavedToken();

  // Captura errores no atrapados en la zona global
  await runZonedGuarded(
    () => runApp(const SkybnbApp()),
    (error, stack) {
      debugPrint('[UncaughtError] $error');
      debugPrint('$stack');
    },
  );
}

class SkybnbApp extends StatelessWidget {
  const SkybnbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ServiceLocator.createAuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.createPropertyProvider()),
        ChangeNotifierProvider(create: (_) => ServiceLocator.createCalendarProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Skybnb',
        theme: ThemeData(
          primaryColor: const Color(0xFFE91E63),
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE91E63),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}