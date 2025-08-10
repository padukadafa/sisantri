import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

/// Model untuk notifikasi
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // 'pengumuman', 'presensi', 'kegiatan', 'system'
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  IconData get icon {
    switch (type) {
      case 'pengumuman':
        return Icons.campaign;
      case 'presensi':
        return Icons.check_circle;
      case 'kegiatan':
        return Icons.event;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (type) {
      case 'pengumuman':
        return Colors.blue;
      case 'presensi':
        return Colors.green;
      case 'kegiatan':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'pengumuman':
        return 'Pengumuman';
      case 'presensi':
        return 'Presensi';
      case 'kegiatan':
        return 'Kegiatan';
      case 'system':
        return 'Sistem';
      default:
        return 'Notifikasi';
    }
  }
}

/// Provider untuk notifikasi (dummy data untuk sekarang)
final notificationsProvider = StateProvider<List<NotificationModel>>((ref) {
  final now = DateTime.now();
  return [
    NotificationModel(
      id: '1',
      title: 'Pengumuman Penting: Perubahan Jadwal',
      body:
          'Jadwal pengajian hari Jumat telah diubah menjadi pukul 14:00 WIB. Mohon untuk hadir tepat waktu.',
      type: 'pengumuman',
      createdAt: now.subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Presensi Berhasil',
      body:
          'Presensi Anda hari ini telah tercatat. Terima kasih atas kehadiran Anda.',
      type: 'presensi',
      createdAt: now.subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    NotificationModel(
      id: '3',
      title: 'Kegiatan Besok: Kajian Tafsir',
      body:
          'Jangan lupa menghadiri kajian tafsir besok pukul 19:30 di Aula Pondok.',
      type: 'kegiatan',
      createdAt: now.subtract(const Duration(hours: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: '4',
      title: 'Selamat! Anda Top 3 Minggu Ini',
      body:
          'Congratulations! Anda berada di posisi 2 leaderboard minggu ini dengan 95 poin.',
      type: 'system',
      createdAt: now.subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: 'Reminder: Presensi Hari Ini',
      body:
          'Jangan lupa untuk melakukan presensi hari ini sebelum pukul 23:59.',
      type: 'presensi',
      createdAt: now.subtract(const Duration(days: 2)),
      isRead: false,
    ),
  ];
});

/// Provider untuk filter notifikasi
final notificationFilterProvider = StateProvider<String>((ref) => 'all');

/// Halaman Notifikasi
class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final currentFilter = ref.watch(notificationFilterProvider);

    // Filter notifications
    final filteredNotifications = _filterNotifications(
      notifications,
      currentFilter,
    );
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifikasi'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => _markAllAsRead(ref),
              child: const Text('Tandai Semua', style: TextStyle(fontSize: 12)),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              ref.read(notificationFilterProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'unread', child: Text('Belum Dibaca')),
              const PopupMenuItem(
                value: 'pengumuman',
                child: Text('Pengumuman'),
              ),
              const PopupMenuItem(value: 'presensi', child: Text('Presensi')),
              const PopupMenuItem(value: 'kegiatan', child: Text('Kegiatan')),
              const PopupMenuItem(value: 'system', child: Text('Sistem')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Header
          if (currentFilter != 'all')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter: ${_getFilterLabel(currentFilter)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(notificationFilterProvider.notifier).state =
                          'all';
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentFilter == 'all'
                              ? 'Belum ada notifikasi'
                              : 'Tidak ada notifikasi ${_getFilterLabel(currentFilter).toLowerCase()}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationCard(context, notification, ref);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon dan unread indicator
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: notification.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: notification.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.color,
                      size: 24,
                    ),
                  ),
                  if (!notification.isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge dan time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: notification.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: notification.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            notification.typeLabel,
                            style: TextStyle(
                              color: notification.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          notification.formattedTime,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: notification.isRead
                            ? Colors.grey[800]
                            : const Color(0xFF2E2E2E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Body
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action button
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
                onSelected: (value) {
                  if (value == 'mark_read' && !notification.isRead) {
                    _markAsRead(notification.id, ref);
                  } else if (value == 'mark_unread' && notification.isRead) {
                    _markAsUnread(notification.id, ref);
                  } else if (value == 'delete') {
                    _deleteNotification(notification.id, ref);
                  }
                },
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_read',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_read, size: 16),
                          SizedBox(width: 8),
                          Text('Tandai Dibaca'),
                        ],
                      ),
                    ),
                  if (notification.isRead)
                    const PopupMenuItem(
                      value: 'mark_unread',
                      child: Row(
                        children: [
                          Icon(Icons.mark_email_unread, size: 16),
                          SizedBox(width: 8),
                          Text('Tandai Belum Dibaca'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification, WidgetRef ref) {
    // Mark as read if unread
    if (!notification.isRead) {
      _markAsRead(notification.id, ref);
    }

    // Handle navigation based on notification type
    // TODO: Implement navigation to specific pages based on notification type and data
  }

  void _markAsRead(String notificationId, WidgetRef ref) {
    final notifications = ref.read(notificationsProvider);
    final updatedNotifications = notifications.map((n) {
      if (n.id == notificationId) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          createdAt: n.createdAt,
          isRead: true,
          data: n.data,
        );
      }
      return n;
    }).toList();

    ref.read(notificationsProvider.notifier).state = updatedNotifications;
  }

  void _markAsUnread(String notificationId, WidgetRef ref) {
    final notifications = ref.read(notificationsProvider);
    final updatedNotifications = notifications.map((n) {
      if (n.id == notificationId) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          createdAt: n.createdAt,
          isRead: false,
          data: n.data,
        );
      }
      return n;
    }).toList();

    ref.read(notificationsProvider.notifier).state = updatedNotifications;
  }

  void _markAllAsRead(WidgetRef ref) {
    final notifications = ref.read(notificationsProvider);
    final updatedNotifications = notifications.map((n) {
      return NotificationModel(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        createdAt: n.createdAt,
        isRead: true,
        data: n.data,
      );
    }).toList();

    ref.read(notificationsProvider.notifier).state = updatedNotifications;
  }

  void _deleteNotification(String notificationId, WidgetRef ref) {
    final notifications = ref.read(notificationsProvider);
    final updatedNotifications = notifications
        .where((n) => n.id != notificationId)
        .toList();

    ref.read(notificationsProvider.notifier).state = updatedNotifications;
  }

  List<NotificationModel> _filterNotifications(
    List<NotificationModel> notifications,
    String filter,
  ) {
    switch (filter) {
      case 'unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'pengumuman':
      case 'presensi':
      case 'kegiatan':
      case 'system':
        return notifications.where((n) => n.type == filter).toList();
      default:
        return notifications;
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'unread':
        return 'Belum Dibaca';
      case 'pengumuman':
        return 'Pengumuman';
      case 'presensi':
        return 'Presensi';
      case 'kegiatan':
        return 'Kegiatan';
      case 'system':
        return 'Sistem';
      default:
        return 'Semua';
    }
  }
}
