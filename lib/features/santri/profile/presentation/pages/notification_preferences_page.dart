import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/core/theme/app_theme.dart';

/// Model untuk pengaturan notifikasi
class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String doNotDisturbStart;
  final String doNotDisturbEnd;
  final bool weekendMode;

  // Kategori notifikasi
  final bool presenceNotifications;
  final bool activityNotifications;
  final bool achievementNotifications;
  final bool reminderNotifications;
  final bool importantAnnouncements;
  final bool socialNotifications;

  const NotificationSettings({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.doNotDisturbStart = '22:00',
    this.doNotDisturbEnd = '06:00',
    this.weekendMode = false,
    this.presenceNotifications = true,
    this.activityNotifications = true,
    this.achievementNotifications = true,
    this.reminderNotifications = true,
    this.importantAnnouncements = true,
    this.socialNotifications = true,
  });

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
    bool? weekendMode,
    bool? presenceNotifications,
    bool? activityNotifications,
    bool? achievementNotifications,
    bool? reminderNotifications,
    bool? importantAnnouncements,
    bool? socialNotifications,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      doNotDisturbStart: doNotDisturbStart ?? this.doNotDisturbStart,
      doNotDisturbEnd: doNotDisturbEnd ?? this.doNotDisturbEnd,
      weekendMode: weekendMode ?? this.weekendMode,
      presenceNotifications:
          presenceNotifications ?? this.presenceNotifications,
      activityNotifications:
          activityNotifications ?? this.activityNotifications,
      achievementNotifications:
          achievementNotifications ?? this.achievementNotifications,
      reminderNotifications:
          reminderNotifications ?? this.reminderNotifications,
      importantAnnouncements:
          importantAnnouncements ?? this.importantAnnouncements,
      socialNotifications: socialNotifications ?? this.socialNotifications,
    );
  }
}

/// Model untuk riwayat notifikasi
class NotificationHistory {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  const NotificationHistory({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  IconData get icon {
    switch (type) {
      case 'presence':
        return Icons.check_circle;
      case 'activity':
        return Icons.event;
      case 'achievement':
        return Icons.emoji_events;
      case 'reminder':
        return Icons.access_time;
      case 'announcement':
        return Icons.campaign;
      case 'social':
        return Icons.people;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'presence':
        return Colors.green;
      case 'activity':
        return Colors.blue;
      case 'achievement':
        return Colors.amber;
      case 'reminder':
        return Colors.orange;
      case 'announcement':
        return Colors.red;
      case 'social':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }
}

/// Providers
final notificationSettingsProvider = StateProvider<NotificationSettings>((ref) {
  return const NotificationSettings();
});

final notificationHistoryProvider = StateProvider<List<NotificationHistory>>((
  ref,
) {
  final now = DateTime.now();
  return [
    NotificationHistory(
      id: '1',
      title: 'Reminder Sholat Ashar',
      message: 'Waktunya untuk sholat Ashar berjamaah',
      type: 'reminder',
      timestamp: now.subtract(const Duration(minutes: 30)),
    ),
    NotificationHistory(
      id: '2',
      title: 'Achievement Unlocked!',
      message: 'Anda telah meraih prestasi "Perfect Week"',
      type: 'achievement',
      timestamp: now.subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    NotificationHistory(
      id: '3',
      title: 'Pengumuman Penting',
      message: 'Jadwal kajian minggu depan telah diperbarui',
      type: 'announcement',
      timestamp: now.subtract(const Duration(hours: 5)),
    ),
    NotificationHistory(
      id: '4',
      title: 'Presensi Berhasil',
      message: 'Presensi sholat subuh Anda telah tercatat',
      type: 'presence',
      timestamp: now.subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationHistory(
      id: '5',
      title: 'Kegiatan Baru',
      message: 'Gotong royong akan dimulai pukul 16:00',
      type: 'activity',
      timestamp: now.subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];
});

/// Halaman Pengaturan Notifikasi
class NotificationPreferencesPage extends ConsumerWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final history = ref.watch(notificationHistoryProvider);
    final unreadCount = history.where((n) => !n.isRead).length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifikasi'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppTheme.primaryColor,
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppTheme.primaryColor,
            tabs: [
              const Tab(icon: Icon(Icons.settings), text: 'Pengaturan'),
              Tab(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(Icons.history),
                ),
                text: 'Riwayat',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSettingsTab(context, ref, settings),
            _buildHistoryTab(context, ref, history),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Main Settings
        _buildSectionCard('Pengaturan Utama', Icons.settings, [
          _buildSwitchTile(
            'Notifikasi Push',
            'Terima notifikasi langsung di perangkat',
            settings.pushNotifications,
            (value) => _updateSettings(
              ref,
              settings.copyWith(pushNotifications: value),
            ),
          ),
          _buildSwitchTile(
            'Notifikasi Email',
            'Terima notifikasi melalui email',
            settings.emailNotifications,
            (value) => _updateSettings(
              ref,
              settings.copyWith(emailNotifications: value),
            ),
          ),
          _buildSwitchTile(
            'Notifikasi SMS',
            'Terima notifikasi melalui SMS',
            settings.smsNotifications,
            (value) => _updateSettings(
              ref,
              settings.copyWith(smsNotifications: value),
            ),
          ),
        ]),

        const SizedBox(height: 16),

        // Sound & Vibration
        _buildSectionCard('Suara & Getaran', Icons.volume_up, [
          _buildSwitchTile(
            'Suara Notifikasi',
            'Mainkan suara saat menerima notifikasi',
            settings.soundEnabled,
            (value) =>
                _updateSettings(ref, settings.copyWith(soundEnabled: value)),
          ),
          _buildSwitchTile(
            'Getaran',
            'Aktifkan getaran untuk notifikasi',
            settings.vibrationEnabled,
            (value) => _updateSettings(
              ref,
              settings.copyWith(vibrationEnabled: value),
            ),
          ),
        ]),

        const SizedBox(height: 16),

        // Do Not Disturb
        _buildSectionCard('Mode Tidur', Icons.bedtime, [
          _buildTimePicker(
            context,
            'Mulai Mode Tidur',
            settings.doNotDisturbStart,
            (time) => _updateSettings(
              ref,
              settings.copyWith(doNotDisturbStart: time),
            ),
          ),
          _buildTimePicker(
            context,
            'Akhiri Mode Tidur',
            settings.doNotDisturbEnd,
            (time) =>
                _updateSettings(ref, settings.copyWith(doNotDisturbEnd: time)),
          ),
          _buildSwitchTile(
            'Mode Weekend',
            'Kurangi notifikasi di akhir pekan',
            settings.weekendMode,
            (value) =>
                _updateSettings(ref, settings.copyWith(weekendMode: value)),
          ),
        ]),

        const SizedBox(height: 16),

        // Notification Categories
        _buildSectionCard('Kategori Notifikasi', Icons.category, [
          _buildSwitchTile(
            'Presensi',
            'Notifikasi terkait presensi sholat',
            settings.presenceNotifications,
            (value) => _updateSettings(
              ref,
              settings.copyWith(presenceNotifications: value),
            ),
          ),
          _buildSwitchTile(
            'Kegiatan',
            'Notifikasi kegiatan dan jadwal',
            settings.activityNotifications,
            (value) => _updateSettings(
              ref,
              settings.copyWith(activityNotifications: value),
            ),
          ),
          _buildSwitchTile(
            'Prestasi',
            'Notifikasi pencapaian dan badge',
            settings.achievementNotifications,
            (value) => _updateSettings(
              ref,
              settings.copyWith(achievementNotifications: value),
            ),
          ),
          _buildSwitchTile(
            'Pengingat',
            'Reminder dan alarm personal',
            settings.reminderNotifications,
            (value) => _updateSettings(
              ref,
              settings.copyWith(reminderNotifications: value),
            ),
          ),
          _buildSwitchTile(
            'Pengumuman Penting',
            'Pengumuman dari pengurus pondok',
            settings.importantAnnouncements,
            (value) => _updateSettings(
              ref,
              settings.copyWith(importantAnnouncements: value),
            ),
          ),
          _buildSwitchTile(
            'Sosial',
            'Notifikasi dari santri lain',
            settings.socialNotifications,
            (value) => _updateSettings(
              ref,
              settings.copyWith(socialNotifications: value),
            ),
          ),
        ]),

        const SizedBox(height: 16),

        // Action Buttons
        _buildActionButtons(context, ref),
      ],
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    WidgetRef ref,
    List<NotificationHistory> history,
  ) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada notifikasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notifikasi akan muncul di sini\nketika ada aktivitas baru',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header Actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Riwayat Notifikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _markAllAsRead(ref),
                child: const Text('Tandai Semua Dibaca'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear_all),
                onPressed: () => _showClearHistoryDialog(context, ref),
                tooltip: 'Hapus Semua',
              ),
            ],
          ),
        ),

        // Notifications List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              ref.invalidate(notificationHistoryProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final notification = history[index];
                return _buildNotificationCard(context, ref, notification);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String title,
    String currentTime,
    Function(String) onTimeSelected,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        currentTime,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: const Icon(Icons.access_time, size: 20),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(currentTime.split(':')[0]),
            minute: int.parse(currentTime.split(':')[1]),
          ),
        );

        if (time != null) {
          final formattedTime =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          onTimeSelected(formattedTime);
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    NotificationHistory notification,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleNotificationTap(ref, notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          notification.formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      notification.message,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _testNotification(context),
            icon: const Icon(Icons.notifications_active),
            label: const Text('Uji Notifikasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _resetToDefault(context, ref),
            icon: const Icon(Icons.restore),
            label: const Text('Reset ke Default'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Methods
  void _updateSettings(WidgetRef ref, NotificationSettings newSettings) {
    ref.read(notificationSettingsProvider.notifier).state = newSettings;
  }

  void _markAllAsRead(WidgetRef ref) {
    final currentHistory = ref.read(notificationHistoryProvider);
    final updatedHistory = currentHistory
        .map(
          (n) => NotificationHistory(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            timestamp: n.timestamp,
            isRead: true,
            actionUrl: n.actionUrl,
            metadata: n.metadata,
          ),
        )
        .toList();

    ref.read(notificationHistoryProvider.notifier).state = updatedHistory;
  }

  void _handleNotificationTap(WidgetRef ref, NotificationHistory notification) {
    if (!notification.isRead) {
      final currentHistory = ref.read(notificationHistoryProvider);
      final updatedHistory = currentHistory
          .map(
            (n) => n.id == notification.id
                ? NotificationHistory(
                    id: n.id,
                    title: n.title,
                    message: n.message,
                    type: n.type,
                    timestamp: n.timestamp,
                    isRead: true,
                    actionUrl: n.actionUrl,
                    metadata: n.metadata,
                  )
                : n,
          )
          .toList();

      ref.read(notificationHistoryProvider.notifier).state = updatedHistory;
    }
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua riwayat notifikasi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notificationHistoryProvider.notifier).state = [];
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Riwayat notifikasi telah dihapus'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _testNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications, color: Colors.white),
            SizedBox(width: 8),
            Text('Notifikasi uji coba dikirim!'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _resetToDefault(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan'),
        content: const Text(
          'Apakah Anda yakin ingin mengembalikan semua pengaturan notifikasi ke default?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(notificationSettingsProvider.notifier).state =
                  const NotificationSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan telah direset ke default'),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
