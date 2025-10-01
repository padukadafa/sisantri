import '../models/pengumuman_model.dart';

/// Utility class untuk filtering pengumuman
class AnnouncementFilter {
  static List<Pengumuman> filterPengumuman(
    List<Pengumuman> pengumumanList,
    String searchQuery,
    String selectedFilter,
  ) {
    List<Pengumuman> filtered = pengumumanList;

    // Filter berdasarkan search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.judul.toLowerCase().contains(searchQuery) ||
                p.konten.toLowerCase().contains(searchQuery) ||
                p.kategori.toLowerCase().contains(searchQuery),
          )
          .toList();
    }

    // Filter berdasarkan status
    switch (selectedFilter) {
      case 'aktif':
        filtered = filtered.where((p) => p.isActive && !p.isExpired).toList();
        break;
      case 'expired':
        filtered = filtered.where((p) => p.isExpired).toList();
        break;
      case 'draft':
        filtered = filtered.where((p) => !p.isActive).toList();
        break;
      case 'penting':
        filtered = filtered.where((p) => p.prioritas == 'tinggi').toList();
        break;
      case 'urgent':
        filtered = filtered.where((p) => p.prioritas == 'urgent').toList();
        break;
    }

    return filtered;
  }
}
