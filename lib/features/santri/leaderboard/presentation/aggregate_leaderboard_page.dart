import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisantri/core/theme/app_theme.dart';
import 'package:sisantri/shared/models/presensi_aggregate_model.dart';
import 'package:sisantri/shared/services/presensi_aggregate_service.dart';
import 'package:sisantri/shared/models/user_model.dart';
import 'package:sisantri/shared/services/auth_service.dart';

/// Provider untuk periode filter leaderboard
final leaderboardPeriodeProvider = StateProvider<String>((ref) => 'monthly');

/// Provider untuk leaderboard data dari aggregates
final aggregateLeaderboardProvider =
    FutureProvider.family<List<Map<String, dynamic>>, Map<String, String>>((
      ref,
      params,
    ) async {
      final periode = params['periode'] ?? 'monthly';
      final periodeKey =
          params['periodeKey'] ?? PeriodeKeyHelper.monthly(DateTime.now());

      final leaderboard = await PresensiAggregateService.getLeaderboard(
        periode: periode,
        periodeKey: periodeKey,
        limit: 100,
      );

      // Get user details untuk setiap entry
      final result = <Map<String, dynamic>>[];
      for (final entry in leaderboard) {
        final userId = entry['userId'] as String;
        final userData = await AuthService.getUserData(userId);

        if (userData != null) {
          result.add({
            'user': userData,
            'totalPoin': entry['totalPoin'],
            'totalHadir': entry['totalHadir'],
            'totalIzin': entry['totalIzin'],
            'totalSakit': entry['totalSakit'],
            'totalAlpha': entry['totalAlpha'],
          });
        }
      }

      return result;
    });

/// Halaman Leaderboard menggunakan agregasi
class AggregateLeaderboardPage extends ConsumerWidget {
  const AggregateLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periode = ref.watch(leaderboardPeriodeProvider);
    final periodeKey = _getPeriodeKey(periode);

    final leaderboardAsync = ref.watch(
      aggregateLeaderboardProvider({
        'periode': periode,
        'periodeKey': periodeKey,
      }),
    );

    final currentUserAsync = ref.watch(
      FutureProvider<UserModel?>((ref) async {
        final user = AuthService.currentUser;
        if (user == null) return null;
        return await AuthService.getUserData(user.uid);
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking Santri'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            initialValue: periode,
            onSelected: (value) {
              ref.read(leaderboardPeriodeProvider.notifier).state = value;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'daily', child: Text('Hari Ini')),
              const PopupMenuItem(value: 'weekly', child: Text('Minggu Ini')),
              const PopupMenuItem(value: 'monthly', child: Text('Bulan Ini')),
              const PopupMenuItem(
                value: 'semester',
                child: Text('Semester Ini'),
              ),
              const PopupMenuItem(value: 'yearly', child: Text('Tahun Ini')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(aggregateLeaderboardProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan periode info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  _getPeriodeLabel(periode),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  periodeKey,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard content
          Expanded(
            child: leaderboardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(aggregateLeaderboardProvider);
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
              data: (leaderboard) {
                if (leaderboard.isEmpty) {
                  return const Center(child: Text('Belum ada data ranking'));
                }

                // Filter untuk santri role (top 10 only)
                final filteredList = currentUserAsync.when(
                  data: (currentUser) {
                    if (currentUser?.role == 'santri') {
                      return leaderboard.take(10).toList();
                    }
                    return leaderboard;
                  },
                  loading: () => leaderboard,
                  error: (_, __) => leaderboard,
                );

                // Get top 3 untuk podium
                final top3 = filteredList.take(3).toList();
                final rest = filteredList.skip(3).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(aggregateLeaderboardProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      if (top3.isNotEmpty) _buildPodium(top3),
                      const SizedBox(height: 16),
                      ...rest.asMap().entries.map((entry) {
                        final index =
                            entry.key + 3; // +3 karena top 3 di podium
                        final item = entry.value;
                        return _buildLeaderboardTile(context, index + 1, item);
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.amber.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2
          if (top3.length > 1)
            Expanded(child: _buildPodiumItem(2, top3[1], 120, Colors.grey)),
          // Rank 1
          if (top3.isNotEmpty)
            Expanded(child: _buildPodiumItem(1, top3[0], 150, Colors.amber)),
          // Rank 3
          if (top3.length > 2)
            Expanded(child: _buildPodiumItem(3, top3[2], 100, Colors.brown)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    int rank,
    Map<String, dynamic> data,
    double height,
    Color color,
  ) {
    final user = data['user'] as UserModel;
    final poin = data['totalPoin'] as int;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar dengan badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundImage: user.fotoProfil != null
                    ? NetworkImage(user.fotoProfil!)
                    : null,
                child: user.fotoProfil == null
                    ? Text(
                        user.nama.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Nama
        SizedBox(
          width: 90,
          child: Text(
            user.nama,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
        // Poin
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                '$poin',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Podium stand
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '#$rank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(
    BuildContext context,
    int rank,
    Map<String, dynamic> data,
  ) {
    final user = data['user'] as UserModel;
    final poin = data['totalPoin'] as int;
    final hadir = data['totalHadir'] as int;
    final izin = data['totalIzin'] as int;
    final sakit = data['totalSakit'] as int;
    final alpha = data['totalAlpha'] as int;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.nama,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$poin',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              _buildStatChip('H', hadir, Colors.green),
              const SizedBox(width: 4),
              _buildStatChip('I', izin, Colors.orange),
              const SizedBox(width: 4),
              _buildStatChip('S', sakit, Colors.blue),
              const SizedBox(width: 4),
              _buildStatChip('A', alpha, Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label:$value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return Colors.amber;
    if (rank <= 10) return AppTheme.primaryColor;
    return Colors.grey;
  }

  String _getPeriodeLabel(String periode) {
    switch (periode) {
      case 'daily':
        return 'Ranking Hari Ini';
      case 'weekly':
        return 'Ranking Minggu Ini';
      case 'monthly':
        return 'Ranking Bulan Ini';
      case 'semester':
        return 'Ranking Semester Ini';
      case 'yearly':
        return 'Ranking Tahun Ini';
      default:
        return 'Ranking';
    }
  }

  String _getPeriodeKey(String periode) {
    final now = DateTime.now();
    switch (periode) {
      case 'daily':
        return PeriodeKeyHelper.daily(now);
      case 'weekly':
        return PeriodeKeyHelper.weekly(now);
      case 'monthly':
        return PeriodeKeyHelper.monthly(now);
      case 'semester':
        return PeriodeKeyHelper.semester(now);
      case 'yearly':
        return PeriodeKeyHelper.yearly(now);
      default:
        return PeriodeKeyHelper.monthly(now);
    }
  }
}
