import 'package:cloud_firestore/cloud_firestore.dart';

/// Challenge Model
/// Represents a challenge/competition between users
class Challenge {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String createdByUsername;
  final int coinReward;
  final int xpReward;
  final List<String> participantIds;
  final DateTime deadline;
  final DateTime createdAt;
  final bool isActive;

  Challenge({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdBy,
    required this.createdByUsername,
    required this.coinReward,
    required this.xpReward,
    required this.participantIds,
    required this.deadline,
    required this.createdAt,
    this.isActive = true,
  });

  /// Get participant count
  int get participantCount => participantIds.length;

  /// Check if challenge has expired
  bool get isExpired => DateTime.now().isAfter(deadline);

  /// Get time remaining as Duration
  Duration get timeRemaining => deadline.difference(DateTime.now());

  /// Get formatted time remaining string
  String get timeRemainingString {
    final remaining = timeRemaining;
    if (remaining.isNegative) return 'Expired';
    
    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  /// Check if user is participant
  bool isParticipant(String userId) => participantIds.contains(userId);

  /// Create from Firestore document
  factory Challenge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      title: data['title'] ?? 'Untitled Challenge',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdByUsername: data['createdByUsername'] ?? 'Unknown',
      coinReward: (data['coinReward'] ?? 0).toInt(),
      xpReward: (data['xpReward'] ?? 0).toInt(),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdByUsername': createdByUsername,
      'coinReward': coinReward,
      'xpReward': xpReward,
      'participantIds': participantIds,
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  /// Create copy with updated fields
  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    String? createdByUsername,
    int? coinReward,
    int? xpReward,
    List<String>? participantIds,
    DateTime? deadline,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdByUsername: createdByUsername ?? this.createdByUsername,
      coinReward: coinReward ?? this.coinReward,
      xpReward: xpReward ?? this.xpReward,
      participantIds: participantIds ?? this.participantIds,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Challenge Progress Model
/// Tracks individual user's progress in a challenge
class ChallengeProgress {
  final String challengeId;
  final String userId;
  final String username;
  final int score;
  final int completedTasks;
  final DateTime joinedAt;

  ChallengeProgress({
    required this.challengeId,
    required this.userId,
    required this.username,
    required this.score,
    required this.completedTasks,
    required this.joinedAt,
  });

  /// Create from Firestore document
  factory ChallengeProgress.fromFirestore(
    String challengeId,
    DocumentSnapshot doc,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeProgress(
      challengeId: challengeId,
      userId: doc.id,
      username: data['username'] ?? 'Unknown',
      score: (data['score'] ?? 0).toInt(),
      completedTasks: (data['completedTasks'] ?? 0).toInt(),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'score': score,
      'completedTasks': completedTasks,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }
}

/// Challenge Invitation Model
/// Represents an invitation to join a challenge
class ChallengeInvitation {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String challengeId;
  final String challengeTitle;
  final String status;
  final DateTime sentAt;

  ChallengeInvitation({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.challengeId,
    required this.challengeTitle,
    required this.status,
    required this.sentAt,
  });

  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusDeclined = 'declined';

  bool get isPending => status == statusPending;

  /// Create from Firestore document
  factory ChallengeInvitation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeInvitation(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUsername: data['fromUsername'] ?? 'Unknown',
      toUserId: data['toUserId'] ?? '',
      challengeId: data['challengeId'] ?? '',
      challengeTitle: data['challengeTitle'] ?? 'Unknown Challenge',
      status: data['status'] ?? 'pending',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'toUserId': toUserId,
      'challengeId': challengeId,
      'challengeTitle': challengeTitle,
      'status': status,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }
}
