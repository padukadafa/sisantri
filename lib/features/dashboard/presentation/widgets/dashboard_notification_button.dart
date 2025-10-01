import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_providers.dart';
import 'notification_badge.dart';
import 'notifications_dialog.dart';

class DashboardNotificationButton extends ConsumerWidget {
  const DashboardNotificationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return notificationsAsync.when(
      loading: () => IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () {},
      ),
      error: (error, stack) => IconButton(
        icon: const Icon(Icons.notifications_outlined),
        onPressed: () {},
      ),
      data: (notifications) => Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _showNotificationsDialog(context, notifications),
          ),
          NotificationBadge(count: notifications.length),
        ],
      ),
    );
  }

  void _showNotificationsDialog(
    BuildContext context,
    List<Map<String, dynamic>> notifications,
  ) {
    showDialog(
      context: context,
      builder: (context) => NotificationsDialog(notifications: notifications),
    );
  }
}
