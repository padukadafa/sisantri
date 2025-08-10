/// Model untuk leaderboard santri
class LeaderboardModel {
  final String id;
  final String userId;
  final String nama;
  final int poin;
  final String? fotoProfil;
  final int ranking;
  final DateTime? lastUpdated;

  const LeaderboardModel({
    required this.id,
    required this.userId,
    required this.nama,
    required this.poin,
    this.fotoProfil,
    required this.ranking,
    this.lastUpdated,
  });

  /// Factory constructor untuk membuat LeaderboardModel dari JSON
  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nama: json['nama'] as String,
      poin: json['poin'] as int,
      fotoProfil: json['fotoProfil'] as String?,
      ranking: json['ranking'] as int,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['lastUpdated'].millisecondsSinceEpoch,
            )
          : null,
    );
  }

  /// Method untuk convert LeaderboardModel ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nama': nama,
      'poin': poin,
      'fotoProfil': fotoProfil,
      'ranking': ranking,
      'lastUpdated': lastUpdated,
    };
  }

  /// Method untuk copy dengan perubahan tertentu
  LeaderboardModel copyWith({
    String? id,
    String? userId,
    String? nama,
    int? poin,
    String? fotoProfil,
    int? ranking,
    DateTime? lastUpdated,
  }) {
    return LeaderboardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nama: nama ?? this.nama,
      poin: poin ?? this.poin,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      ranking: ranking ?? this.ranking,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Get ranking text dengan suffix
  String get rankingText {
    switch (ranking) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${ranking}th';
    }
  }

  /// Get medal emoji berdasarkan ranking
  String get medalEmoji {
    switch (ranking) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  /// Check apakah dalam top 3
  bool get isTopThree => ranking <= 3;

  @override
  String toString() {
    return 'LeaderboardModel(id: $id, nama: $nama, poin: $poin, ranking: $ranking)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
