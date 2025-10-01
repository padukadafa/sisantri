import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_providers.dart';
import 'stats_header.dart';
import 'mini_stat_card.dart';

class DashboardAdditionalStats extends ConsumerWidget {
  const DashboardAdditionalStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatsAsync = ref.watch(userStatsProvider);

    return userStatsAsync.when(
      loading: () => Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StatsHeader(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MiniStatCard(
                      title: 'Minggu Ini',
                      value: '${stats['weeklyPersentase']}%',
                      subtitle:
                          '${stats['weeklyHadir']}/${stats['weeklyTotal']} hadir',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MiniStatCard(
                      title: 'Bulan Ini',
                      value: '${stats['monthlyPersentase']}%',
                      subtitle:
                          '${stats['monthlyHadir']}/${stats['monthlyTotal']} hadir',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
