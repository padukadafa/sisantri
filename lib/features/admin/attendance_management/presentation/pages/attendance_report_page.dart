import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/shared/models/user_model.dart';
import 'package:sisantri/shared/models/presensi_model.dart';

/// Provider untuk data laporan presensi
final attendanceReportProvider =
    FutureProvider.family<Map<String, dynamic>, AttendanceReportFilter>((
      ref,
      filter,
    ) async {
      try {
        final firestore = FirebaseFirestore.instance;

        // Get users data
        final usersSnapshot = await firestore.collection('users').get();
        final users = usersSnapshot.docs
            .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
            .where((user) => user.isSantri)
            .toList();

        // Build attendance query with proper date filtering
        Query attendanceQuery = firestore.collection('presensi');

        // Apply date filter to attendance records
        if (filter.startDate != null) {
          attendanceQuery = attendanceQuery.where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(filter.startDate!),
          );
        }
        if (filter.endDate != null) {
          final endOfDay = DateTime(
            filter.endDate!.year,
            filter.endDate!.month,
            filter.endDate!.day,
            23,
            59,
            59,
          );
          attendanceQuery = attendanceQuery.where(
            'timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          );
        }

        // Apply user filter
        if (filter.userId != null) {
          attendanceQuery = attendanceQuery.where(
            'userId',
            isEqualTo: filter.userId,
          );
        }

        // Apply status filter
        if (filter.status != null) {
          attendanceQuery = attendanceQuery.where(
            'status',
            isEqualTo: filter.status,
          );
        }

        final attendanceSnapshot = await attendanceQuery.get();

        // Parse to PresensiModel
        final attendanceRecords = <PresensiModel>[];
        for (var doc in attendanceSnapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final record = PresensiModel.fromJson({'id': doc.id, ...data});
            attendanceRecords.add(record);
          } catch (e) {
            // Skip invalid records
            continue;
          }
        }

        // Calculate statistics
        final presentCount = attendanceRecords
            .where((a) => a.status == StatusPresensi.hadir)
            .length;

        final absentCount = attendanceRecords
            .where((a) => a.status == StatusPresensi.alpha)
            .length;

        final sickCount = attendanceRecords
            .where((a) => a.status == StatusPresensi.sakit)
            .length;

        final excusedCount = attendanceRecords
            .where((a) => a.status == StatusPresensi.izin)
            .length;

        final totalExpectedAttendance = attendanceRecords.length;
        final rawAttendanceRate = totalExpectedAttendance > 0
            ? (presentCount / totalExpectedAttendance * 100)
            : 0.0;
        final attendanceRate = rawAttendanceRate.clamp(0.0, 100.0);

        // Group by user for summary
        final userAttendanceSummary = <String, Map<String, dynamic>>{};

        for (final user in users) {
          final userRecords = attendanceRecords
              .where((a) => a.userId == user.id)
              .toList();

          final userPresent = userRecords
              .where((a) => a.status == StatusPresensi.hadir)
              .length;

          final userAbsent = userRecords
              .where((a) => a.status == StatusPresensi.alpha)
              .length;

          final userSick = userRecords
              .where((a) => a.status == StatusPresensi.sakit)
              .length;

          final userExcused = userRecords
              .where((a) => a.status == StatusPresensi.izin)
              .length;

          final userExpectedTotal = userRecords.length;
          final rawUserAttendanceRate = userExpectedTotal > 0
              ? (userPresent / userExpectedTotal * 100)
              : 0.0;
          final userAttendanceRate = rawUserAttendanceRate.clamp(0.0, 100.0);

          userAttendanceSummary[user.id] = {
            'user': user,
            'totalRecords': userExpectedTotal,
            'presentCount': userPresent,
            'absentCount': userAbsent,
            'sickCount': userSick,
            'excusedCount': userExcused,
            'attendanceRate': userAttendanceRate,
          };
        }

        return {
          'attendanceRecords': attendanceRecords,
          'users': users,
          'statistics': {
            'totalRecords': totalExpectedAttendance,
            'presentCount': presentCount,
            'absentCount': absentCount,
            'sickCount': sickCount,
            'excusedCount': excusedCount,
            'attendanceRate': attendanceRate,
          },
          'userSummary': userAttendanceSummary,
        };
      } catch (e) {
        throw Exception('Error loading attendance report: $e');
      }
    });

/// Filter untuk laporan presensi
class AttendanceReportFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? userId;
  final String? status;

  const AttendanceReportFilter({
    this.startDate,
    this.endDate,
    this.userId,
    this.status,
  });

  AttendanceReportFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? status,
  }) {
    return AttendanceReportFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }
}

/// State provider untuk filter
final attendanceFilterProvider = StateProvider<AttendanceReportFilter>((ref) {
  // For debugging: remove date filters to see all data
  return const AttendanceReportFilter();
});

/// Halaman Laporan Presensi
class AttendanceReportPage extends ConsumerStatefulWidget {
  const AttendanceReportPage({super.key});

  @override
  ConsumerState<AttendanceReportPage> createState() =>
      _AttendanceReportPageState();
}

class _AttendanceReportPageState extends ConsumerState<AttendanceReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final filter = ref.watch(attendanceFilterProvider);
    final reportAsync = ref.watch(attendanceReportProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Presensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(attendanceReportProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ringkasan', icon: Icon(Icons.analytics)),
            Tab(text: 'Detail', icon: Icon(Icons.list)),
            Tab(text: 'Per Santri', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Summary
          _buildSummaryTab(reportAsync),
          // Tab 2: Detail records
          _buildDetailTab(reportAsync),
          // Tab 3: Per Santri
          _buildUserSummaryTab(reportAsync),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "main_export",
        onPressed: () => _exportToExcel(),
        child: const Icon(Icons.file_download),
        backgroundColor: Colors.blue,
        tooltip: 'Export Excel',
      ),
    );
  }

  Widget _buildSummaryTab(AsyncValue<Map<String, dynamic>> reportAsync) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(attendanceReportProvider);
      },
      child: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error.toString()),
        data: (data) {
          final stats = data['statistics'] as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSummary(),
                const SizedBox(height: 16),
                _buildStatisticsCards(stats),
                const SizedBox(height: 16),
                _buildAttendanceChart(stats),
                const SizedBox(height: 16),
                _buildTopAttendees(data['userSummary'] as Map<String, dynamic>),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTab(AsyncValue<Map<String, dynamic>> reportAsync) {
    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error.toString()),
      data: (data) {
        final records = data['attendanceRecords'] as List<PresensiModel>;
        final users = data['users'] as List<UserModel>;

        if (records.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(attendanceReportProvider);
            },
            child: const SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada data presensi',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(attendanceReportProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final user = users.firstWhere(
                (u) => u.id == record.userId,
                orElse: () => UserModel(
                  id: record.userId,
                  nama: 'Unknown User',
                  email: '',
                  role: 'santri',
                ),
              );
              return _buildAttendanceRecordCard(record, user);
            },
          ),
        );
      },
    );
  }

  Widget _buildUserSummaryTab(AsyncValue<Map<String, dynamic>> reportAsync) {
    return reportAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error.toString()),
      data: (data) {
        final userSummary = data['userSummary'] as Map<String, dynamic>;
        final sortedEntries = userSummary.entries.toList()
          ..sort(
            (a, b) => (b.value['attendanceRate'] as double).compareTo(
              a.value['attendanceRate'] as double,
            ),
          );

        if (sortedEntries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Tidak ada data santri',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(attendanceReportProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final userSummaryData = entry.value;
              return _buildUserSummaryCard(userSummaryData);
            },
          ),
        );
      },
    );
  }

  Widget _buildFilterSummary() {
    final filter = ref.watch(attendanceFilterProvider);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Filter Aktif',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (filter.startDate != null && filter.endDate != null)
              Text(
                'Periode: ${dateFormat.format(filter.startDate!)} - ${dateFormat.format(filter.endDate!)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            if (filter.status != null)
              Text(
                'Status: ${filter.status!}',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Presensi',
          stats['totalRecords'].toString(),
          Icons.assignment,
          Colors.blue,
        ),
        _buildStatCard(
          'Hadir',
          stats['presentCount'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Tidak Hadir',
          stats['absentCount'].toString(),
          Icons.cancel,
          Colors.red,
        ),
        _buildStatCard(
          'Tingkat Kehadiran',
          '${stats['attendanceRate'].toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChart(Map<String, dynamic> stats) {
    final total = stats['totalRecords'] as int;
    final present = stats['presentCount'] as int;
    final absent = stats['absentCount'] as int;
    final sick = stats['sickCount'] as int;
    final excused = stats['excusedCount'] as int;

    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('Tidak ada data untuk ditampilkan')),
        ),
      );
    }

    // Ensure all values are non-negative
    final safeTotal = total.abs();
    final safePresent = present.clamp(0, safeTotal);
    final safeAbsent = absent.clamp(0, safeTotal);
    final safeSick = sick.clamp(0, safeTotal);
    final safeExcused = excused.clamp(0, safeTotal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Status Presensi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusBar('Hadir', safePresent, safeTotal, Colors.green),
            const SizedBox(height: 8),
            _buildStatusBar('Alpha', safeAbsent, safeTotal, Colors.red),
            const SizedBox(height: 8),
            _buildStatusBar('Sakit', safeSick, safeTotal, Colors.orange),
            const SizedBox(height: 8),
            _buildStatusBar('Izin', safeExcused, safeTotal, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;

    // Ensure percentage is between 0.0 and 1.0
    final safePercentage = percentage.clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: safePercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildTopAttendees(Map<String, dynamic> userSummary) {
    final sortedEntries = userSummary.entries.toList()
      ..sort(
        (a, b) => (b.value['attendanceRate'] as double).compareTo(
          a.value['attendanceRate'] as double,
        ),
      );

    final topAttendees = sortedEntries.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 Santri Terbaik',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (topAttendees.isEmpty)
              const Center(
                child: Text(
                  'Tidak ada data',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...topAttendees.asMap().entries.map((entry) {
                final index = entry.key;
                final userData = entry.value.value;
                final user = userData['user'] as UserModel;
                final rate = userData['attendanceRate'] as double;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(user.nama),
                  subtitle: Text(
                    '${userData['presentCount']}/${userData['totalRecords']} hadir',
                  ),
                  trailing: Text(
                    '${rate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRankColor(index),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecordCard(PresensiModel record, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.status.color,
          child: Icon(record.status.icon, color: Colors.white, size: 20),
        ),
        title: Text(user.nama),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${record.status.label}'),
            if (record.keterangan?.isNotEmpty == true)
              Text(
                'Keterangan: ${record.keterangan}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(record.tanggal),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('HH:mm').format(record.tanggal),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSummaryCard(Map<String, dynamic> userSummaryData) {
    final user = userSummaryData['user'] as UserModel;
    final totalRecords = userSummaryData['totalRecords'] as int;
    final presentCount = userSummaryData['presentCount'] as int;
    final attendanceRate = userSummaryData['attendanceRate'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getAttendanceRateColor(attendanceRate),
          child: Text(
            user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.nama),
        subtitle: Text(
          'Tingkat kehadiran: ${attendanceRate.toStringAsFixed(1)}%',
        ),
        trailing: Text(
          '$presentCount/$totalRecords',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Hadir',
                  userSummaryData['presentCount'].toString(),
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Alpha',
                  userSummaryData['absentCount'].toString(),
                  Colors.red,
                ),
                _buildSummaryItem(
                  'Sakit',
                  userSummaryData['sickCount'].toString(),
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'Izin',
                  userSummaryData['excusedCount'].toString(),
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading report',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(attendanceReportProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const _FilterDialog());
  }

  Future<void> _exportToExcel() async {
    try {
      // Request storage permissions first (especially for Downloads access)

      if (Platform.isAndroid) {
        // Check and request storage permissions
        final storageStatus = await Permission.storage.status;

        if (!storageStatus.isGranted) {
          final result = await Permission.storage.request();

          if (!result.isGranted) {
            // Storage permission denied, will use app-specific directory
          }
        }

        // For Android 11+ (API 30+), might need MANAGE_EXTERNAL_STORAGE for Downloads
        try {
          final manageStorageStatus =
              await Permission.manageExternalStorage.status;

          if (!manageStorageStatus.isGranted) {
            // Show info to user before requesting this sensitive permission
            if (mounted) {
              final shouldRequest = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Storage Access'),
                  content: const Text(
                    'To save files directly to Downloads folder, the app needs access to manage external storage. This is optional - files can still be saved to app folder.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Skip'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Grant Access'),
                    ),
                  ],
                ),
              );

              if (shouldRequest == true) {
                await Permission.manageExternalStorage.request();
              }
            }
          }
        } catch (e) {
          // Manage external storage permission error
        }
      }

      // Debug: Check if we have data first
      final filter = ref.read(attendanceFilterProvider);
      final reportData = await ref.read(
        attendanceReportProvider(filter).future,
      );

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting to Excel...'),
            ],
          ),
        ),
      );

      final attendanceRecords =
          reportData['attendanceRecords'] as List<PresensiModel>;
      final users = reportData['users'] as List<UserModel>;
      final statistics = reportData['statistics'] as Map<String, dynamic>;
      final userSummary = reportData['userSummary'] as Map<String, dynamic>;

      // Create Excel workbook
      final excel = excel_lib.Excel.createExcel();

      // Remove default sheet
      excel.delete('Sheet1');

      // Create Summary sheet
      final summarySheet = excel['Ringkasan'];
      _createSummarySheet(summarySheet, statistics, filter);

      // Create Detail Records sheet
      final detailSheet = excel['Detail Presensi'];
      _createDetailSheet(detailSheet, attendanceRecords, users);

      // Create Per Santri summary sheet
      final santriSheet = excel['Per Santri'];
      _createSantriSummarySheet(santriSheet, userSummary);

      // Save file to /storage/emulated/0/Download (public folder) if available
      Directory? directory;
      String directoryType = '';

      if (Platform.isAndroid) {
        final publicDownloads = Directory('/storage/emulated/0/Download');
        if (await publicDownloads.exists()) {
          directory = publicDownloads;
          directoryType = 'Public Downloads';
        } else {
          // Fallback: app-specific downloads folder
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            directory = Directory('${directory.path}/Downloads');
            directoryType = 'App External Storage/Downloads';
          }
        }
      } else {
        // For iOS and other platforms
        directory = await getApplicationDocumentsDirectory();
        directoryType = 'App Documents';
      }

      final fileName = _generateFileName(filter);
      final filePath = directory != null
          ? '${directory.path}/$fileName'
          : fileName;

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);

        // Ensure the directory exists
        await file.parent.create(recursive: true);

        // Write the file
        await file.writeAsBytes(fileBytes);

        // Verify file was created
        if (await file.exists()) {
          await file.length();
        } else {
          throw Exception('File was not created after writing');
        }
      } else {
        throw Exception('Failed to generate Excel file bytes');
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message with emphasis on Downloads location
      if (mounted) {
        final isDownloadsFolder = directoryType.toLowerCase().contains(
          'downloads',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDownloadsFolder
                  ? '✅ Excel berhasil disimpan!\n📁 Lokasi: $directoryType\n📄 File: $fileName\n\n${attendanceRecords.length} records exported'
                  : '✅ Exported ${attendanceRecords.length} records\nSaved to: $directoryType\nFile: $fileName',
            ),
            backgroundColor: isDownloadsFolder ? Colors.green : Colors.blue,
            duration: const Duration(seconds: 7),
            action: SnackBarAction(
              label: isDownloadsFolder ? 'Buka File' : 'Open File',
              onPressed: () => _openExportedFile(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Export Error Details'),
                    content: SingleChildScrollView(child: Text(e.toString())),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  void _createSummarySheet(
    excel_lib.Sheet sheet,
    Map<String, dynamic> stats,
    AttendanceReportFilter filter,
  ) {
    // Title
    sheet.cell(excel_lib.CellIndex.indexByString('A1')).value =
        excel_lib.TextCellValue('LAPORAN RINGKASAN PRESENSI');
    sheet.merge(
      excel_lib.CellIndex.indexByString('A1'),
      excel_lib.CellIndex.indexByString('D1'),
    );

    // Filter information
    int row = 3;
    if (filter.startDate != null && filter.endDate != null) {
      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          excel_lib.TextCellValue('Periode:');
      sheet
          .cell(excel_lib.CellIndex.indexByString('B$row'))
          .value = excel_lib.TextCellValue(
        '${DateFormat('dd/MM/yyyy').format(filter.startDate!)} - ${DateFormat('dd/MM/yyyy').format(filter.endDate!)}',
      );
      row++;
    }

    if (filter.status != null) {
      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          excel_lib.TextCellValue('Filter Status:');
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
          excel_lib.TextCellValue(filter.status!);
      row++;
    }

    row++; // Empty row

    // Statistics
    sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
        excel_lib.TextCellValue('STATISTIK');
    row++;

    sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
        excel_lib.TextCellValue('Total Presensi:');
    sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
        excel_lib.IntCellValue(stats['totalRecords']);
    row++;

    sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
        excel_lib.TextCellValue('Hadir:');
    sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
        excel_lib.IntCellValue(stats['presentCount']);
    row++;

    sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
        excel_lib.TextCellValue('Alpha:');
    sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
        excel_lib.IntCellValue(stats['absentCount']);
    row++;

    sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
        excel_lib.TextCellValue('Sakit:');
    sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
        excel_lib.IntCellValue(stats['sickCount']);
    row++;

    sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
        excel_lib.TextCellValue('Izin:');
    sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
        excel_lib.IntCellValue(stats['excusedCount']);
    row++;

    sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
        excel_lib.TextCellValue('Tingkat Kehadiran:');
    sheet
        .cell(excel_lib.CellIndex.indexByString('B$row'))
        .value = excel_lib.TextCellValue(
      '${stats['attendanceRate'].toStringAsFixed(1)}%',
    );
  }

  void _createDetailSheet(
    excel_lib.Sheet sheet,
    List<PresensiModel> records,
    List<UserModel> users,
  ) {
    // Headers
    sheet.cell(excel_lib.CellIndex.indexByString('A1')).value =
        excel_lib.TextCellValue('No');
    sheet.cell(excel_lib.CellIndex.indexByString('B1')).value =
        excel_lib.TextCellValue('Nama Santri');
    sheet.cell(excel_lib.CellIndex.indexByString('C1')).value =
        excel_lib.TextCellValue('Tanggal');
    sheet.cell(excel_lib.CellIndex.indexByString('D1')).value =
        excel_lib.TextCellValue('Waktu');
    sheet.cell(excel_lib.CellIndex.indexByString('E1')).value =
        excel_lib.TextCellValue('Status');
    sheet.cell(excel_lib.CellIndex.indexByString('F1')).value =
        excel_lib.TextCellValue('Keterangan');

    // Data
    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      final user = users.firstWhere(
        (u) => u.id == record.userId,
        orElse: () => UserModel(
          id: record.userId,
          nama: 'Unknown User',
          email: '',
          role: 'santri',
        ),
      );

      final row = i + 2;
      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          excel_lib.IntCellValue(i + 1);
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
          excel_lib.TextCellValue(user.nama);
      sheet
          .cell(excel_lib.CellIndex.indexByString('C$row'))
          .value = excel_lib.TextCellValue(
        DateFormat('dd/MM/yyyy').format(record.tanggal),
      );
      sheet.cell(excel_lib.CellIndex.indexByString('D$row')).value =
          excel_lib.TextCellValue(DateFormat('HH:mm').format(record.tanggal));
      sheet.cell(excel_lib.CellIndex.indexByString('E$row')).value =
          excel_lib.TextCellValue(record.status.label);
      sheet.cell(excel_lib.CellIndex.indexByString('F$row')).value =
          excel_lib.TextCellValue(record.keterangan ?? '');
    }
  }

  void _createSantriSummarySheet(
    excel_lib.Sheet sheet,
    Map<String, dynamic> userSummary,
  ) {
    // Headers
    sheet.cell(excel_lib.CellIndex.indexByString('A1')).value =
        excel_lib.TextCellValue('No');
    sheet.cell(excel_lib.CellIndex.indexByString('B1')).value =
        excel_lib.TextCellValue('Nama Santri');
    sheet.cell(excel_lib.CellIndex.indexByString('C1')).value =
        excel_lib.TextCellValue('Total Kegiatan');
    sheet.cell(excel_lib.CellIndex.indexByString('D1')).value =
        excel_lib.TextCellValue('Hadir');
    sheet.cell(excel_lib.CellIndex.indexByString('E1')).value =
        excel_lib.TextCellValue('Alpha');
    sheet.cell(excel_lib.CellIndex.indexByString('F1')).value =
        excel_lib.TextCellValue('Sakit');
    sheet.cell(excel_lib.CellIndex.indexByString('G1')).value =
        excel_lib.TextCellValue('Izin');
    sheet.cell(excel_lib.CellIndex.indexByString('H1')).value =
        excel_lib.TextCellValue('Tingkat Kehadiran (%)');

    // Sort by attendance rate
    final sortedEntries = userSummary.entries.toList()
      ..sort(
        (a, b) => (b.value['attendanceRate'] as double).compareTo(
          a.value['attendanceRate'] as double,
        ),
      );

    // Data
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      final data = entry.value;
      final user = data['user'] as UserModel;

      final row = i + 2;
      sheet.cell(excel_lib.CellIndex.indexByString('A$row')).value =
          excel_lib.IntCellValue(i + 1);
      sheet.cell(excel_lib.CellIndex.indexByString('B$row')).value =
          excel_lib.TextCellValue(user.nama);
      sheet.cell(excel_lib.CellIndex.indexByString('C$row')).value =
          excel_lib.IntCellValue(data['totalRecords']);
      sheet.cell(excel_lib.CellIndex.indexByString('D$row')).value =
          excel_lib.IntCellValue(data['presentCount']);
      sheet.cell(excel_lib.CellIndex.indexByString('E$row')).value =
          excel_lib.IntCellValue(data['absentCount']);
      sheet.cell(excel_lib.CellIndex.indexByString('F$row')).value =
          excel_lib.IntCellValue(data['sickCount']);
      sheet.cell(excel_lib.CellIndex.indexByString('G$row')).value =
          excel_lib.IntCellValue(data['excusedCount']);
      sheet.cell(excel_lib.CellIndex.indexByString('H$row')).value =
          excel_lib.TextCellValue(data['attendanceRate'].toStringAsFixed(1));
    }
  }

  String _generateFileName(AttendanceReportFilter filter) {
    final now = DateTime.now();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(now);

    String prefix = 'Laporan_Presensi';

    if (filter.startDate != null && filter.endDate != null) {
      final startStr = DateFormat('ddMMyyyy').format(filter.startDate!);
      final endStr = DateFormat('ddMMyyyy').format(filter.endDate!);
      prefix += '_${startStr}_${endStr}';
    }

    if (filter.status != null) {
      prefix += '_${filter.status}';
    }

    return '${prefix}_$timestamp.xlsx';
  }

  Future<void> _openExportedFile(String filePath) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ File not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Try to open the file
      final result = await OpenFile.open(filePath);

      if (mounted) {
        if (result.type == ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📂 File opened successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (result.type == ResultType.noAppToOpen) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('❌ No app available to open Excel files'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Show Path',
                onPressed: () {
                  _showFilePath(filePath);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to open file: ${result.message}'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Show Path',
                onPressed: () {
                  _showFilePath(filePath);
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error opening file: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Show Path',
              onPressed: () {
                _showFilePath(filePath);
              },
            ),
          ),
        );
      }
    }
  }

  void _showFilePath(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('File saved at:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                filePath,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can manually navigate to this location using a file manager app.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getAttendanceRateColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 80) return Colors.orange;
    if (rate >= 70) return Colors.red.shade300;
    return Colors.red;
  }
}

/// Dialog untuk filter laporan
class _FilterDialog extends ConsumerStatefulWidget {
  const _FilterDialog();

  @override
  ConsumerState<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<_FilterDialog> {
  late AttendanceReportFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(attendanceFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Laporan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date range
            ListTile(
              title: const Text('Tanggal Mulai'),
              subtitle: Text(
                _tempFilter.startDate != null
                    ? DateFormat('dd MMM yyyy').format(_tempFilter.startDate!)
                    : 'Pilih tanggal',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectStartDate(),
            ),
            ListTile(
              title: const Text('Tanggal Akhir'),
              subtitle: Text(
                _tempFilter.endDate != null
                    ? DateFormat('dd MMM yyyy').format(_tempFilter.endDate!)
                    : 'Pilih tanggal',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectEndDate(),
            ),

            // Status filter
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              value: _tempFilter.status,
              items: const [
                DropdownMenuItem(value: null, child: Text('Semua Status')),
                DropdownMenuItem(value: 'Hadir', child: Text('Hadir')),
                DropdownMenuItem(value: 'Alpha', child: Text('Alpha')),
                DropdownMenuItem(value: 'Sakit', child: Text('Sakit')),
                DropdownMenuItem(value: 'Izin', child: Text('Izin')),
              ],
              onChanged: (value) {
                setState(() {
                  _tempFilter = _tempFilter.copyWith(status: value);
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Reset filter
            setState(() {
              final now = DateTime.now();
              final startOfMonth = DateTime(now.year, now.month, 1);
              _tempFilter = AttendanceReportFilter(
                startDate: startOfMonth,
                endDate: now,
              );
            });
          },
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () {
            // Show all data (no date filter)
            setState(() {
              _tempFilter = const AttendanceReportFilter();
            });
          },
          child: const Text('Tampilkan Semua'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(attendanceFilterProvider.notifier).state = _tempFilter;
            Navigator.pop(context);
          },
          child: const Text('Terapkan'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempFilter.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _tempFilter = _tempFilter.copyWith(startDate: date);
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempFilter.endDate ?? DateTime.now(),
      firstDate: _tempFilter.startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _tempFilter = _tempFilter.copyWith(endDate: date);
      });
    }
  }
}
