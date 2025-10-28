import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

/// Model untuk Kegiatan/Event
class KegiatanEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String category; // 'kajian', 'olahraga', 'umum'
  final bool isWajib;
  final String? pengampu; // Ustadz/Pengajar

  const KegiatanEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.category,
    this.isWajib = false,
    this.pengampu,
  });
}

/// Provider untuk daftar kegiatan
final kegiatanListProvider = StateProvider<List<KegiatanEvent>>(
  (ref) => [
    KegiatanEvent(
      id: '2',
      title: 'Kajian Tafsir Al-Quran',
      description: 'Kajian rutin tafsir Al-Quran pada malam hari',
      date: DateTime.now(),
      startTime: const TimeOfDay(hour: 19, minute: 30),
      endTime: const TimeOfDay(hour: 20, minute: 30),
      location: 'Aula Pondok',
      category: 'kajian',
      isWajib: false,
      pengampu: 'Ustadz Ahmad Fauzi',
    ),
    KegiatanEvent(
      id: '3',
      title: 'Olahraga Pagi',
      description: 'Senam dan olahraga ringan bersama',
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: const TimeOfDay(hour: 6, minute: 0),
      endTime: const TimeOfDay(hour: 7, minute: 0),
      location: 'Lapangan Pondok',
      category: 'olahraga',
      isWajib: false,
    ),
    KegiatanEvent(
      id: '4',
      title: 'Gotong Royong',
      description: 'Kerja bakti membersihkan lingkungan pondok',
      date: DateTime.now().add(const Duration(days: 2)),
      startTime: const TimeOfDay(hour: 7, minute: 0),
      endTime: const TimeOfDay(hour: 9, minute: 0),
      location: 'Seluruh Area Pondok',
      category: 'umum',
      isWajib: true,
    ),
  ],
);

/// Provider untuk tanggal yang dipilih
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Provider untuk bulan yang ditampilkan
final displayedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Provider untuk kategori filter
final categoryFilterProvider = StateProvider<String>((ref) => 'semua');

/// Halaman Kalender Kegiatan
class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final displayedMonth = ref.watch(displayedMonthProvider);
    final kegiatanList = ref.watch(kegiatanListProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);

    // Filter kegiatan berdasarkan tanggal dan kategori
    final filteredKegiatan = _getEventsForDay(kegiatanList, selectedDate)
        .where(
          (event) =>
              categoryFilter == 'semua' || event.category == categoryFilter,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Kegiatan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              final now = DateTime.now();
              ref.read(selectedDateProvider.notifier).state = now;
              ref.read(displayedMonthProvider.notifier).state = now;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Widget
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              children: [
                // Calendar Header
                _buildCalendarHeader(context, ref, displayedMonth),

                // Weekday Labels
                _buildWeekdayLabels(),

                // Calendar Grid
                _buildCalendarGrid(
                  context,
                  ref,
                  displayedMonth,
                  selectedDate,
                  kegiatanList,
                ),
              ],
            ),
          ),

          // Filter Categories
          _buildCategoryFilter(context, ref, categoryFilter),

          // Events List
          Expanded(
            child: filteredKegiatan.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredKegiatan.length,
                    itemBuilder: (context, index) {
                      final event = filteredKegiatan[index];
                      return _buildEventCard(context, event);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context, ref, selectedDate),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarHeader(
    BuildContext context,
    WidgetRef ref,
    DateTime displayedMonth,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
            onPressed: () {
              final previousMonth = DateTime(
                displayedMonth.year,
                displayedMonth.month - 1,
              );
              ref.read(displayedMonthProvider.notifier).state = previousMonth;
            },
          ),
          Text(
            _formatMonthYear(displayedMonth),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
            onPressed: () {
              final nextMonth = DateTime(
                displayedMonth.year,
                displayedMonth.month + 1,
              );
              ref.read(displayedMonthProvider.notifier).state = nextMonth;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    final weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: weekdays
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    WidgetRef ref,
    DateTime displayedMonth,
    DateTime selectedDate,
    List<KegiatanEvent> kegiatanList,
  ) {
    final daysInMonth = _getDaysInMonth(displayedMonth);
    final firstDayOfWeek = _getFirstDayOfWeek(displayedMonth);

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: 42, // 6 weeks * 7 days
        itemBuilder: (context, index) {
          if (index < firstDayOfWeek) {
            return const SizedBox(); // Empty space for days before month starts
          }

          final dayNumber = index - firstDayOfWeek + 1;
          if (dayNumber > daysInMonth) {
            return const SizedBox(); // Empty space for days after month ends
          }

          final currentDate = DateTime(
            displayedMonth.year,
            displayedMonth.month,
            dayNumber,
          );
          final eventsForDay = _getEventsForDay(kegiatanList, currentDate);
          final isSelected = _isSameDay(currentDate, selectedDate);
          final isToday = _isSameDay(currentDate, DateTime.now());

          return GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = currentDate;
            },
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : isToday
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected || isToday
                          ? Colors.white
                          : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  if (eventsForDay.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected || isToday
                            ? Colors.white
                            : AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(
    BuildContext context,
    WidgetRef ref,
    String currentFilter,
  ) {
    final categories = [
      {'value': 'semua', 'label': 'Semua', 'icon': Icons.all_inclusive},
      {'value': 'kajian', 'label': 'Kajian', 'icon': Icons.menu_book},
      {'value': 'olahraga', 'label': 'Olahraga', 'icon': Icons.sports},
      {'value': 'umum', 'label': 'Umum', 'icon': Icons.event},
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = currentFilter == category['value'];

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 16,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category['label'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
              ),
              onSelected: (selected) {
                ref.read(categoryFilterProvider.notifier).state =
                    category['value'] as String;
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, KegiatanEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEventDetail(context, event),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time & Category Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getCategoryColor(event.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(event.category),
                      color: _getCategoryColor(event.category),
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.startTime.format(context)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(event.category),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2E2E2E),
                            ),
                          ),
                        ),
                        if (event.isWajib)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'WAJIB',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      event.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),

                    if (event.pengampu != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            event.pengampu!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada kegiatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada kegiatan yang dijadwalkan\nuntuk hari ini',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<KegiatanEvent> _getEventsForDay(
    List<KegiatanEvent> events,
    DateTime day,
  ) {
    return events.where((event) => _isSameDay(event.date, day)).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _getFirstDayOfWeek(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return (firstDay.weekday - 1) % 7; // Monday = 0
  }

  String _formatMonthYear(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'kajian':
        return Colors.blue;
      case 'olahraga':
        return Colors.orange;
      case 'umum':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'kajian':
        return Icons.menu_book;
      case 'olahraga':
        return Icons.sports;
      case 'umum':
        return Icons.event;
      default:
        return Icons.event;
    }
  }

  // Dialog Methods
  void _showEventDetail(BuildContext context, KegiatanEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            _buildDetailRow('Tanggal', _formatDate(event.date)),
            _buildDetailRow(
              'Waktu',
              '${event.startTime.format(context)} - ${event.endTime.format(context)}',
            ),
            _buildDetailRow('Lokasi', event.location),
            _buildDetailRow('Kategori', _getCategoryLabel(event.category)),
            if (event.pengampu != null)
              _buildDetailRow('Pengampu', event.pengampu!),
            _buildDetailRow('Status', event.isWajib ? 'Wajib' : 'Opsional'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Pengingat untuk "${event.title}" telah diatur',
                  ),
                ),
              );
            },
            child: const Text('Set Reminder'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showAddEventDialog(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur tambah kegiatan akan segera hadir')),
    );
  }

  String _formatDate(DateTime date) {
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'kajian':
        return 'Kajian';
      case 'olahraga':
        return 'Olahraga';
      case 'umum':
        return 'Umum';
      default:
        return 'Lainnya';
    }
  }
}
