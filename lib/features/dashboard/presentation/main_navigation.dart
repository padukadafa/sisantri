import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import 'dashboard_page.dart';
import '../../jadwal/presentation/jadwal_page.dart';
import '../../presensi/presentation/presensi_page.dart';
import '../../leaderboard/presentation/leaderboard_page.dart';
import '../../profile/presentation/profile_page.dart';

/// Provider untuk current tab index
final currentTabProvider = StateProvider<int>((ref) => 0);

/// Main Navigation dengan Bottom Navigation Bar
class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    final List<Widget> pages = [
      const DashboardPage(),
      const JadwalPage(),
      const PresensiPage(),
      const LeaderboardPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentTab, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: 'Presensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Ranking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
