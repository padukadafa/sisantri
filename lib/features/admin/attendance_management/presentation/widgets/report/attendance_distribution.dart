import 'package:flutter/material.dart';

/// Widget untuk menampilkan status presensi dengan progress bar
class StatusProgressBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const StatusProgressBar({
    super.key,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$count (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan distribusi status presensi
class AttendanceDistribution extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const AttendanceDistribution({super.key, required this.statistics});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return Colors.green;
      case 'sakit':
        return Colors.orange;
      case 'izin':
        return Colors.blue;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = statistics['totalRecords'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StatusProgressBar(
              label: 'Hadir',
              count: statistics['presentCount'] as int,
              total: total,
              color: _getStatusColor('hadir'),
            ),
            StatusProgressBar(
              label: 'Sakit',
              count: statistics['sickCount'] as int,
              total: total,
              color: _getStatusColor('sakit'),
            ),
            StatusProgressBar(
              label: 'Izin',
              count: statistics['excusedCount'] as int,
              total: total,
              color: _getStatusColor('izin'),
            ),
            StatusProgressBar(
              label: 'Alpha',
              count: statistics['absentCount'] as int,
              total: total,
              color: _getStatusColor('alpha'),
            ),
          ],
        ),
      ),
    );
  }
}
