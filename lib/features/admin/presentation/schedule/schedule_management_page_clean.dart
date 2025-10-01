import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/jadwal_kegiatan_model.dart';
import 'providers/schedule_providers.dart';
import 'widgets/schedule_stats_bar.dart';
import 'widgets/schedule_card.dart';
import 'widgets/schedule_dialogs.dart';
import 'services/schedule_service.dart';

/// Halaman manajemen jadwal yang telah dipecah
class ScheduleManagementPageClean extends ConsumerStatefulWidget {
  const ScheduleManagementPageClean({super.key});

  @override
  ConsumerState<ScheduleManagementPageClean> createState() =>
      _ScheduleManagementPageCleanState();
}

class _ScheduleManagementPageCleanState
    extends ConsumerState<ScheduleManagementPageClean> {
  final ScheduleService _scheduleService = ScheduleService();

  @override
  Widget build(BuildContext context) {
    final jadwalAsync = ref.watch(jadwalProvider);
    final stats = ref.watch(jadwalStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Jadwal'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ScheduleDialogs.showAddDialog(context),
            tooltip: 'Tambah Jadwal Baru',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(jadwalProvider);
        },
        child: Column(
          children: [
            ScheduleStatsBar(stats: stats),

            Expanded(
              child: jadwalAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorWidget(error),
                data: (jadwalList) {
                  if (jadwalList.isEmpty) {
                    return _buildEmptyWidget();
                  }

                  return ListView.builder(
                    itemCount: jadwalList.length,
                    itemBuilder: (context, index) {
                      final jadwal = jadwalList[index];
                      return ScheduleCard(
                        jadwal: jadwal,
                        onTap: () =>
                            ScheduleDialogs.showDetailDialog(context, jadwal),
                        onEdit: () =>
                            ScheduleDialogs.showEditDialog(context, jadwal),
                        onDelete: () => _confirmDelete(jadwal),
                        onToggleStatus: () => _toggleStatus(jadwal),
                        onDuplicate: () => ScheduleDialogs.showDuplicateDialog(
                          context,
                          jadwal,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(jadwalProvider),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada jadwal',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(JadwalKegiatan jadwal) {
    ScheduleDialogs.showConfirmDelete(
      context,
      jadwal,
      () => _scheduleService.deleteJadwal(jadwal.id),
    );
  }

  void _toggleStatus(JadwalKegiatan jadwal) {
    _scheduleService.toggleJadwalStatus(jadwal.id, jadwal.isAktif);
  }
}
