import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

/// Model untuk dokumen pribadi
class PersonalDocument {
  final String id;
  final String title;
  final String type; // 'ktp', 'kk', 'akta', 'ijazah', 'sertifikat', 'other'
  final String fileName;
  final String? filePath;
  final DateTime uploadDate;
  final String status; // 'verified', 'pending', 'rejected'
  final String? notes;
  final int fileSize; // in bytes

  const PersonalDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.fileName,
    this.filePath,
    required this.uploadDate,
    this.status = 'pending',
    this.notes,
    required this.fileSize,
  });

  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  IconData get icon {
    switch (type) {
      case 'ktp':
        return Icons.credit_card;
      case 'kk':
        return Icons.family_restroom;
      case 'akta':
        return Icons.article;
      case 'ijazah':
        return Icons.school;
      case 'sertifikat':
        return Icons.emoji_events;
      default:
        return Icons.description;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'verified':
        return 'Terverifikasi';
      case 'pending':
        return 'Menunggu Verifikasi';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Unknown';
    }
  }
}

/// Model untuk informasi pribadi
class PersonalInfo {
  final String fullName;
  final String nickname;
  final String idNumber;
  final DateTime birthDate;
  final String birthPlace;
  final String gender;
  final String religion;
  final String nationality;
  final String address;
  final String phoneNumber;
  final String email;
  final String emergencyContact;
  final String emergencyPhone;
  final String bloodType;
  final String? allergies;
  final String? medicalHistory;
  final String education;
  final String? skills;
  final String? hobbies;

  const PersonalInfo({
    required this.fullName,
    required this.nickname,
    required this.idNumber,
    required this.birthDate,
    required this.birthPlace,
    required this.gender,
    required this.religion,
    required this.nationality,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.bloodType,
    this.allergies,
    this.medicalHistory,
    required this.education,
    this.skills,
    this.hobbies,
  });

  String get formattedBirthDate {
    return '${birthDate.day}/${birthDate.month}/${birthDate.year}';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

/// Providers
final personalInfoProvider = StateProvider<PersonalInfo>((ref) {
  return PersonalInfo(
    fullName: 'Ahmad Santri Teladan',
    nickname: 'Ahmad',
    idNumber: '3201234567890123',
    birthDate: DateTime(2000, 5, 15),
    birthPlace: 'Jakarta',
    gender: 'Laki-laki',
    religion: 'Islam',
    nationality: 'Indonesia',
    address: 'Jl. Merdeka No. 123, Jakarta Pusat',
    phoneNumber: '+62812345678',
    email: 'ahmad.santri@example.com',
    emergencyContact: 'Bapak Ahmad',
    emergencyPhone: '+62811234567',
    bloodType: 'O+',
    allergies: 'Seafood, Debu',
    medicalHistory: 'Tidak ada riwayat penyakit serius',
    education: 'SMA Negeri 1 Jakarta',
    skills: 'Tahfidz Al-Quran, Komputer, Bahasa Arab',
    hobbies: 'Membaca, Olahraga, Fotografi',
  );
});

final personalDocumentsProvider = StateProvider<List<PersonalDocument>>((ref) {
  final now = DateTime.now();
  return [
    PersonalDocument(
      id: '1',
      title: 'Kartu Tanda Penduduk',
      type: 'ktp',
      fileName: 'KTP_Ahmad_Santri.pdf',
      uploadDate: now.subtract(const Duration(days: 30)),
      status: 'verified',
      fileSize: 1024 * 500, // 500KB
    ),
    PersonalDocument(
      id: '2',
      title: 'Kartu Keluarga',
      type: 'kk',
      fileName: 'KK_Keluarga_Ahmad.pdf',
      uploadDate: now.subtract(const Duration(days: 25)),
      status: 'verified',
      fileSize: 1024 * 750, // 750KB
    ),
    PersonalDocument(
      id: '3',
      title: 'Ijazah SMA',
      type: 'ijazah',
      fileName: 'Ijazah_SMA_Ahmad.pdf',
      uploadDate: now.subtract(const Duration(days: 20)),
      status: 'pending',
      fileSize: 1024 * 1024 * 2, // 2MB
    ),
    PersonalDocument(
      id: '4',
      title: 'Sertifikat Tahfidz',
      type: 'sertifikat',
      fileName: 'Sertifikat_Tahfidz_Ahmad.jpg',
      uploadDate: now.subtract(const Duration(days: 10)),
      status: 'pending',
      fileSize: 1024 * 800, // 800KB
    ),
  ];
});

/// Halaman Data Pribadi dan Dokumentasi
class PersonalDataPage extends ConsumerWidget {
  const PersonalDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Data Pribadi'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppTheme.primaryColor,
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Informasi'),
              Tab(icon: Icon(Icons.folder), text: 'Dokumen'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data pribadi dikelola oleh admin pondok'),
                  ),
                );
              },
              tooltip: 'Info Data',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(context, ref),
            _buildDocumentsTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context, WidgetRef ref) {
    final personalInfo = ref.watch(personalInfoProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          _buildHeaderCard(personalInfo),

          const SizedBox(height: 16),

          // Personal Information
          _buildSectionCard('Informasi Pribadi', Icons.person, [
            _buildInfoTile('Nama Lengkap', personalInfo.fullName),
            _buildInfoTile('Nama Panggilan', personalInfo.nickname),
            _buildInfoTile('NIK', personalInfo.idNumber),
            _buildInfoTile(
              'Tempat, Tanggal Lahir',
              '${personalInfo.birthPlace}, ${personalInfo.formattedBirthDate}',
            ),
            _buildInfoTile('Umur', '${personalInfo.age} tahun'),
            _buildInfoTile('Jenis Kelamin', personalInfo.gender),
            _buildInfoTile('Agama', personalInfo.religion),
            _buildInfoTile('Kewarganegaraan', personalInfo.nationality),
          ]),

          const SizedBox(height: 16),

          // Contact Information
          _buildSectionCard('Informasi Kontak', Icons.contact_phone, [
            _buildInfoTile('Alamat', personalInfo.address),
            _buildInfoTile('Nomor HP', personalInfo.phoneNumber),
            _buildInfoTile('Email', personalInfo.email),
            _buildInfoTile('Kontak Darurat', personalInfo.emergencyContact),
            _buildInfoTile('HP Kontak Darurat', personalInfo.emergencyPhone),
          ]),

          const SizedBox(height: 16),

          // Medical Information
          _buildSectionCard('Informasi Kesehatan', Icons.medical_services, [
            _buildInfoTile('Golongan Darah', personalInfo.bloodType),
            if (personalInfo.allergies != null)
              _buildInfoTile('Alergi', personalInfo.allergies!),
            if (personalInfo.medicalHistory != null)
              _buildInfoTile('Riwayat Kesehatan', personalInfo.medicalHistory!),
          ]),

          const SizedBox(height: 16),

          // Additional Information
          _buildSectionCard('Informasi Tambahan', Icons.info, [
            _buildInfoTile('Pendidikan Terakhir', personalInfo.education),
            if (personalInfo.skills != null)
              _buildInfoTile('Keahlian', personalInfo.skills!),
            if (personalInfo.hobbies != null)
              _buildInfoTile('Hobi', personalInfo.hobbies!),
          ]),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(BuildContext context, WidgetRef ref) {
    final documents = ref.watch(personalDocumentsProvider);
    final verifiedCount = documents.where((d) => d.status == 'verified').length;
    final pendingCount = documents.where((d) => d.status == 'pending').length;

    return Column(
      children: [
        // Statistics Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Terverifikasi',
                  '$verifiedCount',
                  Icons.verified,
                  Colors.green,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem(
                  'Pending',
                  '$pendingCount',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '${documents.length}',
                  Icons.folder,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Documents List
        Expanded(
          child: documents.isEmpty
              ? _buildEmptyDocumentsState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return _buildDocumentCard(context, ref, document);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(PersonalInfo info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${info.age} tahun • ${info.birthPlace}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        info.bloodType,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        info.gender,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(' : '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    WidgetRef ref,
    PersonalDocument document,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDocumentDetail(context, document),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  document.icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      document.fileName,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: document.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            document.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: document.statusColor,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          document.formattedFileSize,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'view') {
                    _showDocumentDetail(context, document);
                  } else if (value == 'download') {
                    _downloadDocument(context, document);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, ref, document);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 16),
                        SizedBox(width: 8),
                        Text('Lihat'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 8),
                        Text('Download'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDocumentsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada dokumen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload dokumen pribadi Anda\nuntuk verifikasi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  void _showDocumentDetail(BuildContext context, PersonalDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(document.icon, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Expanded(child: Text(document.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Nama File', document.fileName),
            _buildDetailRow('Ukuran', document.formattedFileSize),
            _buildDetailRow(
              'Upload',
              document.uploadDate.toString().split(' ')[0],
            ),
            _buildDetailRow('Status', document.statusLabel),
            if (document.notes != null)
              _buildDetailRow('Catatan', document.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (document.status == 'verified')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _downloadDocument(context, document);
              },
              child: const Text('Download'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _downloadDocument(BuildContext context, PersonalDocument document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mengunduh ${document.fileName}...')),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    PersonalDocument document,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dokumen'),
        content: Text('Apakah Anda yakin ingin menghapus ${document.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final currentDocs = ref.read(personalDocumentsProvider);
              final updatedDocs = currentDocs
                  .where((d) => d.id != document.id)
                  .toList();
              ref.read(personalDocumentsProvider.notifier).state = updatedDocs;

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${document.title} telah dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
