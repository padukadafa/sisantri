import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_wrapper.dart';
import 'shared/services/notification_service.dart';
import 'shared/widgets/splash_screen.dart';
import 'firebase_options.dart';

/// Background message handler untuk Firebase Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

/// Flutter Local Notifications plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize local notifications
  await NotificationService.initialize();

  runApp(const ProviderScope(child: SiSantriApp()));
}

class SiSantriApp extends StatelessWidget {
  const SiSantriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SiSantri',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Restart app
                        main();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Show main app after successful initialization
          return const AuthWrapper();
        },
      ),
    );
  }
}
