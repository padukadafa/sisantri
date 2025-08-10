import 'package:cloud_firestore/cloud_firestore.dart';

/// Service untuk membuat dummy data untuk testing
class DummyDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Buat dummy data lengkap
  static Future<void> createAllDummyData() async {
    try {
      await createDummyUsers();
      await createDummyJadwalPengajian();
      await createDummyJadwalKegiatan();
      await createDummyPengumuman();
      print('✅ Semua dummy data berhasil dibuat');
    } catch (e) {
      print('❌ Error membuat dummy data: $e');
    }
  }

  /// Buat dummy users
  static Future<void> createDummyUsers() async {
    final users = [
      // Admin
      {
        'nama': 'Admin SiSantri',
        'email': 'admin@sisantri.com',
        'role': 'admin',
        'poin': 0,
        'fotoProfil': null,
        'statusAktif': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      // Santri
      {
        'nama': 'Ahmad Fadli',
        'email': 'ahmad.fadli@email.com',
        'role': 'santri',
        'poin': 85,
        'fotoProfil': null,
        'statusAktif': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'nama': 'Muhammad Rizki',
        'email': 'muhammad.rizki@email.com',
        'role': 'santri',
        'poin': 92,
        'fotoProfil': null,
        'statusAktif': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'nama': 'Abdul Rahman',
        'email': 'abdul.rahman@email.com',
        'role': 'santri',
        'poin': 78,
        'fotoProfil': null,
        'statusAktif': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'nama': 'Yusuf Hakim',
        'email': 'yusuf.hakim@email.com',
        'role': 'santri',
        'poin': 95,
        'fotoProfil': null,
        'statusAktif': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'nama': 'Ali Akbar',
        'email': 'ali.akbar@email.com',
        'role': 'santri',
        'poin': 67,
        'fotoProfil': null,
        'statusAktif': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final user in users) {
      await _firestore.collection('users').add(user);
    }

    print('✅ Dummy users created');
  }

  /// Buat dummy jadwal pengajian
  static Future<void> createDummyJadwalPengajian() async {
    final now = DateTime.now();
    final jadwalList = [
      {
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 1))),
        'tema': 'Akhlak dalam Islam',
        'pemateri': 'Ustadz Ahmad Syarif',
        'lokasi': 'Masjid Al-Awwabin',
        'deskripsi':
            'Pembahasan mengenai pentingnya akhlak mulia dalam kehidupan sehari-hari menurut ajaran Islam.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 3))),
        'tema': 'Fiqih Shalat',
        'pemateri': 'Ustadz Muhammad Iqbal',
        'lokasi': 'Aula Pondok',
        'deskripsi':
            'Tata cara shalat yang benar sesuai dengan sunnah Rasulullah SAW.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 5))),
        'tema': 'Sejarah Islam',
        'pemateri': 'Ustadz Abdullah Hakim',
        'lokasi': 'Ruang Kelas A',
        'deskripsi':
            'Mempelajari sejarah perkembangan Islam dari masa Rasulullah hingga masa kini.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 7))),
        'tema': 'Tafsir Al-Quran',
        'pemateri': 'Ustadz Yusuf Mansur',
        'lokasi': 'Masjid Al-Awwabin',
        'deskripsi':
            'Kajian tafsir surat Al-Fatihah dan implementasinya dalam kehidupan.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final jadwal in jadwalList) {
      await _firestore.collection('jadwal_pengajian').add(jadwal);
    }

    print('✅ Dummy jadwal pengajian created');
  }

  /// Buat dummy jadwal kegiatan
  static Future<void> createDummyJadwalKegiatan() async {
    final now = DateTime.now();
    final kegiatanList = [
      {
        'nama_kegiatan': 'Qiyamul Lail Bersama',
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 1))),
        'lokasi': 'Masjid Al-Awwabin',
        'deskripsi':
            'Shalat malam bersama santri dan pengurus pondok pesantren.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'nama_kegiatan': 'Gotong Royong Membersihkan Pondok',
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 2))),
        'lokasi': 'Seluruh Area Pondok',
        'deskripsi': 'Kegiatan bersih-bersih lingkungan pondok pesantren.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'nama_kegiatan': 'Kajian Kitab Kuning',
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 4))),
        'lokasi': 'Ruang Kelas B',
        'deskripsi': 'Pembahasan kitab Fathul Qorib dengan metode sorogan.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'nama_kegiatan': 'Pelatihan Tahfidz',
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 6))),
        'lokasi': 'Ruang Tahfidz',
        'deskripsi': 'Program menghafal Al-Quran untuk santri.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'nama_kegiatan': 'Dialog Keagamaan',
        'tanggal': Timestamp.fromDate(now.add(const Duration(days: 8))),
        'lokasi': 'Aula Pondok',
        'deskripsi': 'Diskusi terbuka mengenai isu-isu keagamaan kontemporer.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final kegiatan in kegiatanList) {
      await _firestore.collection('jadwal_kegiatan').add(kegiatan);
    }

    print('✅ Dummy jadwal kegiatan created');
  }

  /// Buat dummy pengumuman
  static Future<void> createDummyPengumuman() async {
    final now = DateTime.now();
    final pengumumanList = [
      {
        'judul': 'Selamat Datang di SiSantri!',
        'isi':
            'Assalamu\'alaikum warahmatullahi wabarakatuh. Selamat datang di aplikasi SiSantri, platform digital untuk memudahkan aktivitas santri di Pondok Pesantren Al-Awwabin. Semoga aplikasi ini dapat memberikan manfaat bagi kemajuan pondok pesantren kita.',
        'tanggal': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'gambarUrl': null,
        'authorId': 'admin',
        'authorName': 'Admin SiSantri',
        'isPenting': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'judul': 'Perubahan Jadwal Pengajian',
        'isi':
            'Diberitahukan kepada seluruh santri bahwa jadwal pengajian hari Jumat akan dimajukan menjadi pukul 19.00 WIB. Mohon untuk hadir tepat waktu. Jazakumullahu khairan.',
        'tanggal': Timestamp.fromDate(now.subtract(const Duration(hours: 6))),
        'gambarUrl': null,
        'authorId': 'admin',
        'authorName': 'Admin SiSantri',
        'isPenting': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'judul': 'Pendaftaran Tahfidz Terbuka',
        'isi':
            'Alhamdulillah, program tahfidz Al-Quran telah dibuka kembali. Bagi santri yang ingin mengikuti program ini, silakan mendaftar ke bagian akademik. Kuota terbatas untuk 20 santri.',
        'tanggal': Timestamp.fromDate(now.subtract(const Duration(hours: 12))),
        'gambarUrl': null,
        'authorId': 'admin',
        'authorName': 'Admin SiSantri',
        'isPenting': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'judul': 'Lomba Kaligrafi Islami',
        'isi':
            'Dalam rangka memperingati Maulid Nabi Muhammad SAW, pondok pesantren akan mengadakan lomba kaligrafi islami. Pendaftaran dibuka mulai hari ini hingga akhir bulan. Hadiah menarik menanti para juara!',
        'tanggal': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
        'gambarUrl': null,
        'authorId': 'admin',
        'authorName': 'Admin SiSantri',
        'isPenting': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final pengumuman in pengumumanList) {
      await _firestore.collection('pengumuman').add(pengumuman);
    }

    print('✅ Dummy pengumuman created');
  }

  /// Hapus semua dummy data
  static Future<void> deleteAllDummyData() async {
    try {
      // Hapus users
      final usersSnapshot = await _firestore.collection('users').get();
      for (final doc in usersSnapshot.docs) {
        await doc.reference.delete();
      }

      // Hapus jadwal pengajian
      final jadwalPengajianSnapshot = await _firestore
          .collection('jadwal_pengajian')
          .get();
      for (final doc in jadwalPengajianSnapshot.docs) {
        await doc.reference.delete();
      }

      // Hapus jadwal kegiatan
      final jadwalKegiatanSnapshot = await _firestore
          .collection('jadwal_kegiatan')
          .get();
      for (final doc in jadwalKegiatanSnapshot.docs) {
        await doc.reference.delete();
      }

      // Hapus presensi
      final presensiSnapshot = await _firestore.collection('presensi').get();
      for (final doc in presensiSnapshot.docs) {
        await doc.reference.delete();
      }

      // Hapus pengumuman
      final pengumumanSnapshot = await _firestore
          .collection('pengumuman')
          .get();
      for (final doc in pengumumanSnapshot.docs) {
        await doc.reference.delete();
      }

      print('✅ Semua dummy data berhasil dihapus');
    } catch (e) {
      print('❌ Error menghapus dummy data: $e');
    }
  }

  /// Cek apakah sudah ada data di database
  static Future<bool> hasExistingData() async {
    try {
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      return usersSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error mengecek existing data: $e');
      return false;
    }
  }
}
