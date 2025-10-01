import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_management_providers.dart';

/// Widget untuk menampilkan statistik users
class UserStatsCard extends ConsumerWidget {
  const UserStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistik Pengguna',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
              data: (stats) => _buildStatsGrid(stats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatItem('Total', stats['total'] ?? 0, Icons.people, Colors.blue),
        _buildStatItem(
          'Santri',
          stats['santri'] ?? 0,
          Icons.school,
          Colors.green,
        ),
        _buildStatItem('Guru', stats['guru'] ?? 0, Icons.person, Colors.purple),
        _buildStatItem(
          'Admin',
          stats['admin'] ?? 0,
          Icons.admin_panel_settings,
          Colors.orange,
        ),
        _buildStatItem(
          'Aktif',
          stats['active'] ?? 0,
          Icons.check_circle,
          Colors.teal,
        ),
        _buildStatItem(
          'Tidak Aktif',
          stats['inactive'] ?? 0,
          Icons.block,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, int count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
