import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ✅ Importar para inicializar locales
import 'screens/login/login_screen.dart';

void main() async {
  // ✅ Inicializar locales para español
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  
  runApp(const SkybnbApp());
}

class SkybnbApp extends StatelessWidget {
  const SkybnbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}