import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/auth_service.dart';
import '../../jadwal/presentation/jadwal_page.dart';
import '../../presensi/presentation/presensi_summary_page.dart';
import '../../leaderboard/presentation/leaderboard_page.dart';
import '../../pengumuman/presentation/pengumuman_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../admin/presentation/dewa_guru_dashboard_page.dart';

/// Provider untuk current tab index khusus dewan guru
final dewaGuruTabProvider = StateProvider<int>((ref) => 0);

/// Provider untuk mendapatkan data user dewan guru
final dewaGuruUserProvider = FutureProvider<UserModel?>((ref) async {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) return null;

  return await AuthService.getUserData(currentUser.uid);
});

/// Navigation khusus untuk Dewan Guru
class DewaGuruNavigation extends ConsumerWidget {
  const DewaGuruNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(dewaGuruTabProvider);
    final userData = ref.watch(dewaGuruUserProvider);

    return userData.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('User tidak ditemukan')),
          );
        }

        final List<Widget> pages = [
          DewaGuruDashboardPage(user: user),
          const PengumumanPage(),
          const JadwalPage(),
          const LeaderboardPage(),
          const PresensiSummaryPage(),
          const ProfilePage(),
        ];

        return Scaffold(
          body: IndexedStack(index: currentTab, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentTab,
            onTap: (index) {
              ref.read(dewaGuruTabProvider.notifier).state = index;
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.campaign_outlined),
                activeIcon: Icon(Icons.campaign),
                label: 'Pengumuman',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule_outlined),
                activeIcon: Icon(Icons.schedule),
                label: 'Jadwal',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard_outlined),
                activeIcon: Icon(Icons.leaderboard),
                label: 'Ranking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'Presensi',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }
}
