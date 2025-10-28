import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/core/theme/app_theme.dart';

import '../models/jadwal_kegiatan_model.dart';
import '../providers/schedule_providers.dart';
import '../widgets/schedule_filter_menu.dart';
import '../widgets/schedule_list_view.dart';
import 'add_edit_jadwal_page.dart';

class ScheduleManagementPage extends ConsumerWidget {
  const ScheduleManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jadwalAsync = ref.watch(jadwalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Jadwal'),
        actions: [const ScheduleFilterMenu()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(jadwalProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: jadwalAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorView(ref),
          data: (jadwalList) => ScheduleListView(
            jadwalList: jadwalList,
            onAddPressed: () => _showAddEditDialog(context, ref),
            onJadwalTap: (jadwal) =>
                _showAddEditDialog(context, ref, jadwal: jadwal),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context, ref),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(jadwalProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight > 400 ? constraints.maxHeight : 400,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text('Terjadi kesalahan saat memuat data'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(jadwalProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref, {
    JadwalKegiatan? jadwal,
  }) async {
    final result = await Navigator.push<JadwalKegiatan>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditJadwalPage(jadwal: jadwal),
      ),
    );

    if (result != null) {
      // Jadwal sudah disimpan di AddEditJadwalPage
      // Hanya refresh provider untuk update UI
      ref.invalidate(jadwalProvider);
    }
  }
}
