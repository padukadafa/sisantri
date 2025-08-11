import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/services/firestore_service.dart';
import '../../../shared/models/jadwal_pengajian_model.dart';
import '../../../shared/models/jadwal_kegiatan_model.dart';

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
                    color: AppTheme.primaryColor.withOpacity(0.1),
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
    final jadwalKegiatanStream = ref.watch(jadwalKegiatanProvider);

    return jadwalKegiatanStream.when(
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada jadwal kegiatan',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
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
    );
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
                    color: Colors.blue.withOpacity(0.1),
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
