import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/shared/services/firestore_service.dart';
import 'package:sisantri/shared/models/jadwal_pengajian_model.dart';
import 'package:sisantri/shared/models/jadwal_kegiatan_model.dart';

/// Provider untuk jadwal pengajian
final jadwalPengajianProvider = StreamProvider<List<JadwalPengajianModel>>((
  ref,
) {
  return FirestoreService.getJadwalPengajian();
});

/// Provider untuk jadwal kegiatan
final jadwalKegiatanProvider = StreamProvider<List<JadwalKegiatanModel>>((ref) {
  return FirestoreService.getJadwalKegiatan();
});

/// Provider untuk tab index jadwal
final jadwalTabProvider = StateProvider<int>((ref) => 0);

/// Enum untuk mode filter tanggal
enum DateFilterMode {
  all, // Semua kegiatan
  singleDate, // Tanggal tertentu
  month, // Bulan tertentu
  dateRange, // Rentang tanggal
}

/// Model untuk filter tanggal kegiatan
class DateFilterModel {
  final DateFilterMode mode;
  final DateTime? singleDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;

  DateFilterModel({
    this.mode = DateFilterMode.all,
    this.singleDate,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
  });

  DateFilterModel copyWith({
    DateFilterMode? mode,
    DateTime? singleDate,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
  }) {
    return DateFilterModel(
      mode: mode ?? this.mode,
      singleDate: singleDate ?? this.singleDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  bool matchesDate(DateTime date) {
    switch (mode) {
      case DateFilterMode.all:
        return true;
      case DateFilterMode.singleDate:
        if (singleDate == null) return true;
        return date.year == singleDate!.year &&
            date.month == singleDate!.month &&
            date.day == singleDate!.day;
      case DateFilterMode.month:
        if (month == null || year == null) return true;
        return date.month == month && date.year == year;
      case DateFilterMode.dateRange:
        if (startDate == null || endDate == null) return true;
        return date.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            date.isBefore(endDate!.add(const Duration(days: 1)));
    }
  }

  String get displayText {
    final formatter = DateFormat('dd MMM yyyy');
    final monthFormatter = DateFormat('MMMM yyyy');

    switch (mode) {
      case DateFilterMode.all:
        return 'Semua Kegiatan';
      case DateFilterMode.singleDate:
        return singleDate != null
            ? formatter.format(singleDate!)
            : 'Pilih Tanggal';
      case DateFilterMode.month:
        if (month != null && year != null) {
          return monthFormatter.format(DateTime(year!, month!));
        }
        return 'Pilih Bulan';
      case DateFilterMode.dateRange:
        if (startDate != null && endDate != null) {
          return '${formatter.format(startDate!)} - ${formatter.format(endDate!)}';
        }
        return 'Pilih Rentang';
    }
  }
}

/// Provider untuk filter tanggal kegiatan
final kegiatanDateFilterProvider = StateProvider<DateFilterModel>((ref) {
  return DateFilterModel();
});

/// Provider untuk kegiatan yang sudah difilter
final filteredKegiatanProvider =
    Provider<AsyncValue<List<JadwalKegiatanModel>>>((ref) {
      final kegiatanAsync = ref.watch(jadwalKegiatanProvider);
      final filter = ref.watch(kegiatanDateFilterProvider);

      return kegiatanAsync.whenData((kegiatanList) {
        if (filter.mode == DateFilterMode.all) {
          return kegiatanList;
        }

        return kegiatanList.where((kegiatan) {
          return filter.matchesDate(kegiatan.tanggal);
        }).toList();
      });
    });

/// Halaman Jadwal (Pengajian & Kegiatan)
class JadwalPage extends ConsumerWidget {
  const JadwalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jadwal'),
          bottom: TabBar(
            onTap: (index) {
              ref.read(jadwalTabProvider.notifier).state = index;
            },
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Pengajian'),
              Tab(text: 'Kegiatan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_JadwalPengajianTab(), _JadwalKegiatanTab()],
        ),
      ),
    );
  }
}

/// Tab untuk Jadwal Pengajian
class _JadwalPengajianTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalPengajianStream = ref.watch(jadwalPengajianProvider);

    return jadwalPengajianStream.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(jadwalPengajianProvider);
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
      data: (jadwalList) {
        if (jadwalList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada jadwal pengajian',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(jadwalPengajianProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jadwalList.length,
            itemBuilder: (context, index) {
              final jadwal = jadwalList[index];
              return _buildPengajianCard(jadwal);
            },
          ),
        );
      },
    );
  }

  Widget _buildPengajianCard(JadwalPengajianModel jadwal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal.tema ?? jadwal.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pemateri: ${jadwal.pemateri}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  jadwal.formattedTanggal,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  jadwal.formattedWaktu,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            if (jadwal.tempat != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    jadwal.tempat!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (jadwal.deskripsi != null) ...[
              const SizedBox(height: 12),
              Text(
                jadwal.deskripsi!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tab untuk Jadwal Kegiatan
class _JadwalKegiatanTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredKegiatanAsync = ref.watch(filteredKegiatanProvider);
    final filter = ref.watch(kegiatanDateFilterProvider);

    return Column(
      children: [
        // Filter section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.filter_list, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Filter Kegiatan:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (filter.mode != DateFilterMode.all)
                    TextButton.icon(
                      onPressed: () {
                        ref.read(kegiatanDateFilterProvider.notifier).state =
                            DateFilterModel();
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Reset'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context: context,
                      ref: ref,
                      label: 'Semua',
                      mode: DateFilterMode.all,
                      icon: Icons.all_inclusive,
                      isSelected: filter.mode == DateFilterMode.all,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context: context,
                      ref: ref,
                      label: 'Tanggal',
                      mode: DateFilterMode.singleDate,
                      icon: Icons.event,
                      isSelected: filter.mode == DateFilterMode.singleDate,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context: context,
                      ref: ref,
                      label: 'Bulan',
                      mode: DateFilterMode.month,
                      icon: Icons.calendar_month,
                      isSelected: filter.mode == DateFilterMode.month,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context: context,
                      ref: ref,
                      label: 'Rentang',
                      mode: DateFilterMode.dateRange,
                      icon: Icons.date_range,
                      isSelected: filter.mode == DateFilterMode.dateRange,
                    ),
                  ],
                ),
              ),
              if (filter.mode != DateFilterMode.all) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          filter.displayText,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Content section
        Expanded(
          child: filteredKegiatanAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(jadwalKegiatanProvider);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
            data: (jadwalList) {
              if (jadwalList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        filter.mode == DateFilterMode.all
                            ? 'Belum ada jadwal kegiatan'
                            : 'Tidak ada kegiatan\n${filter.displayText}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(jadwalKegiatanProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jadwalList.length,
                  itemBuilder: (context, index) {
                    final jadwal = jadwalList[index];
                    return _buildKegiatanCard(jadwal);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required DateFilterMode mode,
    required IconData icon,
    required bool isSelected,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) async {
        if (selected) {
          await _showDatePickerForMode(context, ref, mode);
        }
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Future<void> _showDatePickerForMode(
    BuildContext context,
    WidgetRef ref,
    DateFilterMode mode,
  ) async {
    final now = DateTime.now();

    switch (mode) {
      case DateFilterMode.all:
        ref.read(kegiatanDateFilterProvider.notifier).state = DateFilterModel();
        break;

      case DateFilterMode.singleDate:
        final date = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          helpText: 'Pilih Tanggal',
        );
        if (date != null) {
          ref.read(kegiatanDateFilterProvider.notifier).state = DateFilterModel(
            mode: DateFilterMode.singleDate,
            singleDate: date,
          );
        }
        break;

      case DateFilterMode.month:
        final result = await showDialog<Map<String, int>>(
          context: context,
          builder: (context) => _MonthPickerDialog(
            initialMonth: now.month,
            initialYear: now.year,
          ),
        );
        if (result != null) {
          ref.read(kegiatanDateFilterProvider.notifier).state = DateFilterModel(
            mode: DateFilterMode.month,
            month: result['month'],
            year: result['year'],
          );
        }
        break;

      case DateFilterMode.dateRange:
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDateRange: DateTimeRange(
            start: now,
            end: now.add(const Duration(days: 7)),
          ),
          helpText: 'Pilih Rentang Tanggal',
        );
        if (range != null) {
          ref.read(kegiatanDateFilterProvider.notifier).state = DateFilterModel(
            mode: DateFilterMode.dateRange,
            startDate: range.start,
            endDate: range.end,
          );
        }
        break;
    }
  }

  Widget _buildKegiatanCard(JadwalKegiatanModel jadwal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event, color: Colors.blue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jadwal.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jadwal.tempat ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (jadwal.isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else if (jadwal.isTomorrow)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Besok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  jadwal.formattedTanggal,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  jadwal.formattedWaktu,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            if (jadwal.deskripsi != null) ...[
              const SizedBox(height: 12),
              Text(
                jadwal.deskripsi!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dialog untuk memilih bulan dan tahun
class _MonthPickerDialog extends StatefulWidget {
  final int initialMonth;
  final int initialYear;

  const _MonthPickerDialog({
    required this.initialMonth,
    required this.initialYear,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return AlertDialog(
      title: const Text('Pilih Bulan'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedYear--;
                    });
                  },
                ),
                Text(
                  '$selectedYear',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedYear++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Month grid
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == selectedMonth;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedMonth = month;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          months[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'month': selectedMonth,
              'year': selectedYear,
            });
          },
          child: const Text('Pilih'),
        ),
      ],
    );
  }
}
