import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

/// Model untuk aktivitas
class ActivityRecord {
  final String id;
  final String title;
  final String type; // 'presensi', 'kegiatan', 'achievement', 'point'
  final String description;
  final DateTime timestamp;
  final int? pointsEarned;
  final String? location;
  final bool isPositive;

  const ActivityRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.timestamp,
    this.pointsEarned,
    this.location,
    this.isPositive = true,
  });

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  IconData get icon {
    switch (type) {
      case 'presensi':
        return Icons.check_circle;
      case 'kegiatan':
        return Icons.event;
      case 'achievement':
        return Icons.emoji_events;
      case 'point':
        return Icons.star;
      default:
        return Icons.history;
    }
  }

  Color get color {
    if (!isPositive) return Colors.red;

    switch (type) {
      case 'presensi':
        return Colors.green;
      case 'kegiatan':
        return Colors.blue;
      case 'achievement':
        return Colors.amber;
      case 'point':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }
}

/// Provider untuk activity history
final activityHistoryProvider = StateProvider<List<ActivityRecord>>((ref) {
  final now = DateTime.now();
  return [
    ActivityRecord(
      id: '1',
      title: 'Presensi Sholat Subuh',
      type: 'presensi',
      description: 'Berhasil presensi sholat subuh berjamaah',
      timestamp: now.subtract(const Duration(hours: 2)),
      pointsEarned: 10,
      location: 'Masjid Al-Awwabin',
    ),
    ActivityRecord(
      id: '2',
      title: 'Achievement Unlocked!',
      type: 'achievement',
      description: 'Meraih prestasi "Perfect Week"',
      timestamp: now.subtract(const Duration(hours: 5)),
      pointsEarned: 50,
    ),
    ActivityRecord(
      id: '3',
      title: 'Kajian Tafsir Al-Quran',
      type: 'kegiatan',
      description: 'Mengikuti kajian tafsir Al-Quran',
      timestamp: now.subtract(const Duration(days: 1)),
      pointsEarned: 15,
      location: 'Aula Pondok',
    ),
    ActivityRecord(
      id: '4',
      title: 'Bonus Poin Mingguan',
      type: 'point',
      description: 'Mendapat bonus poin untuk performa minggu ini',
      timestamp: now.subtract(const Duration(days: 2)),
      pointsEarned: 25,
    ),
    ActivityRecord(
      id: '5',
      title: 'Olahraga Pagi',
      type: 'kegiatan',
      description: 'Mengikuti senam dan olahraga pagi bersama',
      timestamp: now.subtract(const Duration(days: 3)),
      pointsEarned: 5,
      location: 'Lapangan Pondok',
    ),
    ActivityRecord(
      id: '6',
      title: 'Presensi Sholat Maghrib',
      type: 'presensi',
      description: 'Berhasil presensi sholat maghrib berjamaah',
      timestamp: now.subtract(const Duration(days: 3)),
      pointsEarned: 10,
      location: 'Masjid Al-Awwabin',
    ),
    ActivityRecord(
      id: '7',
      title: 'Gotong Royong',
      type: 'kegiatan',
      description: 'Kerja bakti membersihkan lingkungan pondok',
      timestamp: now.subtract(const Duration(days: 5)),
      pointsEarned: 8,
      location: 'Seluruh Area Pondok',
    ),
    ActivityRecord(
      id: '8',
      title: 'Terlambat Presensi',
      type: 'presensi',
      description: 'Terlambat melakukan presensi sholat isya',
      timestamp: now.subtract(const Duration(days: 6)),
      pointsEarned: -5,
      isPositive: false,
      location: 'Masjid Al-Awwabin',
    ),
  ];
});

/// Provider untuk filter aktivitas
final activityFilterProvider = StateProvider<String>((ref) => 'all');

/// Provider untuk date range filter
final dateRangeFilterProvider = StateProvider<String>((ref) => 'week');

/// Halaman Riwayat Aktivitas
class ActivityHistoryPage extends ConsumerWidget {
  const ActivityHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityHistoryProvider);
    final typeFilter = ref.watch(activityFilterProvider);
    final dateFilter = ref.watch(dateRangeFilterProvider);

    // Filter activities
    final filteredActivities = _filterActivities(
      activities,
      typeFilter,
      dateFilter,
    );

    // Calculate stats
    final totalPoints = filteredActivities
        .where((a) => a.pointsEarned != null)
        .fold<int>(0, (sum, a) => sum + (a.pointsEarned ?? 0));
    final positiveActivities = filteredActivities
        .where((a) => a.isPositive)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearHistoryDialog(context, ref),
            tooltip: 'Bersihkan Riwayat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          _buildSummaryCard(
            totalPoints,
            positiveActivities,
            filteredActivities.length,
          ),

          // Filters
          _buildFilters(context, ref, typeFilter, dateFilter),

          // Activities List
          Expanded(
            child: filteredActivities.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      // Simulate refresh
                      await Future.delayed(const Duration(seconds: 1));
                      ref.invalidate(activityHistoryProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredActivities.length,
                      itemBuilder: (context, index) {
                        final activity = filteredActivities[index];
                        return _buildActivityCard(context, activity);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    int totalPoints,
    int positiveActivities,
    int totalActivities,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total Poin',
              '$totalPoints',
              Icons.star,
              totalPoints >= 0 ? Colors.green : Colors.red,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          Expanded(
            child: _buildSummaryItem(
              'Aktivitas',
              '$positiveActivities/$totalActivities',
              Icons.trending_up,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(
    BuildContext context,
    WidgetRef ref,
    String typeFilter,
    String dateFilter,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Type Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  ref,
                  'all',
                  'Semua',
                  typeFilter,
                  activityFilterProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  ref,
                  'presensi',
                  'Presensi',
                  typeFilter,
                  activityFilterProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  ref,
                  'kegiatan',
                  'Kegiatan',
                  typeFilter,
                  activityFilterProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  ref,
                  'achievement',
                  'Prestasi',
                  typeFilter,
                  activityFilterProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  ref,
                  'point',
                  'Poin',
                  typeFilter,
                  activityFilterProvider,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Date Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  ref,
                  'week',
                  'Minggu Ini',
                  dateFilter,
                  dateRangeFilterProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  ref,
                  'month',
                  'Bulan Ini',
                  dateFilter,
                  dateRangeFilterProvider,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  ref,
                  'all',
                  'Semua Waktu',
                  dateFilter,
                  dateRangeFilterProvider,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String value,
    String label,
    String currentValue,
    StateProvider<String> provider,
  ) {
    final isSelected = currentValue == value;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.primaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
      ),
      onSelected: (selected) {
        ref.read(provider.notifier).state = value;
      },
    );
  }

  Widget _buildActivityCard(BuildContext context, ActivityRecord activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activity.isPositive ? Colors.grey[200]! : Colors.red[100]!,
          width: 1,
        ),
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
        onTap: () => _showActivityDetail(context, activity),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon & Points
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: activity.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: activity.color.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(activity.icon, color: activity.color, size: 24),
                  ),

                  if (activity.pointsEarned != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: activity.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${activity.pointsEarned! >= 0 ? '+' : ''}${activity.pointsEarned}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: activity.color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: activity.isPositive
                                  ? const Color(0xFF2E2E2E)
                                  : Colors.red[700],
                            ),
                          ),
                        ),
                        Text(
                          activity.formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      activity.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Location
                    if (activity.location != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activity.location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada aktivitas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai ikuti kegiatan untuk melihat\nriwayat aktivitas Anda',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  List<ActivityRecord> _filterActivities(
    List<ActivityRecord> activities,
    String typeFilter,
    String dateFilter,
  ) {
    var filtered = activities;

    // Filter by type
    if (typeFilter != 'all') {
      filtered = filtered.where((a) => a.type == typeFilter).toList();
    }

    // Filter by date
    if (dateFilter != 'all') {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      if (dateFilter == 'week') {
        filtered = filtered
            .where((a) => a.timestamp.isAfter(startOfWeek))
            .toList();
      } else if (dateFilter == 'month') {
        filtered = filtered
            .where((a) => a.timestamp.isAfter(startOfMonth))
            .toList();
      }
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  void _showActivityDetail(BuildContext context, ActivityRecord activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(activity.icon, color: activity.color),
            const SizedBox(width: 8),
            Expanded(child: Text(activity.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description, style: const TextStyle(fontSize: 14)),

            const SizedBox(height: 16),

            _buildDetailRow('Waktu', activity.formattedDate),
            if (activity.location != null)
              _buildDetailRow('Lokasi', activity.location!),
            if (activity.pointsEarned != null)
              _buildDetailRow(
                'Poin',
                '${activity.pointsEarned! >= 0 ? '+' : ''}${activity.pointsEarned}',
              ),
            _buildDetailRow('Tipe', _getTypeLabel(activity.type)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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

  String _getTypeLabel(String type) {
    switch (type) {
      case 'presensi':
        return 'Presensi';
      case 'kegiatan':
        return 'Kegiatan';
      case 'achievement':
        return 'Prestasi';
      case 'point':
        return 'Poin';
      default:
        return type;
    }
  }

  void _showClearHistoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bersihkan Riwayat'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua riwayat aktivitas? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(activityHistoryProvider.notifier).state = [];
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Riwayat aktivitas telah dibersihkan'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }
}
