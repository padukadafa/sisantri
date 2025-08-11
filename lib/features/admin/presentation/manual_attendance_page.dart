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

/// Provider untuk status absensi santri berdasarkan activity yang dipilih
final attendanceStatusProvider =
    FutureProvider.family<Map<String, String>, String?>((
      ref,
      activityId,
    ) async {
      if (activityId == null) return {};

      try {
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = DateTime(
          today.year,
          today.month,
          today.day,
          23,
          59,
          59,
        );

        final snapshot = await FirebaseFirestore.instance
            .collection('presensi')
            .where('activity', isEqualTo: activityId)
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where(
              'timestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
            )
            .get();

        final statusMap = <String, String>{};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          statusMap[data['userId']] = data['status'];
        }

        return statusMap;
      } catch (e) {
        print('Error loading attendance status: $e');
        return {};
      }
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

  // Track individual attendance status for each santri
  final Map<String, String> _santriAttendanceStatus = {};

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
    final attendanceStatusAsync = ref.watch(
      attendanceStatusProvider(_selectedActivity),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Manual'),
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
              data: (santriList) {
                return attendanceStatusAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildSantriList(santriList, {}),
                  data: (statusMap) => _buildSantriList(santriList, statusMap),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectMode && _selectedSantri.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _bulkAttendance,
              icon: const Icon(Icons.check),

              label: Text(
                '${_selectedSantri.length}',
                style: TextStyle(fontSize: 18),
              ),
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
              loading: () => const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: 56,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Error loading activities: $error',
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (activities) {
                if (activities.isEmpty) {
                  return Container(
                    height: 56,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Tidak ada kegiatan tersedia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: _selectedActivity,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.event),
                    ),
                    hint: const Text('Pilih dari kegiatan tersedia'),
                    isExpanded: true,
                    items: activities.map((jadwal) {
                      return DropdownMenuItem<String>(
                        value: jadwal.id,
                        child: Container(
                          width: double.infinity,
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
                                    color: _getKategoriColor(
                                      jadwal.kategori.value,
                                    ),
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
                        // Clear local status when activity changes
                        _santriAttendanceStatus.clear();
                      });
                      // Refresh attendance status provider
                      if (value != null) {
                        ref.invalidate(attendanceStatusProvider(value));
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getKategoriColor(String? kategori) {
    switch (kategori?.toLowerCase()) {
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

  Widget _buildSantriList(
    List<UserModel> santriList,
    Map<String, String> existingStatusMap,
  ) {
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
                : SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<String>(
                      value:
                          _santriAttendanceStatus[santri.id] ??
                          existingStatusMap[santri.id] ??
                          'alpha',
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'alpha',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red, size: 16),
                              SizedBox(width: 4),
                              Text('Alpha', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'hadir',
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text('Hadir', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'izin',
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange, size: 16),
                              SizedBox(width: 4),
                              Text('Izin', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                      onChanged: _selectedActivity == null
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _santriAttendanceStatus[santri.id] = value;
                                });
                                // Auto record attendance when status changes
                                _recordAttendance(santri, value);
                              }
                            },
                    ),
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

  Future<void> _recordAttendance(
    UserModel santri,
    String attendanceStatus,
  ) async {
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
        'status': attendanceStatus,
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
            '${santri.nama} - $_selectedActivity: ${_getStatusLabel(attendanceStatus)}',
        'userId': santri.id,
        'recordedBy': AuthService.currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Absensi ${santri.nama} berhasil dicatat (${_getStatusLabel(attendanceStatus)})',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh attendance status provider to reflect changes
        ref.invalidate(attendanceStatusProvider(_selectedActivity));
      }

      // Send notification to dewan guru if alpha
      if (attendanceStatus == 'alpha') {
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

    // Show dialog to select bulk status
    final bulkStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Status untuk Semua'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih status kehadiran untuk ${_selectedSantri.length} santri yang dipilih:',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Status Kehadiran',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'alpha',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Alpha'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'hadir',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Hadir'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'izin',
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text('Izin'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (bulkStatus == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Absensi Massal'),
        content: Text(
          'Apakah Anda yakin ingin mencatat absensi untuk ${_selectedSantri.length} santri dengan status "${_getStatusLabel(bulkStatus)}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(bulkStatus),
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
          'status': bulkStatus,
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
              '${santri.nama} - $_selectedActivity: ${_getStatusLabel(bulkStatus)}',
          'userId': santri.id,
          'recordedBy': AuthService.currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Update local status
        _santriAttendanceStatus[santri.id] = bulkStatus;
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

        // Refresh attendance status provider to reflect changes
        ref.invalidate(attendanceStatusProvider(_selectedActivity));
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
}
