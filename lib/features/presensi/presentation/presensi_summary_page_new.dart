import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/presensi_service.dart';

/// Provider untuk periode yang dipilih
final selectedPeriodProvider = StateProvider<String>((ref) => 'Minggu Ini');

/// Provider untuk ringkasan presensi
final presensiSummaryProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  return await PresensiService.getPresensiSummary();
});

/// Provider untuk statistik presensi berdasarkan periode
final presensiStatsProvider =
    FutureProvider.family<List<PresensiStatsModel>, String>((
      ref,
      period,
    ) async {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      switch (period) {
        case 'Hari Ini':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Minggu Ini':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(
            startOfWeek.year,
            startOfWeek.month,
            startOfWeek.day,
          );
          break;
        case 'Bulan Ini':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Semester Ini':
          // Asumsi semester dimulai dari bulan Juli atau Januari
          final semesterStart = now.month >= 7
              ? DateTime(now.year, 7, 1)
              : DateTime(now.year, 1, 1);
          startDate = semesterStart;
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }

      return await PresensiService.getPresensiStats(
        startDate: startDate,
        endDate: endDate,
      );
    });

/// Provider untuk aktivitas terbaru
final recentActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return await PresensiService.getRecentActivities(limit: 5);
});

class PresensiSummaryPage extends ConsumerStatefulWidget {
  const PresensiSummaryPage({super.key});

  @override
  ConsumerState<PresensiSummaryPage> createState() =>
      _PresensiSummaryPageState();
}

class _PresensiSummaryPageState extends ConsumerState<PresensiSummaryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> periods = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini',
    'Semester Ini',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rangkuman Presensi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          PopupMenuButton<String>(
            initialValue: selectedPeriod,
            onSelected: (String value) {
              ref.read(selectedPeriodProvider.notifier).state = value;
            },
            itemBuilder: (BuildContext context) => periods
                .map(
                  (period) =>
                      PopupMenuItem<String>(value: period, child: Text(period)),
                )
                .toList(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedPeriod,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Per Santri'),
            Tab(text: 'Statistik'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildPerSantriTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(presensiSummaryProvider);
        ref.invalidate(recentActivitiesProvider);
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final summaryAsync = ref.watch(presensiSummaryProvider);
                return summaryAsync.when(
                  loading: () => _buildSummaryCardsLoading(),
                  error: (error, stack) =>
                      _buildSummaryCardsError(error.toString()),
                  data: (summary) => _buildSummaryCardsWithData(summary),
                );
              },
            ),
            const SizedBox(height: 24),
            _buildActivityChart(),
            const SizedBox(height: 24),
            Consumer(
              builder: (context, ref, child) {
                final activitiesAsync = ref.watch(recentActivitiesProvider);
                return activitiesAsync.when(
                  loading: () => _buildRecentActivitiesLoading(),
                  error: (error, stack) =>
                      _buildRecentActivitiesError(error.toString()),
                  data: (activities) =>
                      _buildRecentActivitiesWithData(activities),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardsWithData(Map<String, dynamic> summary) {
    final weeklyStats = summary['thisWeek'] as Map<String, dynamic>;
    final totalSantri = summary['totalSantri'] as int;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Total Presensi',
                value: '${weeklyStats['totalPresensi']}',
                subtitle: 'Minggu ini',
                icon: Icons.how_to_reg,
                color: Colors.green,
                trend: 'up',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Rata-rata Hadir',
                value:
                    '${weeklyStats['persentaseKehadiran'].toStringAsFixed(0)}%',
                subtitle: 'Dari $totalSantri santri',
                icon: Icons.trending_up,
                color: Colors.blue,
                trend: 'up',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: 'Terlambat',
                value: '${weeklyStats['totalTerlambat']}',
                subtitle: 'Minggu ini',
                icon: Icons.schedule,
                color: Colors.orange,
                trend: 'down',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'Tidak Hadir',
                value: '${weeklyStats['totalAlpha']}',
                subtitle: 'Minggu ini',
                icon: Icons.cancel,
                color: Colors.red,
                trend: 'up',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(
                  trend == 'up' ? Icons.trending_up : Icons.trending_down,
                  color: trend == 'up' ? Colors.green : Colors.red,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardsLoading() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCardLoading()),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCardLoading()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCardLoading()),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCardLoading()),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCardLoading() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Memuat...'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCardsError(String error) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('Error: $error', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(presensiSummaryProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Grafik Presensi Harian',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              child: const Center(
                child: Text(
                  'Grafik akan diimplementasikan dengan chart library',
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesWithData(List<Map<String, dynamic>> activities) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Center(
                child: Text(
                  'Belum ada aktivitas',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...activities.map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getColorFromString(
                            activity['color'] as String,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconFromString(activity['icon'] as String),
                          color: _getColorFromString(
                            activity['color'] as String,
                          ),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['message'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              activity['time'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesLoading() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Memuat aktivitas...'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesError(String error) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text('Error: $error', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.invalidate(recentActivitiesProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerSantriTab() {
    final selectedPeriod = ref.watch(selectedPeriodProvider);

    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(presensiStatsProvider(selectedPeriod));

        return statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(presensiStatsProvider(selectedPeriod)),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Presensi Per Santri',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (stats.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Belum ada data presensi untuk periode ini',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final santri = stats[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withOpacity(
                              0.1,
                            ),
                            child: Text(
                              santri.userName.substring(0, 1),
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            santri.userName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Row(
                            children: [
                              _buildStatusBadge(
                                'H: ${santri.totalHadir}',
                                Colors.green,
                              ),
                              const SizedBox(width: 4),
                              _buildStatusBadge(
                                'T: ${santri.totalTerlambat}',
                                Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              _buildStatusBadge(
                                'A: ${santri.totalAlpha}',
                                Colors.red,
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPercentageColor(
                                santri.persentaseKehadiran.toInt(),
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${santri.persentaseKehadiran.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: _getPercentageColor(
                                  santri.persentaseKehadiran.toInt(),
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distribusi Kehadiran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDistributionChart(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trend Mingguan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    child: const Center(
                      child: Text(
                        'Grafik trend akan diimplementasikan',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionChart() {
    final data = [
      {'label': 'Hadir', 'value': 85, 'color': Colors.green},
      {'label': 'Terlambat', 'value': 10, 'color': Colors.orange},
      {'label': 'Alpha', 'value': 5, 'color': Colors.red},
    ];

    return Column(
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['label'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${item['value']}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item['color'] as Color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'check_circle':
        return Icons.check_circle;
      case 'schedule':
        return Icons.schedule;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
