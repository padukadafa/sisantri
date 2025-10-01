import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/bloc/auth_provider.dart';
import '../../../core/error/auth_error_mapper.dart';

/// Demo page untuk testing berbagai skenario error authentication
/// Hanya untuk development - jangan include di production build
class AuthErrorDemoPage extends ConsumerStatefulWidget {
  const AuthErrorDemoPage({super.key});

  @override
  ConsumerState<AuthErrorDemoPage> createState() => _AuthErrorDemoPageState();
}

class _AuthErrorDemoPageState extends ConsumerState<AuthErrorDemoPage> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: const Text('Demo Error Authentication'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Demo Pesan Error Authentication',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Divider untuk skenario login
            const Divider(),
            const Text(
              'Skenario Login Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Test wrong password
            ElevatedButton(
              onPressed: () => _testLoginError('test@example.com', 'wrongpass'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Test: Password Salah',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),

            // Test user not found
            ElevatedButton(
              onPressed: () =>
                  _testLoginError('nonexistent@example.com', 'password123'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Test: User Tidak Ditemukan',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),

            // Test invalid email
            ElevatedButton(
              onPressed: () => _testLoginError('invalid-email', 'password123'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Test: Email Tidak Valid',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            // Divider untuk testing pesan error
            const Divider(),
            const Text(
              'Test Pesan Error Manual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Grid untuk berbagai error codes
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _errorButton('wrong-password'),
                _errorButton('user-not-found'),
                _errorButton('invalid-email'),
                _errorButton('user-disabled'),
                _errorButton('too-many-requests'),
                _errorButton('network-request-failed'),
                _errorButton('weak-password'),
                _errorButton('email-already-in-use'),
                _errorButton('invalid-credential'),
                _errorButton('timeout'),
                _errorButton('account-not-verified'),
                _errorButton('maintenance-mode'),
              ],
            ),

            const SizedBox(height: 24),

            // Divider untuk testing validasi
            const Divider(),
            const Text(
              'Test Validasi Form',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => _testValidation('', 'Email kosong'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                'Test: Email Kosong',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () =>
                  _testValidation('invalid-email-format', 'Email format salah'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                'Test: Format Email Salah',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () =>
                  _testValidation('12345', 'Password terlalu pendek'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                'Test: Password Pendek',
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 32),

            // Back button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Kembali',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorButton(String errorCode) {
    return ElevatedButton(
      onPressed: () => _showErrorMessage(errorCode),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      child: Text(
        errorCode,
        style: const TextStyle(fontSize: 10, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _testLoginError(String email, String password) {
    ref
        .read(authProvider.notifier)
        .loginWithEmailAndPassword(email: email, password: password);
  }

  void _showErrorMessage(String errorCode) {
    final message = AuthErrorMapper.mapFirebaseAuthError(errorCode);
    final severity = AuthErrorMapper.getErrorSeverity(errorCode);

    Color backgroundColor;
    IconData icon;

    switch (severity) {
      case ErrorSeverity.info:
        backgroundColor = Colors.blue;
        icon = Icons.info;
        break;
      case ErrorSeverity.warning:
        backgroundColor = Colors.orange;
        icon = Icons.warning;
        break;
      case ErrorSeverity.error:
        backgroundColor = Colors.red;
        icon = Icons.error;
        break;
      case ErrorSeverity.critical:
        backgroundColor = Colors.red[800]!;
        icon = Icons.dangerous;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error Code: $errorCode',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _testValidation(String input, String type) {
    String? result;

    if (type == 'Email kosong' || type == 'Email format salah') {
      result = AuthErrorMapper.validateEmailFormat(input);
    } else if (type == 'Password terlalu pendek') {
      result = AuthErrorMapper.validatePasswordFormat(input);
    }

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(result)),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              SizedBox(width: 8),
              Text('Validasi berhasil!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
