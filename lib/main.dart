import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_wrapper_clean.dart';
import 'shared/services/notification_service.dart';
import 'firebase_options.dart';

/// Background message handler untuk Firebase Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();
  // Handling a background message
}

/// Flutter Local Notifications plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Messaging background handler dengan error handling
    try {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    } catch (e) {
      // Firebase Messaging error (akan diabaikan)
    }

    // Initialize local notifications
    try {
      await NotificationService.initialize();
    } catch (e) {
      // Local notifications error (akan diabaikan)
    }
  } catch (e) {
    // Firebase initialization error
    // Lanjutkan saja meskipun ada error Firebase
  }

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
      // Firebase sudah diinisialisasi di main(), langsung tampilkan AuthWrapper
      home: const AuthWrapper(),
    );
  }
}
