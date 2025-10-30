import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/jadwal_kegiatan_model.dart';
import '../providers/schedule_providers.dart';
import '../utils/schedule_helpers.dart';
import 'schedule_empty_state.dart';
import 'schedule_info_banner.dart';
import 'schedule_date_group.dart';

/// Widget untuk menampilkan list jadwal dengan filter
class ScheduleListView extends ConsumerWidget {
  final List<JadwalKegiatan> jadwalList;
  final VoidCallback onAddPressed;
  final Function(JadwalKegiatan) onJadwalTap;
  final Function(JadwalKegiatan)? onJadwalDelete;

  const ScheduleListView({
    super.key,
    required this.jadwalList,
    required this.onAddPressed,
    required this.onJadwalTap,
    this.onJadwalDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleFilter = ref.watch(scheduleFilterProvider);
    final filteredList = _filterJadwal(jadwalList, scheduleFilter);

    if (filteredList.isEmpty) {
      return ScheduleEmptyState(
        filter: scheduleFilter,
        hasOtherSchedules: jadwalList.isNotEmpty,
        onAddPressed: onAddPressed,
      );
    }

    final groupedJadwal = _groupJadwalByDate(filteredList);
    final sortedKeys = _sortDateKeys(groupedJadwal.keys.toList());

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount:
          sortedKeys.length + (scheduleFilter != ScheduleFilter.all ? 1 : 0),
      itemBuilder: (context, index) {
        if (scheduleFilter != ScheduleFilter.all && index == 0) {
          return ScheduleInfoBanner(filter: scheduleFilter);
        }

        final dateIndex = scheduleFilter != ScheduleFilter.all
            ? index - 1
            : index;
        final dateKey = sortedKeys[dateIndex];
        final jadwalHari = groupedJadwal[dateKey]!;
        final date = ScheduleHelpers.parseDateKey(dateKey);

        return ScheduleDateGroup(
          date: date,
          jadwalList: jadwalHari,
          onJadwalTap: onJadwalTap,
          onJadwalDelete: onJadwalDelete,
          isFirstGroup: dateIndex == 0,
        );
      },
    );
  }

  List<JadwalKegiatan> _filterJadwal(
    List<JadwalKegiatan> jadwalList,
    ScheduleFilter filter,
  ) {
    final now = DateTime.now();

    switch (filter) {
      case ScheduleFilter.futureOnly:
        final today = DateTime(now.year, now.month, now.day);
        return jadwalList.where((jadwal) {
          final jadwalDate = DateTime(
            jadwal.tanggal.year,
            jadwal.tanggal.month,
            jadwal.tanggal.day,
          );
          return jadwalDate.isAtSameMomentAs(today) ||
              jadwalDate.isAfter(today);
        }).toList();

      case ScheduleFilter.thisMonthAndFuture:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return jadwalList.where((jadwal) {
          final jadwalDate = DateTime(
            jadwal.tanggal.year,
            jadwal.tanggal.month,
            jadwal.tanggal.day,
          );
          return jadwalDate.isAtSameMomentAs(startOfMonth) ||
              jadwalDate.isAfter(startOfMonth);
        }).toList();

      case ScheduleFilter.lastMonth:
        final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
        return jadwalList.where((jadwal) {
          final jadwalDate = DateTime(
            jadwal.tanggal.year,
            jadwal.tanggal.month,
            jadwal.tanggal.day,
          );
          return jadwalDate.isAtSameMomentAs(oneMonthAgo) ||
              jadwalDate.isAfter(oneMonthAgo);
        }).toList();

      case ScheduleFilter.last3Months:
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return jadwalList.where((jadwal) {
          final jadwalDate = DateTime(
            jadwal.tanggal.year,
            jadwal.tanggal.month,
            jadwal.tanggal.day,
          );
          return jadwalDate.isAtSameMomentAs(threeMonthsAgo) ||
              jadwalDate.isAfter(threeMonthsAgo);
        }).toList();

      case ScheduleFilter.all:
        return jadwalList;
    }
  }

  Map<String, List<JadwalKegiatan>> _groupJadwalByDate(
    List<JadwalKegiatan> jadwalList,
  ) {
    final grouped = <String, List<JadwalKegiatan>>{};

    for (final jadwal in jadwalList) {
      final dateKey = ScheduleHelpers.formatDateKey(jadwal.tanggal);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(jadwal);
    }

    return grouped;
  }

  List<String> _sortDateKeys(List<String> keys) {
    return keys..sort((a, b) {
      final dateA = ScheduleHelpers.parseDateKey(a);
      final dateB = ScheduleHelpers.parseDateKey(b);
      return dateA.compareTo(dateB);
    });
  }
}
