import 'package:flutter/material.dart';
import 'package:skybnb/core/constants/app_colors.dart';

/// Logo de la app con fallback a ícono de casa.
/// Stateless: sin estado propio.
class LoginLogo extends StatelessWidget {
  final double height;
  const LoginLogo({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      height: height,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        width: height,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Icon(Icons.home, size: height * 0.5, color: Colors.white),
      ),
    );
  }
}
