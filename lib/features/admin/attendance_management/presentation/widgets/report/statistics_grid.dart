import 'package:flutter/material.dart';

/// Widget untuk menampilkan kartu statistik
class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
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
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid untuk menampilkan kartu statistik
class StatisticsGrid extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsGrid({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        StatisticsCard(
          title: 'Total Presensi',
          value: statistics['totalRecords'].toString(),
          icon: Icons.assignment,
          color: Colors.blue,
        ),
        StatisticsCard(
          title: 'Hadir',
          value: statistics['presentCount'].toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatisticsCard(
          title: 'Alpha',
          value: statistics['absentCount'].toString(),
          icon: Icons.cancel,
          color: Colors.red,
        ),
        StatisticsCard(
          title: 'Tingkat Kehadiran',
          value: '${statistics['attendanceRate'].toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
      ],
    );
  }
}
