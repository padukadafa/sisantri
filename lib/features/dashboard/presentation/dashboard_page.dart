import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/auth_service.dart';
import 'providers/dashboard_providers.dart';
import 'widgets/dashboard_notification_button.dart';
import 'widgets/dashboard_error_widget.dart';
import 'widgets/dashboard_content.dart';

/// Halaman Dashboard utama aplikasi
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AuthService.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('User tidak ditemukan')));
    }

    final dashboardData = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [DashboardNotificationButton()],
      ),
      body: dashboardData.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat dashboard...'),
            ],
          ),
        ),
        error: (error, stack) => DashboardErrorWidget(error: error, ref: ref),
        data: (data) => DashboardContent(data: data, ref: ref),
      ),
    );
  }
}
