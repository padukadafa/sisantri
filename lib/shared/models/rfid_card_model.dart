class RfidCardModel {
  final String id;
  final String cardId;
  final String? userId;
  final String? userName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUsedAt;

  const RfidCardModel({
    required this.id,
    required this.cardId,
    this.userId,
    this.userName,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastUsedAt,
  });

  factory RfidCardModel.fromJson(Map<String, dynamic> json) {
    return RfidCardModel(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'userId': userId,
      'userName': userName,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  RfidCardModel copyWith({
    String? id,
    String? cardId,
    String? userId,
    String? userName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
  }) {
    return RfidCardModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  bool get isAssigned => userId != null;

  String get displayName => userName ?? 'Kartu ${cardId.substring(0, 8)}...';

  String get statusText => isActive ? 'Aktif' : 'Non-Aktif';

  String get assignmentText => isAssigned ? userName! : 'Belum Ditugaskan';
}
