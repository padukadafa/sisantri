import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sisantri/shared/models/user_model.dart';
import 'package:sisantri/shared/services/nfc_service.dart';

/// Dialog untuk mengelola RFID card user
class RfidManagementDialog extends StatefulWidget {
  final UserModel user;

  const RfidManagementDialog({super.key, required this.user});

  @override
  RfidManagementDialogState createState() => RfidManagementDialogState();
}

class RfidManagementDialogState extends State<RfidManagementDialog> {
  final _nfcService = NfcService();
  final _cardIdController = TextEditingController();

  bool _isScanning = false;
  bool _isLoading = false;
  bool _nfcAvailable = false;
  String? _scannedCardId;

  @override
  void initState() {
    super.initState();
    _cardIdController.text = widget.user.rfidCardId ?? '';
    _checkNfcAvailability();
  }

  @override
  void dispose() {
    _cardIdController.dispose();
    _nfcService.stopSession();
    super.dispose();
  }

  Future<void> _checkNfcAvailability() async {
    final isAvailable = await _nfcService.isNfcAvailable();
    if (mounted) {
      setState(() {
        _nfcAvailable = isAvailable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Kelola RFID - ${widget.user.nama}'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current RFID Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.user.hasRfidSetup
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.user.hasRfidSetup
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.user.hasRfidSetup ? Icons.nfc : Icons.nfc_outlined,
                      color: widget.user.hasRfidSetup
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status RFID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.user.hasRfidSetup
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          Text(
                            widget.user.hasRfidSetup
                                ? 'Kartu: ${_nfcService.formatCardId(widget.user.rfidCardId!)}'
                                : 'Belum ada kartu yang di-assign',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // NFC Availability Warning
              if (!_nfcAvailable)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'NFC tidak tersedia pada perangkat ini. Anda dapat memasukkan ID kartu secara manual.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Manual Input
              TextField(
                controller: _cardIdController,
                decoration: InputDecoration(
                  labelText: 'ID Kartu RFID',
                  hintText: 'Masukkan ID kartu atau scan kartu',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.credit_card),
                  suffixIcon: _cardIdController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _cardIdController.clear();
                            setState(() {
                              _scannedCardId = null;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),

              // NFC Scan Button
              if (_nfcAvailable)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isScanning || _isLoading ? null : _startNfcScan,
                    icon: _isScanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.nfc),
                    label: Text(
                      _isScanning ? 'Scanning...' : 'Scan Kartu RFID',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),

              if (_scannedCardId != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kartu berhasil discan: ${_nfcService.formatCardId(_scannedCardId!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text(
                'Catatan: Pastikan ID kartu benar sebelum menyimpan. ID kartu yang salah dapat menyebabkan masalah pada sistem presensi.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        if (widget.user.hasRfidSetup)
          TextButton(
            onPressed: _isLoading ? null : _removeRfidCard,
            child: const Text(
              'Hapus Kartu',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ElevatedButton(
          onPressed: _isLoading || _cardIdController.text.trim().isEmpty
              ? null
              : _saveRfidCard,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.user.hasRfidSetup ? 'Update' : 'Simpan'),
        ),
      ],
    );
  }

  Future<void> _startNfcScan() async {
    setState(() {
      _isScanning = true;
    });

    try {
      await _nfcService.startSession(
        alertMessage:
            'Tempelkan kartu RFID pada perangkat untuk membaca ID kartu',
        onCardDetected: (cardId) {
          if (mounted) {
            setState(() {
              _cardIdController.text = cardId;
              _scannedCardId = cardId;
              _isScanning = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isScanning = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memulai scan NFC: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveRfidCard() async {
    final cardId = _cardIdController.text.trim().toUpperCase();

    if (cardId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID kartu tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_nfcService.isValidCardId(cardId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format ID kartu tidak valid'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if card is already assigned to another user
      final existingCard = await FirebaseFirestore.instance
          .collection('users')
          .where('rfidCardId', isEqualTo: cardId)
          .get();

      if (existingCard.docs.isNotEmpty) {
        final existingUser = existingCard.docs.first.data();
        if (existingUser['id'] != widget.user.id) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Kartu sudah di-assign ke user: ${existingUser['nama']}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Update user with RFID card
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update({
            'rfidCardId': cardId,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Log activity
      await FirebaseFirestore.instance.collection('activities').add({
        'type': 'rfid_assigned',
        'title': 'RFID Card Assigned',
        'description':
            'Kartu RFID ${_nfcService.formatCardId(cardId)} berhasil di-assign ke ${widget.user.nama}',
        'timestamp': FieldValue.serverTimestamp(),
        'recordedBy': 'Admin',
      });

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kartu RFID berhasil ${widget.user.hasRfidSetup ? 'diupdate' : 'disimpan'} untuk ${widget.user.nama}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeRfidCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kartu RFID'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kartu RFID dari user "${widget.user.nama}"?\n\nUser tidak akan bisa melakukan presensi otomatis sampai kartu di-assign ulang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.id)
            .update({
              'rfidCardId': FieldValue.delete(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

        // Log activity
        await FirebaseFirestore.instance.collection('activities').add({
          'type': 'rfid_removed',
          'title': 'RFID Card Removed',
          'description': 'Kartu RFID dihapus dari user ${widget.user.nama}',
          'timestamp': FieldValue.serverTimestamp(),
          'recordedBy': 'Admin',
        });

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Kartu RFID berhasil dihapus dari ${widget.user.nama}',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
