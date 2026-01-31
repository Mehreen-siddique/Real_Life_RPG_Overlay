import 'package:cloud_firestore/cloud_firestore.dart';

/// Target types supported by [ChallengeService].
enum ChallengeTargetType {
  steps,
  questCompletion,
  xpEarned,
  stationaryMinutes,
}

extension ChallengeTargetTypeX on ChallengeTargetType {
  String get asString {
    switch (this) {
      case ChallengeTargetType.steps:
        return 'steps';
      case ChallengeTargetType.questCompletion:
        return 'questCompletion';
      case ChallengeTargetType.xpEarned:
        return 'xpEarned';
      case ChallengeTargetType.stationaryMinutes:
        return 'stationaryMinutes';
    }
  }

  static ChallengeTargetType fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'steps':
        return ChallengeTargetType.steps;
      case 'questcompletion':
      case 'quest_completion':
        return ChallengeTargetType.questCompletion;
      case 'xpearned':
      case 'xp_earned':
      case 'xp earned':
        return ChallengeTargetType.xpEarned;
      case 'stationaryminutes':
      case 'stationary_minutes':
      case 'stationary minutes':
        return ChallengeTargetType.stationaryMinutes;
      default:
        return ChallengeTargetType.steps;
    }
  }
}

class ChallengeMatch {
  final String id;
  final String title;
  final String description;
  final ChallengeTargetType targetType;
  final double targetValue;

  final String createdBy;
  final String createdByName;
  final bool isActive;
  final DateTime startAt;
  final DateTime endAt;

  /// List of UIDs participating.
  final List<String> participantIds;

  final DateTime createdAt;

  /// Optional quest linkage for questCompletion/xpEarned challenges.
  /// (Not part of the minimal required model, but enables correct progress rules.)
  final String? sourceQuestId;
  final String? sourceQuestType;

  const ChallengeMatch({
    required this.id,
    required this.title,
    required this.description,
    required this.targetType,
    required this.targetValue,
    required this.createdBy,
    required this.createdByName,
    required this.isActive,
    required this.startAt,
    required this.endAt,
    required this.participantIds,
    required this.createdAt,
    this.sourceQuestId,
    this.sourceQuestType,
  });

  bool get isEnded => endAt.isBefore(DateTime.now());

  factory ChallengeMatch.fromFirestore(
    String id,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    final startAtTs = data['startAt'] as Timestamp?;
    final endAtTs = data['endAt'] as Timestamp?;

    return ChallengeMatch(
      id: id,
      title: (data['title'] ?? '') as String,
      description: (data['description'] ?? '') as String,
      targetType: ChallengeTargetTypeX.fromString(data['targetType'] as String?),
      targetValue: (data['targetValue'] ?? 0).toDouble(),
      createdBy: (data['createdBy'] ?? '') as String,
      createdByName: (data['createdByName'] ?? 'Unknown') as String,
      isActive: (data['isActive'] ?? true) as bool,
      startAt: (startAtTs ?? Timestamp.now()).toDate(),
      endAt: (endAtTs ?? Timestamp.now()).toDate(),
      participantIds: List<String>.from(data['participantIds'] ?? const []),
      createdAt: ((data['createdAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
      sourceQuestId: data['sourceQuestId'] as String?,
      sourceQuestType: data['sourceQuestType'] as String?,
    );
  }
}

class ChallengeParticipant {
  final String userId;
  final String username;
  final double progress;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? rank;
  final String? selectedCharacterId;
  final DateTime updatedAt;

  const ChallengeParticipant({
    required this.userId,
    required this.username,
    required this.progress,
    required this.isCompleted,
    required this.completedAt,
    required this.rank,
    required this.selectedCharacterId,
    required this.updatedAt,
  });

  factory ChallengeParticipant.fromFirestore(
    String userId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ChallengeParticipant(
      userId: userId,
      username: (data['username'] ?? 'Unknown') as String,
      progress: (data['progress'] ?? 0).toDouble(),
      isCompleted: (data['isCompleted'] ?? false) as bool,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      rank: (data['rank'] as num?)?.toInt(),
      selectedCharacterId: data['selectedCharacterId'] as String?,
      updatedAt:
          ((data['updatedAt'] as Timestamp?) ?? Timestamp.now()).toDate(),
    );
  }
}

