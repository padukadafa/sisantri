import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'auth_service.dart';

/// Service untuk mengelola notifikasi lokal dan push notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Inisialisasi notification service
  static Future<void> initialize() async {
    // Request permission untuk notifications
    await _requestPermissions();

    // Inisialisasi local notifications
    await _initializeLocalNotifications();

    // Inisialisasi Firebase messaging
    await _initializeFirebaseMessaging();

    // Setup foreground message handler
    _setupForegroundMessageHandler();
  }

  /// Request permissions untuk notifications
  static Future<void> _requestPermissions() async {
    // Request permission untuk notifications
    await Permission.notification.request();

    // Request permission untuk Firebase messaging
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  /// Inisialisasi local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  /// Handler untuk ketika notifikasi di-tap
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
  }

  /// Inisialisasi Firebase messaging
  static Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    if (token != null) {
      // Update token di Firestore melalui AuthService
      try {
        await _updateTokenInFirestore(token);
      } catch (e) {
        print('Error updating token in Firestore: $e');
      }
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      _updateTokenInFirestore(newToken);
    });
  }

  /// Helper method untuk update token di Firestore
  static Future<void> _updateTokenInFirestore(String token) async {
    try {
      await AuthService.updateDeviceToken(token);
    } catch (e) {
      print('Error updating token in Firestore: $e');
    }
  }

  /// Setup handler untuk foreground messages
  static void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });
  }

  /// Menampilkan notifikasi lokal
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'sisantri_channel',
          'SiSantri Notifications',
          channelDescription: 'Notifikasi untuk aplikasi SiSantri',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  /// Menampilkan notifikasi untuk pengingat kegiatan
  static Future<void> showKegiatanReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'kegiatan_reminder',
          'Pengingat Kegiatan',
          channelDescription: 'Pengingat untuk kegiatan pondok pesantren',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // For now, just show immediate notification
    // TODO: Implement proper scheduling with timezone package
    await _flutterLocalNotificationsPlugin.show(
      1,
      title,
      body,
      platformChannelSpecifics,
      payload: 'kegiatan_reminder',
    );
  }

  /// Get FCM token untuk user saat ini
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe ke topic tertentu
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe dari topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Send notification to specific device tokens (untuk admin)
  /// Note: Ini memerlukan server-side implementation atau Firebase Functions
  /// Karena client tidak bisa langsung send ke token lain
  static Future<void> sendNotificationToTokens({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Implementasi ini memerlukan Firebase Functions atau backend server
    // Untuk sekarang, kita bisa log saja sebagai placeholder
    print('Sending notification to ${tokens.length} devices:');
    print('Title: $title');
    print('Body: $body');
    print('Tokens: $tokens');
    print('Data: $data');

    // TODO: Implementasi dengan Firebase Functions atau backend API
    // Example call to backend:
    // await http.post(
    //   Uri.parse('https://your-backend.com/send-notification'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'tokens': tokens,
    //     'title': title,
    //     'body': body,
    //     'data': data,
    //   }),
    // );
  }

  /// Send notification ke semua santri
  static Future<void> sendNotificationToAllSantri({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final santriTokens = await AuthService.getDeviceTokensByRole('santri');
      if (santriTokens.isNotEmpty) {
        await sendNotificationToTokens(
          tokens: santriTokens,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      print('Error sending notification to all santri: $e');
    }
  }

  /// Send notification ke semua dewan guru
  static Future<void> sendNotificationToAllDewaGuru({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final guruTokens = await AuthService.getDeviceTokensByRole('dewan_guru');
      if (guruTokens.isNotEmpty) {
        await sendNotificationToTokens(
          tokens: guruTokens,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      print('Error sending notification to all dewa guru: $e');
    }
  }
}
