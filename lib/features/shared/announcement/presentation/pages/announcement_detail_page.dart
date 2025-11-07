import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/features/shared/announcement/data/models/announcement_model.dart';
import 'package:sisantri/shared/services/announcement_service.dart';

class AnnouncementDetailPage extends ConsumerStatefulWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailPage({super.key, required this.announcement});

  @override
  ConsumerState<AnnouncementDetailPage> createState() =>
      _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState
    extends ConsumerState<AnnouncementDetailPage> {
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
  }

  Future<void> _incrementViewCount() async {
    try {
      await AnnouncementService.incrementViewCount(widget.announcement.id);
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcement = widget.announcement;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E2E2E),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(context, announcement),

                  const SizedBox(height: 16),

                  // Content Section
                  _buildContentSection(context, announcement),

                  const SizedBox(height: 16),

                  // Attachment Section
                  if (announcement.lampiranUrl != null &&
                      announcement.lampiranUrl!.isNotEmpty)
                    _buildAttachmentSection(context, announcement),

                  const SizedBox(height: 16),

                  // Info Section
                  _buildInfoSection(context, announcement),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    AnnouncementModel pengumuman,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority Badge & Category
          Row(
            children: [
              if (pengumuman.isHighPriority) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.priority_high,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PENTING',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withAlpha(50),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getCategoryLabel(pengumuman.kategori),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (pengumuman.isPinned) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Disematkan',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            pengumuman.judul,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2E2E),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // Author & Date Info
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withAlpha(15),
                radius: 20,
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pengumuman.createdByName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    Text(
                      'Dipublikasikan ${DateFormat('dd MMM yyyy, HH:mm').format(pengumuman.createdAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(
    BuildContext context,
    AnnouncementModel pengumuman,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.article, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Isi Pengumuman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            pengumuman.konten,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFF2E2E2E),
            ),
          ),
        ],
      ),
    );
  }

  /// Attachment Section - Show if there's an attachment
  Widget _buildAttachmentSection(
    BuildContext context,
    AnnouncementModel pengumuman,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.attach_file, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Lampiran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _openAttachment(pengumuman.lampiranUrl!),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.insert_drive_file,
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
                          _getFileNameFromUrl(pengumuman.lampiranUrl!),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF2E2E2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ketuk untuk membuka',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Info Section - Target audience, validity period, etc.
  Widget _buildInfoSection(BuildContext context, AnnouncementModel pengumuman) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Informasi Pengumuman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target Audience
          _buildInfoItem(
            icon: Icons.people,
            label: 'Ditujukan untuk',
            value: _getTargetAudienceLabel(pengumuman),
          ),

          const Divider(height: 24),

          // Validity Period
          _buildInfoItem(
            icon: Icons.calendar_today,
            label: 'Berlaku mulai',
            value: DateFormat('dd MMMM yyyy').format(pengumuman.tanggalMulai),
          ),

          if (pengumuman.tanggalBerakhir != null) ...[
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.event_busy,
              label: 'Berakhir pada',
              value: DateFormat(
                'dd MMMM yyyy',
              ).format(pengumuman.tanggalBerakhir!),
              valueColor: pengumuman.isExpired ? Colors.red : null,
            ),
          ],

          const Divider(height: 24),

          // Last Updated
          _buildInfoItem(
            icon: Icons.update,
            label: 'Terakhir diperbarui',
            value: DateFormat(
              'dd MMM yyyy, HH:mm',
            ).format(pengumuman.updatedAt),
          ),
        ],
      ),
    );
  }

  /// Info Item Widget
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get category label in Indonesian
  String _getCategoryLabel(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'umum':
        return 'Umum';
      case 'penting':
        return 'Penting';
      case 'mendesak':
        return 'Mendesak';
      case 'akademik':
        return 'Akademik';
      case 'kegiatan':
        return 'Kegiatan';
      default:
        return kategori;
    }
  }

  /// Get target audience label
  String _getTargetAudienceLabel(AnnouncementModel pengumuman) {
    switch (pengumuman.targetAudience.toLowerCase()) {
      case 'all':
        return 'Semua pengguna';
      case 'santri':
        return 'Santri';
      case 'dewan_guru':
        return 'Dewan Guru';
      case 'kelas_tertentu':
        if (pengumuman.targetClasses.isNotEmpty) {
          return 'Kelas ${pengumuman.targetClasses.join(', ')}';
        }
        return 'Kelas tertentu';
      default:
        return pengumuman.targetAudience;
    }
  }

  /// Get filename from URL
  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
      return 'Lampiran';
    } catch (e) {
      return 'Lampiran';
    }
  }

  /// Open attachment
  void _openAttachment(String url) {
    // TODO: Implement file opening
    // You can use url_launcher package or open_file package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Membuka lampiran: $url'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
