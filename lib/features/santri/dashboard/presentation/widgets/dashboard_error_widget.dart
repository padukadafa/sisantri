import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_providers.dart';
import '../providers/stats_providers.dart';
import '../providers/notification_providers.dart';

class DashboardErrorWidget extends StatelessWidget {
  final Object error;
  final WidgetRef ref;

  const DashboardErrorWidget({
    super.key,
    required this.error,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Terjadi kesalahan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _refreshAllData(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  void _refreshAllData() {
    ref.invalidate(dashboardUserProvider);
    ref.invalidate(todayPresensiProvider);
    ref.invalidate(upcomingKegiatanProvider);
    ref.invalidate(recentPengumumanProvider);
    ref.invalidate(userStatsProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(userRankProvider);
  }
}
