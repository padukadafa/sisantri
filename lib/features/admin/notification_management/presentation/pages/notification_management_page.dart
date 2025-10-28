import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisantri/shared/helpers/messaging_helper.dart';
import 'package:sisantri/shared/services/notification_service.dart';
import 'package:sisantri/core/theme/app_theme.dart';

/// Page untuk mengelola pengiriman notifikasi (khusus admin/dewan guru)
class NotificationManagementPage extends ConsumerStatefulWidget {
  const NotificationManagementPage({super.key});

  @override
  ConsumerState<NotificationManagementPage> createState() =>
      _NotificationManagementPageState();
}

class _NotificationManagementPageState
    extends ConsumerState<NotificationManagementPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedRecipient = 'santri';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Notifikasi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsCard(),
            const SizedBox(height: 24),
            _buildSendNotificationCard(),
            const SizedBox(height: 24),
            _buildQuickActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Statistik Device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, int>>(
              future: MessagingHelper.getDeviceTokenStatistics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final stats = snapshot.data ?? {};
                return Row(
                  children: [
                    _buildStatItem('Santri', stats['santri'] ?? 0, Colors.blue),
                    _buildStatItem(
                      'Dewan Guru',
                      stats['dewan_guru'] ?? 0,
                      Colors.green,
                    ),
                    _buildStatItem('Admin', stats['admin'] ?? 0, Colors.orange),
                    _buildStatItem(
                      'Total',
                      stats['total'] ?? 0,
                      AppTheme.primaryColor,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendNotificationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.send, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  const Text(
                    'Kirim Notifikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recipient selector
              const Text(
                'Penerima:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRecipient,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'santri',
                    child: Text('Semua Santri'),
                  ),
                  DropdownMenuItem(
                    value: 'dewan_guru',
                    child: Text('Semua Dewan Guru'),
                  ),
                  DropdownMenuItem(value: 'all', child: Text('Semua User')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRecipient = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Title field
              const Text(
                'Judul:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                  hintText: 'Masukkan judul notifikasi',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Message field
              const Text(
                'Pesan:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                  hintText: 'Masukkan isi pesan notifikasi',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Pesan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Mengirim...'),
                          ],
                        )
                      : const Text(
                          'Kirim Notifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Aksi Cepat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuickActionButton(
              'Pengumuman Kegiatan',
              'Kirim pengumuman kegiatan kepada semua santri',
              Icons.event,
              Colors.blue,
              () => _sendQuickNotification(
                'Pengumuman Kegiatan',
                'Ada kegiatan baru yang akan segera dimulai. Silakan berkumpul di aula utama.',
                'santri',
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              'Notifikasi Darurat',
              'Kirim notifikasi darurat kepada semua user',
              Icons.warning,
              Colors.red,
              () => _sendEmergencyNotification(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.send, color: color),
        onTap: onTap,
      ),
    );
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final message = _messageController.text.trim();

      switch (_selectedRecipient) {
        case 'santri':
          await MessagingHelper.sendPengumumanToSantri(
            title: title,
            message: message,
          );
          break;
        case 'dewan_guru':
          await NotificationService.sendNotificationToAllDewaGuru(
            title: title,
            body: message,
          );
          break;
        case 'all':
          await MessagingHelper.sendEmergencyNotification(
            title: title,
            message: message,
          );
          break;
      }

      // Clear form
      _titleController.clear();
      _messageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Notifikasi berhasil dikirim'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendQuickNotification(
    String title,
    String message,
    String recipient,
  ) async {
    try {
      switch (recipient) {
        case 'santri':
          await MessagingHelper.sendPengumumanToSantri(
            title: title,
            message: message,
          );
          break;
        case 'dewan_guru':
          await NotificationService.sendNotificationToAllDewaGuru(
            title: title,
            body: message,
          );
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('$title berhasil dikirim'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
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

  Future<void> _sendEmergencyNotification() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Notifikasi Darurat'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul darurat',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Pesan darurat',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Kirim Darurat',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true &&
        titleController.text.isNotEmpty &&
        messageController.text.isNotEmpty) {
      try {
        await MessagingHelper.sendEmergencyNotification(
          title: titleController.text.trim(),
          message: messageController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Notifikasi darurat berhasil dikirim'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
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

    titleController.dispose();
    messageController.dispose();
  }
}
