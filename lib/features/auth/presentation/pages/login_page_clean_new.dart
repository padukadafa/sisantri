import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bloc/auth_provider.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form_fields.dart';
import '../widgets/login_button.dart';
import '../widgets/login_dialogs.dart';

/// Login Page dengan Clean Architecture dan komponen yang dipecah
class LoginPageClean extends ConsumerStatefulWidget {
  const LoginPageClean({super.key});

  @override
  ConsumerState<LoginPageClean> createState() => _LoginPageCleanState();
}

class _LoginPageCleanState extends ConsumerState<LoginPageClean> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen to auth state changes for better UX
    ref.listen<AuthState>(authProvider, (previous, current) {
      if (current.error != null) {
        LoginDialogs.showErrorDialog(context, current.error!);

        // Clear error after showing
        Future.delayed(const Duration(milliseconds: 100), () {
          ref.read(authProvider.notifier).clearError();
        });
      }

      // Show success feedback when login is successful
      if (previous?.isLoading == true &&
          current.isLoading == false &&
          current.error == null &&
          current.user != null) {
        LoginDialogs.showSuccessSnackBar(context);
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHeader(),

                LoginForm(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 32),

                LoginButton(
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),

                // Register Link
                TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          // Navigate to register page
                          // Navigator.push(context, ...);
                        },
                  child: const Text(
                    'Belum punya akun? Daftar di sini',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .loginWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }
}
