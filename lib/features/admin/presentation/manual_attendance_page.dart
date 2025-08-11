import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/jadwal_model.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/helpers/messaging_helper.dart';

/// Provider untuk daftar santri
final santriListProvider = FutureProvider<List<UserModel>>((ref) async {
  return await AuthService.getSantriList();
});

/// Provider untuk 5 kegiatan terakhir yang tersedia
final activitiesProvider = FutureProvider<List<JadwalModel>>((ref) async {
  try {
    // Ambil 5 kegiatan terakhir dari jadwal yang aktif
    final jadwalSnapshot = await FirebaseFirestore.instance
        .collection('jadwal')
        .where('isAktif', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    if (jadwalSnapshot.docs.isNotEmpty) {
      return jadwalSnapshot.docs.map((doc) {
        final data = doc.data();
        return JadwalModel.fromJson({'id': doc.id, ...data});
      }).toList();
    }

    // Fallback: jika tidak ada jadwal aktif, ambil yang terbaru berdasarkan createdAt
    final fallbackSnapshot = await FirebaseFirestore.instance
        .collection('jadwal')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    if (fallbackSnapshot.docs.isNotEmpty) {
      return fallbackSnapshot.docs.map((doc) {
        final data = doc.data();
        return JadwalModel.fromJson({'id': doc.id, ...data});
      }).toList();
    }

    return [];
  } catch (e) {
    // Jika gagal dengan index, coba tanpa orderBy
    try {
      final simpleSnapshot = await FirebaseFirestore.instance
          .collection('jadwal')
          .limit(5)
          .get();

      return simpleSnapshot.docs.map((doc) {
        final data = doc.data();
        return JadwalModel.fromJson({'id': doc.id, ...data});
      }).toList();
    } catch (e2) {
      print('Error loading activities: $e2');
      return [];
    }
  }
});

/// Halaman untuk absensi manual oleh admin
class ManualAttendancePage extends ConsumerStatefulWidget {
  const ManualAttendancePage({super.key});

  @override
  ConsumerState<ManualAttendancePage> createState() =>
      _ManualAttendancePageState();
}

class _ManualAttendancePageState extends ConsumerState<ManualAttendancePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedActivity;
  String _attendanceStatus = 'hadir';

  // Track selected santri for bulk operations
  final Set<String> _selectedSantri = {};
  bool _isSelectMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final santriAsync = ref.watch(santriListProvider);
    final activitiesAsync = ref.watch(activitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Manual'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isSelectMode)
            TextButton(
              onPressed: _selectedSantri.isEmpty ? null : _bulkAttendance,
              child: Text(
                'Absen (${_selectedSantri.length})',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          IconButton(
            icon: Icon(_isSelectMode ? Icons.close : Icons.checklist),
            onPressed: () {
              setState(() {
                _isSelectMode = !_isSelectMode;
                if (!_isSelectMode) {
                  _selectedSantri.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(activitiesAsync),
          Expanded(
            child: santriAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (santriList) => _buildSantriList(santriList),
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectMode && _selectedSantri.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _bulkAttendance,
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.check),
              label: Text('Absen ${_selectedSantri.length} Santri'),
            )
          : null,
    );
  }

  Widget _buildFiltersSection(AsyncValue<List<JadwalModel>> activitiesAsync) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama santri...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),

            // Activity selector
            const Text(
              'Kegiatan:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            activitiesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error loading activities: $error'),
              data: (activities) => DropdownButtonFormField<String>(
                value: _selectedActivity,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.event),
                ),
                hint: const Text('Pilih dari kegiatan tersedia'),
                items: activities.map((jadwal) {
                  return DropdownMenuItem<String>(
                    value: jadwal.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getKategoriColor(
                                jadwal.kategori.value,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getKategoriColor(
                                  jadwal.kategori.value,
                                ).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              jadwal.kategori.value.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getKategoriColor(jadwal.kategori.value),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              jadwal.displayTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivity = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Status selector
            const Text(
              'Status Kehadiran:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatusChip('hadir', 'Hadir', Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusChip('izin', 'Izin', Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusChip('alpha', 'Alpha', Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, Color color) {
    final isSelected = _attendanceStatus == value;

    return InkWell(
      onTap: () {
        setState(() {
          _attendanceStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: isSelected ? 2 : 1),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSantriList(List<UserModel> santriList) {
    // Filter santri based on search query
    final filteredSantri = santriList.where((santri) {
      if (_searchQuery.isEmpty) return true;
      return santri.nama.toLowerCase().contains(_searchQuery) ||
          (santri.nim?.toLowerCase().contains(_searchQuery) ?? false) ||
          (santri.kampus?.toLowerCase().contains(_searchQuery) ?? false);
    }).toList();

    if (filteredSantri.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Tidak ada santri yang terdaftar'
                  : 'Tidak ada santri yang sesuai dengan pencarian',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredSantri.length,
      itemBuilder: (context, index) {
        final santri = filteredSantri[index];
        final isSelected = _selectedSantri.contains(santri.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: _isSelectMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedSantri.add(santri.id);
                        } else {
                          _selectedSantri.remove(santri.id);
                        }
                      });
                    },
                  )
                : CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      santri.nama.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            title: Text(
              santri.nama,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (santri.nim != null) Text('NIM: ${santri.nim}'),
                if (santri.kampus != null) Text('Kampus: ${santri.kampus}'),
                if (santri.tempatKos != null) Text('Kos: ${santri.tempatKos}'),
              ],
            ),
            trailing: _isSelectMode
                ? null
                : ElevatedButton(
                    onPressed: _selectedActivity == null
                        ? null
                        : () => _recordAttendance(santri),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusColor(_attendanceStatus),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(_getStatusLabel(_attendanceStatus)),
                  ),
            onTap: _isSelectMode
                ? () {
                    setState(() {
                      if (isSelected) {
                        _selectedSantri.remove(santri.id);
                      } else {
                        _selectedSantri.add(santri.id);
                      }
                    });
                  }
                : null,
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'hadir':
        return Colors.green;
      case 'izin':
        return Colors.orange;
      case 'alpha':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'hadir':
        return 'Hadir';
      case 'izin':
        return 'Izin';
      case 'alpha':
        return 'Alpha';
      default:
        return 'Status';
    }
  }

  Color _getKategoriColor(String? kategori) {
    switch (kategori?.toLowerCase()) {
      case 'sholat':
        return Colors.green;
      case 'kajian':
        return Colors.blue;
      case 'tahfidz':
        return Colors.purple;
      case 'kerja bakti':
        return Colors.orange;
      case 'olahraga':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _recordAttendance(UserModel santri) async {
    if (_selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kegiatan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      // Create attendance record
      await firestore.collection('presensi').add({
        'userId': santri.id,
        'userName': santri.nama,
        'activity': _selectedActivity,
        'status': _attendanceStatus,
        'timestamp': Timestamp.fromDate(now),
        'recordedBy': AuthService.currentUserId,
        'recordedByName': 'Admin',
        'isManual': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Log activity
      await firestore.collection('activities').add({
        'type': 'manual_attendance',
        'title': 'Absensi Manual',
        'description':
            '${santri.nama} - $_selectedActivity: ${_getStatusLabel(_attendanceStatus)}',
        'userId': santri.id,
        'recordedBy': AuthService.currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Absensi ${santri.nama} berhasil dicatat (${_getStatusLabel(_attendanceStatus)})',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Send notification to dewan guru if alpha
      if (_attendanceStatus == 'alpha') {
        try {
          await MessagingHelper.sendPresensiNotificationToGuru(
            santriName: santri.nama,
            activity: _selectedActivity!,
            status: 'Alpha',
          );
        } catch (e) {
          print('Error sending notification: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkAttendance() async {
    if (_selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kegiatan terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSantri.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Absensi Massal'),
        content: Text(
          'Apakah Anda yakin ingin mencatat absensi untuk ${_selectedSantri.length} santri dengan status "${_getStatusLabel(_attendanceStatus)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(_attendanceStatus),
            ),
            child: const Text('Ya, Catat'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      final batch = firestore.batch();

      // Get santri data
      final santriList = await ref.read(santriListProvider.future);
      final selectedSantriData = santriList
          .where((santri) => _selectedSantri.contains(santri.id))
          .toList();

      // Create attendance records
      for (final santri in selectedSantriData) {
        final presensiRef = firestore.collection('presensi').doc();
        batch.set(presensiRef, {
          'userId': santri.id,
          'userName': santri.nama,
          'activity': _selectedActivity,
          'status': _attendanceStatus,
          'timestamp': Timestamp.fromDate(now),
          'recordedBy': AuthService.currentUserId,
          'recordedByName': 'Admin',
          'isManual': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Log activity
        final activityRef = firestore.collection('activities').doc();
        batch.set(activityRef, {
          'type': 'bulk_attendance',
          'title': 'Absensi Massal',
          'description':
              '${santri.nama} - $_selectedActivity: ${_getStatusLabel(_attendanceStatus)}',
          'userId': santri.id,
          'recordedBy': AuthService.currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Absensi ${_selectedSantri.length} santri berhasil dicatat',
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear selection and exit select mode
        setState(() {
          _selectedSantri.clear();
          _isSelectMode = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Clean up any resources if needed
    }
  }
}
