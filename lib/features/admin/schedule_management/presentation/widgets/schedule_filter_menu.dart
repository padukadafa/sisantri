import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/core/theme/app_theme.dart';
import '../providers/schedule_providers.dart';

/// Widget untuk menu filter jadwal
class ScheduleFilterMenu extends ConsumerWidget {
  const ScheduleFilterMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleFilter = ref.watch(scheduleFilterProvider);

    return PopupMenuButton<ScheduleFilter>(
      icon: Icon(
        Icons.filter_list,
        color: scheduleFilter != ScheduleFilter.futureOnly
            ? AppTheme.primaryColor
            : null,
      ),
      tooltip: 'Filter Jadwal',
      onSelected: (value) {
        ref.read(scheduleFilterProvider.notifier).state = value;
      },
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          ScheduleFilter.futureOnly,
          'Mendatang Saja',
          scheduleFilter,
        ),
        _buildMenuItem(
          context,
          ScheduleFilter.thisMonthAndFuture,
          'Bulan Ini & Mendatang',
          scheduleFilter,
        ),
        _buildMenuItem(
          context,
          ScheduleFilter.lastMonth,
          '1 Bulan Terakhir',
          scheduleFilter,
        ),
        _buildMenuItem(
          context,
          ScheduleFilter.last3Months,
          '3 Bulan Terakhir',
          scheduleFilter,
        ),
        _buildMenuItem(
          context,
          ScheduleFilter.all,
          'Semua Jadwal',
          scheduleFilter,
        ),
      ],
    );
  }

  PopupMenuItem<ScheduleFilter> _buildMenuItem(
    BuildContext context,
    ScheduleFilter value,
    String label,
    ScheduleFilter currentFilter,
  ) {
    final isSelected = currentFilter == value;

    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: isSelected ? AppTheme.primaryColor : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
