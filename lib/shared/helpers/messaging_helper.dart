import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../models/user_model.dart';

/// Helper class untuk mengelola messaging dan notifications
class MessagingHelper {
  /// Initialize messaging setelah login berhasil
  static Future<void> initializeAfterLogin() async {
    try {
      // Setup NotificationService
      await NotificationService.initialize();

      // Subscribe ke topic umum berdasarkan role
      final currentUser = await AuthService.getUserData(
        AuthService.currentUserId!,
      );
      if (currentUser != null) {
        await _subscribeToRoleBasedTopics(currentUser);
      }
    } catch (e) {
      // Error initializing messaging after login
    }
  }

  /// Subscribe ke topics berdasarkan role user
  static Future<void> _subscribeToRoleBasedTopics(UserModel user) async {
    try {
      // Subscribe ke topic umum
      await NotificationService.subscribeToTopic('all_users');

      // Subscribe berdasarkan role
      switch (user.role) {
        case 'santri':
          await NotificationService.subscribeToTopic('santri');

          // Subscribe berdasarkan kampus jika ada
          if (user.kampus != null && user.kampus!.isNotEmpty) {
            final kampusTopic =
                'kampus_${user.kampus!.toLowerCase().replaceAll(' ', '_')}';
            await NotificationService.subscribeToTopic(kampusTopic);
          }

          // Subscribe berdasarkan tempat kos jika ada
          if (user.tempatKos != null && user.tempatKos!.isNotEmpty) {
            final kosTopic =
                'kos_${user.tempatKos!.toLowerCase().replaceAll(' ', '_')}';
            await NotificationService.subscribeToTopic(kosTopic);
          }
          break;

        case 'dewan_guru':
          await NotificationService.subscribeToTopic('dewan_guru');
          await NotificationService.subscribeToTopic('staff');
          break;

        case 'admin':
          await NotificationService.subscribeToTopic('admin');
          await NotificationService.subscribeToTopic('staff');
          await NotificationService.subscribeToTopic('dewan_guru');
          await NotificationService.subscribeToTopic('santri');
          break;
      }

      // Successfully subscribed to topics
    } catch (e) {
      // Error subscribing to topics
    }
  }

  /// Unsubscribe dari semua topics saat logout dengan timeout dan error handling
  static Future<void> unsubscribeFromAllTopics() async {
    try {
      // Daftar semua topics yang mungkin
      final topics = ['all_users', 'santri', 'dewan_guru', 'admin', 'staff'];

      // Unsubscribe dari semua topics secara paralel dengan timeout per topic
      final unsubscribeFutures = topics.map((topic) async {
        try {
          // Timeout 2 detik per topic
          await Future.any([
            NotificationService.unsubscribeFromTopic(topic),
            Future.delayed(const Duration(seconds: 2)),
          ]);
        } catch (e) {
          // Ignore error per topic, lanjutkan ke topic berikutnya
        }
      });

      // Tunggu semua unsubscribe selesai (maksimal 10 detik total)
      await Future.wait(
        unsubscribeFutures,
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      // Ignore semua error dalam messaging cleanup
    }
  }

  /// Send pengumuman ke semua santri
  static Future<void> sendPengumumanToSantri({
    required String title,
    required String message,
  }) async {
    try {
      await NotificationService.sendNotificationToAllSantri(
        title: title,
        body: message,
        data: {
          'type': 'pengumuman',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Error sending pengumuman to santri
      rethrow;
    }
  }

  /// Send pengumuman ke semua dewan guru
  static Future<void> sendPengumumanToDevanGuru({
    required String title,
    required String message,
  }) async {
    try {
      await NotificationService.sendNotificationToAllDewaGuru(
        title: title,
        body: message,
        data: {
          'type': 'pengumuman',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Error sending pengumuman to dewan guru
      rethrow;
    }
  }

  /// Send notifikasi presensi ke dewan guru
  static Future<void> sendPresensiNotificationToGuru({
    required String santriName,
    required String activity,
    required String status,
  }) async {
    try {
      await NotificationService.sendNotificationToAllDewaGuru(
        title: 'Update Presensi',
        body: '$santriName - $activity: $status',
        data: {
          'type': 'presensi',
          'santri_name': santriName,
          'activity': activity,
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Error sending presensi notification to guru
      rethrow;
    }
  }

  /// Send reminder kegiatan ke santri
  static Future<void> sendKegiatanReminderToSantri({
    required String kegiatanName,
    required DateTime waktu,
    required String tempat,
  }) async {
    try {
      await NotificationService.sendNotificationToAllSantri(
        title: 'Pengingat Kegiatan',
        body: '$kegiatanName akan dimulai dalam 15 menit di $tempat',
        data: {
          'type': 'kegiatan_reminder',
          'kegiatan_name': kegiatanName,
          'waktu': waktu.toIso8601String(),
          'tempat': tempat,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Error sending kegiatan reminder
      rethrow;
    }
  }

  /// Send emergency notification ke semua user
  static Future<void> sendEmergencyNotification({
    required String title,
    required String message,
  }) async {
    try {
      // Kirim ke semua role
      await Future.wait([
        NotificationService.sendNotificationToAllSantri(
          title: '🚨 $title',
          body: message,
          data: {
            'type': 'emergency',
            'priority': 'high',
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
        NotificationService.sendNotificationToAllDewaGuru(
          title: '🚨 $title',
          body: message,
          data: {
            'type': 'emergency',
            'priority': 'high',
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      ]);
    } catch (e) {
      // Error sending emergency notification
      rethrow;
    }
  }

  /// Get statistics device tokens yang terdaftar
  static Future<Map<String, int>> getDeviceTokenStatistics() async {
    try {
      final [santriTokens, guruTokens] = await Future.wait([
        AuthService.getDeviceTokensByRole('santri'),
        AuthService.getDeviceTokensByRole('dewan_guru'),
      ]);

      final adminTokens = await AuthService.getDeviceTokensByRole('admin');

      return {
        'santri': santriTokens.length,
        'dewan_guru': guruTokens.length,
        'admin': adminTokens.length,
        'total': santriTokens.length + guruTokens.length + adminTokens.length,
      };
    } catch (e) {
      // Error getting device token statistics
      return {'santri': 0, 'dewan_guru': 0, 'admin': 0, 'total': 0};
    }
  }
}
