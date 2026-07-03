import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skybnb/application/providers/auth_provider.dart';
import 'package:skybnb/core/constants/app_colors.dart';
import 'package:skybnb/core/constants/app_strings.dart';
import 'package:skybnb/presentation/screens/login/widgets/login_button.dart';
import 'package:skybnb/presentation/screens/login/widgets/login_input_field.dart';
import 'package:skybnb/presentation/screens/login/widgets/login_logo.dart';
import 'package:skybnb/presentation/screens/main_navigation.dart';

/// StatefulWidget: maneja controllers de texto, visibilidad de contraseña
/// y estado de carga del formulario.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.loginFieldsRequired),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(username, password);

    if (!mounted) return;
    if (success) {
      if (_rememberMe) {
        await auth.saveUserSession(auth.currentUser!.id);
      } else {
        await auth.clearUserSession();
      }

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MainNavigation(userId: auth.currentUser!.id),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? AppStrings.loginError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Text(
                  AppStrings.loginTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                const LoginLogo(),
                const SizedBox(height: 32),
                LoginInputField(
                  controller: _usernameController,
                  hint: AppStrings.userHint,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                LoginInputField(
                  controller: _passwordController,
                  hint: AppStrings.passwordHint,
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primaryDark,
                      onChanged: (v) =>
                          setState(() => _rememberMe = v ?? false),
                    ),
                    const Text(AppStrings.rememberMe),
                  ],
                ),
                const SizedBox(height: 24),
                LoginButton(
                  label: AppStrings.loginButton,
                  isLoading: isLoading,
                  onTap: _handleLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
