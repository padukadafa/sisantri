import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/core/theme/app_theme.dart';
import '../providers/schedule_providers.dart';
import '../utils/schedule_helpers.dart';

/// Widget untuk menampilkan empty state jadwal
class ScheduleEmptyState extends ConsumerWidget {
  final ScheduleFilter filter;
  final bool hasOtherSchedules;
  final VoidCallback onAddPressed;

  const ScheduleEmptyState({
    super.key,
    required this.filter,
    required this.hasOtherSchedules,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                ScheduleHelpers.getEmptyStateTitle(filter),
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                ScheduleHelpers.getEmptyStateMessage(filter, hasOtherSchedules),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (filter != ScheduleFilter.all && hasOtherSchedules)
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(scheduleFilterProvider.notifier).state =
                        ScheduleFilter.all;
                  },
                  icon: const Icon(Icons.all_inclusive),
                  label: const Text('Lihat Semua Jadwal'),
                ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kegiatan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
