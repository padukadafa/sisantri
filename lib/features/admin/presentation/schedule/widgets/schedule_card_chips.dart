import 'package:flutter/material.dart';
import '../models/jadwal_kegiatan_model.dart';

/// Widget untuk chips kategori dan status pada schedule card
class ScheduleCardChips extends StatelessWidget {
  final JadwalKegiatan jadwal;

  const ScheduleCardChips({super.key, required this.jadwal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [_buildKategoriChip(), const Spacer(), _buildStatusChip()],
    );
  }

  Widget _buildKategoriChip() {
    Color color = Colors.blue;
    switch (jadwal.kategori.value) {
      case 'pengajian':
        color = Colors.green;
        break;
      case 'kajian':
        color = Colors.purple;
        break;
      case 'tahfidz':
        color = Colors.orange;
        break;
      case 'olahraga':
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        jadwal.kategori.value.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: jadwal.isAktif
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        jadwal.isAktif ? 'AKTIF' : 'NONAKTIF',
        style: TextStyle(
          color: jadwal.isAktif ? Colors.green : Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
