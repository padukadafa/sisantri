# Announcement Management Widgets

Folder ini berisi widget-widget yang digunakan pada fitur manajemen pengumuman.

## Struktur Widget

### Pages

- **announcement_management_page.dart** - Halaman utama manajemen pengumuman (refactored)
  - Menggunakan widget-widget modular yang ada di folder ini
  - Lebih clean dan mudah dimaintain

### Widgets

#### State Widgets

- **announcement_empty_state.dart** - Widget untuk menampilkan state ketika belum ada pengumuman
  - Menampilkan icon, pesan, dan tombol untuk membuat pengumuman pertama
- **announcement_error_state.dart** - Widget untuk menampilkan state error

  - Menampilkan icon error, pesan error, dan tombol retry
  - Terintegrasi dengan provider untuk refresh data

- **announcement_list_view.dart** - Widget untuk menampilkan list pengumuman
  - Menggunakan RefreshIndicator untuk pull-to-refresh
  - Menampilkan AnnouncementCard untuk setiap item
  - Handle navigasi ke edit page dan delete dialog

#### Card Components

- **announcement_card.dart** - Widget utama card pengumuman
- **announcement_card_header.dart** - Header card (judul, menu actions)
- **announcement_card_content.dart** - Konten card (deskripsi, excerpt)
- **announcement_card_chips.dart** - Chips card (target, prioritas, status)
- **announcement_card_footer.dart** - Footer card (tanggal, author)

#### Other Components

- **announcement_stats_bar.dart** - Bar statistik pengumuman
- **announcement_delete_dialog.dart** - Dialog konfirmasi hapus pengumuman
- **announcement_fab.dart** - Floating Action Button untuk tambah pengumuman

## Keuntungan Refactoring

1. **Separation of Concerns** - Setiap widget punya tanggung jawab spesifik
2. **Reusability** - Widget bisa digunakan ulang di tempat lain
3. **Maintainability** - Lebih mudah untuk maintain dan debug
4. **Testability** - Setiap widget bisa ditest secara independen
5. **Readability** - Kode lebih mudah dibaca dan dipahami

## Penggunaan

```dart
// Di halaman utama
class AnnouncementManagementPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          AnnouncementStatsBar(stats: stats),
          Expanded(
            child: announcementsAsync.when(
              loading: () => CircularProgressIndicator(),
              error: (error, _) => AnnouncementErrorState(error: error),
              data: (announcements) {
                if (announcements.isEmpty) {
                  return AnnouncementEmptyState();
                }
                return AnnouncementListView(announcements: announcements);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnnouncementFab(),
    );
  }
}
```

## Migration Notes

File `announcement_management_page.dart` sebelumnya memiliki sekitar 200 baris kode. Setelah refactoring:

- Page utama: ~30 baris (berkurang 85%)
- Logic terbagi ke 5 widget terpisah
- Setiap widget fokus pada satu responsibility
