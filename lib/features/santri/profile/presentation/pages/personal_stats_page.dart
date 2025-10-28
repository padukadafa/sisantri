import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/core/theme/app_theme.dart';

/// Model untuk achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.maxProgress = 100,
  });

  double get progressPercentage =>
      maxProgress > 0 ? progress / maxProgress : 0.0;
}

/// Model untuk statistik
class PersonalStats {
  final int totalPoints;
  final int currentRank;
  final int totalPresence;
  final int perfectWeeks;
  final int activitiesJoined;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> categoryStats;

  const PersonalStats({
    required this.totalPoints,
    required this.currentRank,
    required this.totalPresence,
    required this.perfectWeeks,
    required this.activitiesJoined,
    required this.currentStreak,
    required this.longestStreak,
    required this.categoryStats,
  });
}

/// Provider untuk personal stats
final personalStatsProvider = StateProvider<PersonalStats>(
  (ref) => const PersonalStats(
    totalPoints: 1250,
    currentRank: 3,
    totalPresence: 87,
    perfectWeeks: 4,
    activitiesJoined: 23,
    currentStreak: 7,
    longestStreak: 14,
    categoryStats: {'sholat': 45, 'kajian': 18, 'olahraga': 12, 'umum': 12},
  ),
);

/// Provider untuk achievements
final achievementsProvider = StateProvider<List<Achievement>>(
  (ref) => [
    const Achievement(
      id: '1',
      title: 'First Steps',
      description: 'Bergabung dengan SiSantri',
      icon: Icons.flag,
      color: Colors.green,
      isUnlocked: true,
      unlockedAt: null,
      progress: 1,
      maxProgress: 1,
    ),
    const Achievement(
      id: '2',
      title: 'Perfect Week',
      description: 'Hadir sempurna selama 1 minggu',
      icon: Icons.star,
      color: Colors.amber,
      isUnlocked: true,
      progress: 4,
      maxProgress: 4,
    ),
    const Achievement(
      id: '3',
      title: 'Prayer Champion',
      description: 'Hadir sholat berjamaah 50 kali',
      icon: Icons.mosque,
      color: Colors.blue,
      isUnlocked: true,
      progress: 50,
      maxProgress: 50,
    ),
    const Achievement(
      id: '4',
      title: 'Study Master',
      description: 'Ikuti 25 kajian',
      icon: Icons.menu_book,
      color: Colors.purple,
      isUnlocked: false,
      progress: 18,
      maxProgress: 25,
    ),
    const Achievement(
      id: '5',
      title: 'Team Player',
      description: 'Ikuti 20 kegiatan umum',
      icon: Icons.group,
      color: Colors.orange,
      isUnlocked: false,
      progress: 12,
      maxProgress: 20,
    ),
    const Achievement(
      id: '6',
      title: 'Top Performer',
      description: 'Masuk 5 besar leaderboard',
      icon: Icons.emoji_events,
      color: Colors.red,
      isUnlocked: true,
      progress: 1,
      maxProgress: 1,
    ),
    const Achievement(
      id: '7',
      title: 'Streak Master',
      description: 'Streak 30 hari berturut-turut',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
      isUnlocked: false,
      progress: 7,
      maxProgress: 30,
    ),
    const Achievement(
      id: '8',
      title: 'Point Collector',
      description: 'Kumpulkan 2000 poin',
      icon: Icons.diamond,
      color: Colors.cyan,
      isUnlocked: false,
      progress: 1250,
      maxProgress: 2000,
    ),
  ],
);

/// Provider untuk filter achievement
final achievementFilterProvider = StateProvider<String>((ref) => 'all');

/// Halaman Statistik dan Achievement Personal
class PersonalStatsPage extends ConsumerWidget {
  const PersonalStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(personalStatsProvider);
    final achievements = ref.watch(achievementsProvider);
    final filter = ref.watch(achievementFilterProvider);

    // Filter achievements
    final filteredAchievements = _filterAchievements(achievements, filter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik & Prestasi'),
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
                  Tab(text: 'Statistik'),
                  Tab(text: 'Prestasi'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildStatsTab(context, stats),
                  _buildAchievementsTab(
                    context,
                    ref,
                    filteredAchievements,
                    filter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context, PersonalStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _buildOverviewCards(stats),

          const SizedBox(height: 24),

          // Performance Chart
          _buildPerformanceSection(stats),

          const SizedBox(height: 24),

          // Category Breakdown
          _buildCategoryBreakdown(stats),

          const SizedBox(height: 24),

          // Progress Timeline
          _buildProgressTimeline(stats),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(
    BuildContext context,
    WidgetRef ref,
    List<Achievement> achievements,
    String filter,
  ) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;

    return Column(
      children: [
        // Achievement Summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$unlockedCount/$totalCount Prestasi',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Terus kumpulkan prestasi!',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 8),

                    LinearProgressIndicator(
                      value: unlockedCount / totalCount,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Filter Chips
        _buildAchievementFilter(context, ref, filter),

        // Achievements List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(context, achievement);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(PersonalStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                title: 'Total Poin',
                value: '${stats.totalPoints}',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.leaderboard,
                title: 'Ranking',
                value: '#${stats.currentRank}',
                color: Colors.blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                title: 'Kehadiran',
                value: '${stats.totalPresence}',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                title: 'Streak',
                value: '${stats.currentStreak}',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(PersonalStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performa Minggu Ini',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2E2E),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildPerformanceItem(
                  'Perfect Weeks',
                  '${stats.perfectWeeks}',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              Expanded(
                child: _buildPerformanceItem(
                  'Aktivitas',
                  '${stats.activitiesJoined}',
                  Icons.event,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildPerformanceItem(
                  'Longest Streak',
                  '${stats.longestStreak}',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(PersonalStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown Kategori',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2E2E),
            ),
          ),

          const SizedBox(height: 16),

          ...stats.categoryStats.entries.map((entry) {
            final category = entry.key;
            final count = entry.value;
            final total = stats.categoryStats.values.reduce((a, b) => a + b);
            final percentage = count / total;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getCategoryLabel(category),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(category),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCategoryColor(category),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline(PersonalStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E2E2E),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Fitur timeline progress akan segera hadir dengan grafik interaktif untuk melacak perkembangan Anda dari waktu ke waktu.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementFilter(
    BuildContext context,
    WidgetRef ref,
    String filter,
  ) {
    final filters = [
      {'value': 'all', 'label': 'Semua'},
      {'value': 'unlocked', 'label': 'Terbuka'},
      {'value': 'locked', 'label': 'Terkunci'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filterItem = filters[index];
          final isSelected = filter == filterItem['value'];

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(filterItem['label']!),
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
              ),
              onSelected: (selected) {
                ref.read(achievementFilterProvider.notifier).state =
                    filterItem['value']!;
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? achievement.color.withOpacity(0.3)
              : Colors.grey[200]!,
          width: 1,
        ),
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
        onTap: () => _showAchievementDetail(context, achievement),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color.withOpacity(0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: achievement.isUnlocked
                        ? achievement.color.withOpacity(0.3)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.isUnlocked
                      ? achievement.color
                      : Colors.grey[400],
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: achievement.isUnlocked
                                  ? const Color(0xFF2E2E2E)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (achievement.isUnlocked)
                          Icon(
                            Icons.check_circle,
                            color: achievement.color,
                            size: 20,
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      achievement.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),

                    if (!achievement.isUnlocked) ...[
                      const SizedBox(height: 8),

                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: achievement.progressPercentage,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                achievement.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${achievement.progress}/${achievement.maxProgress}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: achievement.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Methods
  List<Achievement> _filterAchievements(
    List<Achievement> achievements,
    String filter,
  ) {
    switch (filter) {
      case 'unlocked':
        return achievements.where((a) => a.isUnlocked).toList();
      case 'locked':
        return achievements.where((a) => !a.isUnlocked).toList();
      default:
        return achievements;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'sholat':
        return Icons.mosque;
      case 'kajian':
        return Icons.menu_book;
      case 'olahraga':
        return Icons.sports;
      case 'umum':
        return Icons.event;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'sholat':
        return Colors.green;
      case 'kajian':
        return Colors.blue;
      case 'olahraga':
        return Colors.orange;
      case 'umum':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'sholat':
        return 'Sholat';
      case 'kajian':
        return 'Kajian';
      case 'olahraga':
        return 'Olahraga';
      case 'umum':
        return 'Umum';
      default:
        return category;
    }
  }

  void _showAchievementDetail(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(achievement.icon, color: achievement.color),
            const SizedBox(width: 8),
            Expanded(child: Text(achievement.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description, style: const TextStyle(fontSize: 14)),

            const SizedBox(height: 16),

            if (achievement.isUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: achievement.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: achievement.color),
                    const SizedBox(width: 8),
                    const Text(
                      'Prestasi Terbuka!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Progress: ${achievement.progress}/${achievement.maxProgress}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: achievement.progressPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
              ),
              const SizedBox(height: 8),
              Text(
                '${(achievement.progressPercentage * 100).round()}% selesai',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
