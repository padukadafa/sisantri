import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sisantri/core/theme/app_theme.dart';

/// Model untuk FAQ
class FaqItem {
  final String question;
  final String answer;
  final String category;
  final List<String> tags;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
    required this.tags,
  });
}

/// Model untuk panduan penggunaan
class GuideItem {
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;

  const GuideItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
  });
}

/// Provider untuk daftar FAQ
final faqListProvider = StateProvider<List<FaqItem>>(
  (ref) => [
    const FaqItem(
      question: 'Bagaimana cara melakukan presensi dengan RFID?',
      answer:
          'Tempelkan kartu RFID Anda ke reader yang tersedia di lokasi kegiatan. Sistem akan otomatis mencatat kehadiran Anda. Pastikan kartu RFID sudah terdaftar di sistem.',
      category: 'Presensi',
      tags: ['rfid', 'presensi', 'kehadiran'],
    ),
    const FaqItem(
      question: 'Kenapa kartu RFID saya tidak terbaca?',
      answer:
          'Beberapa kemungkinan: 1) Kartu belum didaftarkan, 2) Kartu rusak atau kotor, 3) Reader bermasalah. Hubungi admin untuk bantuan lebih lanjut.',
      category: 'RFID',
      tags: ['rfid', 'error', 'troubleshooting'],
    ),
    const FaqItem(
      question: 'Bagaimana cara melihat jadwal kegiatan?',
      answer:
          'Buka menu Kalender di halaman utama. Anda dapat melihat jadwal harian, mingguan, dan bulanan. Tap pada tanggal untuk melihat detail kegiatan.',
      category: 'Jadwal',
      tags: ['jadwal', 'kalender', 'kegiatan'],
    ),
    const FaqItem(
      question: 'Bagaimana sistem poin bekerja?',
      answer:
          'Poin diberikan berdasarkan kehadiran dan partisipasi dalam kegiatan. Presensi sholat: 10 poin, Kajian: 15 poin, Olahraga: 5 poin, Kegiatan umum: 8 poin.',
      category: 'Poin',
      tags: ['poin', 'ranking', 'gamifikasi'],
    ),
    const FaqItem(
      question: 'Bagaimana cara mengubah password?',
      answer:
          'Masuk ke Pengaturan > Keamanan > Ubah Password. Masukkan password lama dan password baru. Password minimal 8 karakter dengan kombinasi huruf dan angka.',
      category: 'Akun',
      tags: ['password', 'keamanan', 'akun'],
    ),
    const FaqItem(
      question: 'Saya lupa password, bagaimana cara reset?',
      answer:
          'Di halaman login, tap "Lupa Password" dan masukkan email Anda. Kami akan mengirimkan link reset password ke email tersebut.',
      category: 'Akun',
      tags: ['password', 'reset', 'lupa'],
    ),
    const FaqItem(
      question: 'Bagaimana cara melihat ranking saya?',
      answer:
          'Buka menu Leaderboard untuk melihat ranking Anda. Tersedia ranking mingguan dan bulanan berdasarkan total poin yang dikumpulkan.',
      category: 'Ranking',
      tags: ['ranking', 'leaderboard', 'kompetisi'],
    ),
    const FaqItem(
      question: 'Notifikasi tidak muncul, bagaimana mengatasinya?',
      answer:
          'Pastikan notifikasi diaktifkan di Pengaturan > Notifikasi. Juga cek pengaturan notifikasi di sistem Android/iOS untuk aplikasi SiSantri.',
      category: 'Notifikasi',
      tags: ['notifikasi', 'pengaturan', 'push'],
    ),
  ],
);

/// Provider untuk daftar panduan
final guideListProvider = StateProvider<List<GuideItem>>(
  (ref) => [
    const GuideItem(
      title: 'Setup Kartu RFID',
      description: 'Panduan lengkap untuk mendaftarkan kartu RFID Anda',
      icon: Icons.nfc,
      steps: [
        'Hubungi admin pondok untuk mendapatkan kartu RFID',
        'Berikan informasi pribadi (nama, kelas, nomor santri)',
        'Admin akan mendaftarkan kartu RFID ke sistem',
        'Test kartu dengan menempelkan ke reader',
        'Jika berhasil, Anda bisa menggunakan kartu untuk presensi',
      ],
    ),
    const GuideItem(
      title: 'Cara Presensi',
      description: 'Langkah-langkah melakukan presensi kegiatan',
      icon: Icons.how_to_reg,
      steps: [
        'Pastikan Anda sudah memiliki kartu RFID yang terdaftar',
        'Datang ke lokasi kegiatan sesuai jadwal',
        'Cari reader RFID di lokasi tersebut',
        'Tempelkan kartu RFID ke reader hingga berbunyi beep',
        'Presensi berhasil jika lampu reader menyala hijau',
        'Cek konfirmasi di aplikasi mobile',
      ],
    ),
    const GuideItem(
      title: 'Melihat Jadwal',
      description: 'Cara menggunakan fitur kalender dan jadwal',
      icon: Icons.calendar_today,
      steps: [
        'Buka aplikasi SiSantri',
        'Tap menu "Kalender" di halaman utama',
        'Pilih tanggal untuk melihat kegiatan hari itu',
        'Gunakan filter kategori untuk menyaring kegiatan',
        'Tap pada kegiatan untuk melihat detail lengkap',
        'Set reminder untuk kegiatan penting',
      ],
    ),
    const GuideItem(
      title: 'Mengumpulkan Poin',
      description: 'Tips dan strategi mengumpulkan poin maksimal',
      icon: Icons.stars,
      steps: [
        'Hadir tepat waktu di setiap kegiatan wajib',
        'Ikuti kegiatan kajian dan olahraga (poin tambahan)',
        'Pertahankan streak kehadiran untuk bonus poin',
        'Ikuti kegiatan khusus dan gotong royong',
        'Raih achievement untuk poin bonus besar',
        'Cek leaderboard secara rutin untuk motivasi',
      ],
    ),
    const GuideItem(
      title: 'Mengelola Notifikasi',
      description: 'Cara mengatur notifikasi sesuai kebutuhan',
      icon: Icons.notifications,
      steps: [
        'Masuk ke menu Pengaturan',
        'Pilih "Notifikasi"',
        'Aktifkan/nonaktifkan jenis notifikasi yang diinginkan',
        'Atur pengingat untuk kegiatan wajib',
        'Sesuaikan waktu pengingat (misal 30 menit sebelum)',
        'Test notifikasi untuk memastikan berfungsi',
      ],
    ),
  ],
);

/// Provider untuk search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider untuk kategori filter
final categoryFilterProvider = StateProvider<String>((ref) => 'Semua');

/// Provider untuk expanded FAQ items
final expandedFaqProvider = StateProvider<Set<int>>((ref) => <int>{});

/// Halaman Bantuan dan FAQ
class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan & FAQ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'FAQ'),
                  Tab(text: 'Panduan'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildFaqTab(context, ref),
                  _buildGuideTab(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTab(BuildContext context, WidgetRef ref) {
    final faqList = ref.watch(faqListProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);
    final expandedFaqs = ref.watch(expandedFaqProvider);

    // Filter FAQ berdasarkan search dan kategori
    final filteredFaqs = faqList.where((faq) {
      final matchesSearch =
          searchQuery.isEmpty ||
          faq.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
          faq.answer.toLowerCase().contains(searchQuery.toLowerCase()) ||
          faq.tags.any(
            (tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()),
          );

      final matchesCategory =
          categoryFilter == 'Semua' || faq.category == categoryFilter;

      return matchesSearch && matchesCategory;
    }).toList();

    // Get unique categories
    final categories = ['Semua', ...faqList.map((faq) => faq.category).toSet()];

    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: TextField(
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            decoration: InputDecoration(
              hintText: 'Cari pertanyaan...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // Category Filter
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = categoryFilter == category;

              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(category),
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey[300]!,
                  ),
                  onSelected: (selected) {
                    ref.read(categoryFilterProvider.notifier).state = category;
                  },
                ),
              );
            },
          ),
        ),

        // FAQ List
        Expanded(
          child: filteredFaqs.isEmpty
              ? _buildEmptyState('FAQ')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredFaqs.length,
                  itemBuilder: (context, index) {
                    final faq = filteredFaqs[index];
                    final isExpanded = expandedFaqs.contains(index);

                    return _buildFaqCard(context, ref, faq, index, isExpanded);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGuideTab(BuildContext context, WidgetRef ref) {
    final guideList = ref.watch(guideListProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guideList.length,
      itemBuilder: (context, index) {
        final guide = guideList[index];
        return _buildGuideCard(context, guide);
      },
    );
  }

  Widget _buildFaqCard(
    BuildContext context,
    WidgetRef ref,
    FaqItem faq,
    int index,
    bool isExpanded,
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
        onTap: () {
          final expandedSet = ref.read(expandedFaqProvider);
          if (expandedSet.contains(index)) {
            ref.read(expandedFaqProvider.notifier).state = Set.from(expandedSet)
              ..remove(index);
          } else {
            ref.read(expandedFaqProvider.notifier).state = Set.from(expandedSet)
              ..add(index);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      faq.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                faq.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),

              if (isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                if (faq.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: faq.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context, GuideItem guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        onTap: () => _showGuideDetail(context, guide),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(guide.icon, color: AppTheme.primaryColor, size: 24),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      guide.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${guide.steps.length} langkah',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'FAQ' ? Icons.help_outline : Icons.menu_book_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada $type ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah kata kunci pencarian\natau filter kategori',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showGuideDetail(BuildContext context, GuideItem guide) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(guide.icon, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Expanded(child: Text(guide.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guide.description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Langkah-langkah:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...guide.steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(step, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Panduan "${guide.title}" disimpan')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
