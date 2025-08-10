import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/user_model.dart';

/// Provider untuk mendapatkan semua santri
final allSantriProvider = FutureProvider<List<UserModel>>((ref) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'santri')
        .orderBy('nama')
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  } catch (e) {
    throw Exception('Error loading santri: $e');
  }
});

/// Halaman manajemen RFID untuk admin
class RfidManagementPage extends ConsumerStatefulWidget {
  const RfidManagementPage({super.key});

  @override
  ConsumerState<RfidManagementPage> createState() => _RfidManagementPageState();
}

class _RfidManagementPageState extends ConsumerState<RfidManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen RFID'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari santri...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: ref
                .watch(allSantriProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(allSantriProvider),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                  data: (santriList) {
                    // Filter santri berdasarkan search query
                    final filteredSantri = santriList.where((santri) {
                      return santri.nama.toLowerCase().contains(_searchQuery) ||
                          santri.email.toLowerCase().contains(_searchQuery) ||
                          (santri.rfidCardId?.toLowerCase().contains(
                                _searchQuery,
                              ) ??
                              false);
                    }).toList();

                    if (filteredSantri.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Belum ada data santri'
                                  : 'Tidak ada santri yang sesuai pencarian',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSantri.length,
                      itemBuilder: (context, index) {
                        final santri = filteredSantri[index];
                        return _buildSantriCard(santri);
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSantriCard(UserModel santri) {
    final hasRfid = santri.hasRfidSetup;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasRfid ? Colors.green[200]! : Colors.orange[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama dan status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: hasRfid
                      ? Colors.green[100]
                      : Colors.orange[100],
                  child: Icon(
                    hasRfid ? Icons.contactless : Icons.contactless_outlined,
                    color: hasRfid ? Colors.green[600] : Colors.orange[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        santri.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        santri.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hasRfid ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasRfid ? Colors.green[200]! : Colors.orange[200]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hasRfid ? 'RFID Aktif' : 'Perlu Setup',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: hasRfid ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // RFID Card ID Section
            Row(
              children: [
                Icon(Icons.credit_card, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'RFID Card ID:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    santri.rfidCardId ?? 'Belum di-setup',
                    style: TextStyle(
                      fontSize: 14,
                      color: hasRfid ? Colors.grey[800] : Colors.orange[600],
                      fontWeight: hasRfid ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRfidSetupDialog(santri),
                    icon: Icon(hasRfid ? Icons.edit : Icons.add, size: 16),
                    label: Text(hasRfid ? 'Edit RFID' : 'Setup RFID'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      side: BorderSide(color: Theme.of(context).primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (hasRfid) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRemoveRfidDialog(santri),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red[600],
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRfidSetupDialog(UserModel santri) {
    final TextEditingController rfidController = TextEditingController(
      text: santri.rfidCardId ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(santri.hasRfidSetup ? 'Edit RFID Card' : 'Setup RFID Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Santri: ${santri.nama}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rfidController,
              decoration: const InputDecoration(
                labelText: 'RFID Card ID',
                hintText: 'Masukkan ID kartu RFID',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 8),
            Text(
              'Contoh: A1B2C3D4, 12345678',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final rfidId = rfidController.text.trim().toUpperCase();
              if (rfidId.isNotEmpty) {
                await _updateRfidCard(santri.id, rfidId);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showRemoveRfidDialog(UserModel santri) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus RFID Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda yakin ingin menghapus RFID card untuk:'),
            const SizedBox(height: 8),
            Text(
              santri.nama,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'RFID: ${santri.rfidCardId}',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Santri tidak akan bisa mengakses aplikasi setelah RFID dihapus.',
                      style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateRfidCard(santri.id, null);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateRfidCard(String userId, String? rfidCardId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'rfidCardId': rfidCardId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh data
      final _ = ref.refresh(allSantriProvider);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              rfidCardId != null
                  ? 'RFID berhasil disimpan'
                  : 'RFID berhasil dihapus',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
