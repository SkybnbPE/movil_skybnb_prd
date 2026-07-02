import 'package:flutter/material.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/core/constants/app_strings.dart';
import 'package:skybnb/presentation/screens/profile/profile_screen.dart';
import 'package:skybnb/presentation/screens/properties/properties_screen.dart';
import 'package:skybnb/presentation/screens/calendar/calendar_screen.dart';

/// StatefulWidget: gestiona el índice de la tab activa.
/// Sus hijos (ProfileScreen, PropertiesScreen, CalendarScreen) manejan
/// su propio estado de datos a través de sus Providers.
class MainNavigation extends StatefulWidget {
  final String userId;

  const MainNavigation({super.key, required this.userId});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Inicia en Propiedades

  @override
  Widget build(BuildContext context) {
    final screens = [
      ProfileScreen(userId: widget.userId),
      PropertiesScreen(userId: widget.userId),
      CalendarScreen(userId: widget.userId),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: AppStrings.navProfile,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: AppStrings.navProperties,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: AppStrings.navCalendar,
            ),
          ],
        ),
      ),
    );
  }
}
