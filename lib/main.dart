import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/service_locator.dart';
import 'presentation/screens/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const SkybnbApp());
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