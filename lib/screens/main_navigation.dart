import 'package:flutter/material.dart';
import 'profile/profile_screen.dart';
import 'properties/properties_screen.dart';
import 'calendar/calendar_screen.dart';

/// ===============================
/// MAIN NAVIGATION
/// ===============================
/// Container principal con Bottom Navigation Bar
/// Maneja las 3 secciones: Perfil | Propiedades | Calendario

class MainNavigation extends StatefulWidget {
  final String ownerId;

  const MainNavigation({
    super.key,
    required this.ownerId,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Inicia en Propiedades

  // Colores Skybnb
  static const Color skybnbPink = Color(0xFFE91E63);
  static const Color skybnbPinkLight = Color(0xFFF8BBD0);

  @override
  Widget build(BuildContext context) {
    // Las 3 pantallas
    final screens = [
      ProfileScreen(ownerId: widget.ownerId),
      PropertiesScreen(ownerId: widget.ownerId),
      CalendarScreen(ownerId: widget.ownerId),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: skybnbPink,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Propiedades',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendario',
            ),
          ],
        ),
      ),
    );
  }
}