import 'package:cloud_firestore/cloud_firestore.dart';

/// Quest model compatible with Firestore for auto-completion system
class QuestModel {
  final String? id;
  final String title;
  final String? description;
  final String? type;
  final String? difficulty;
  final int? xpReward;
  final int? statBonus;
  final int? goldReward;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool isDaily;
  final bool isCustom;
  final bool isDeleted;
  
  // Activity tracking fields
  final String? activityType;
  final int? target;
  final int? targetSteps;
  final double? targetDistanceKm;
  final int? targetDurationMinutes;
  
  // Progress fields
  final int currentSteps;
  final double currentDistanceKm;
  final int currentDurationMinutes;
  final DateTime? trackingStartedAt;
  final DateTime? lastUpdatedAt;
  final String? detectedActivity;

  QuestModel({
    this.id,
    required this.title,
    this.description,
    this.type,
    this.difficulty,
    this.xpReward,
    this.statBonus,
    this.goldReward,
    this.isCompleted = false,
    this.completedAt,
    this.dueDate,
    DateTime? createdAt,
    this.isDaily = false,
    this.isCustom = false,
    this.isDeleted = false,
    this.activityType,
    this.target,
    this.targetSteps,
    this.targetDistanceKm,
    this.targetDurationMinutes,
    this.currentSteps = 0,
    this.currentDistanceKm = 0.0,
    this.currentDurationMinutes = 0,
    this.trackingStartedAt,
    this.lastUpdatedAt,
    this.detectedActivity,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create from Firestore document
  factory QuestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return QuestModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      type: data['type'],
      difficulty: data['difficulty'],
      xpReward: data['xpReward'],
      statBonus: data['statBonus'],
      goldReward: data['goldReward'],
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      dueDate: data['dueDate'] != null 
          ? (data['dueDate'] as Timestamp).toDate() 
          : null,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      isDaily: data['isDaily'] ?? false,
      isCustom: data['isCustom'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      activityType: data['activityType'],
      target: data['target'],
      targetSteps: data['targetSteps'],
      targetDistanceKm: data['targetDistanceKm']?.toDouble(),
      targetDurationMinutes: data['targetDurationMinutes'],
      currentSteps: data['currentSteps'] ?? 0,
      currentDistanceKm: data['currentDistanceKm']?.toDouble() ?? 0.0,
      currentDurationMinutes: data['currentDurationMinutes'] ?? 0,
      trackingStartedAt: data['trackingStartedAt'] != null 
          ? (data['trackingStartedAt'] as Timestamp).toDate() 
          : null,
      lastUpdatedAt: data['lastUpdatedAt'] != null 
          ? (data['lastUpdatedAt'] as Timestamp).toDate() 
          : null,
      detectedActivity: data['detectedActivity'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'difficulty': difficulty,
      'xpReward': xpReward,
      'statBonus': statBonus,
      'goldReward': goldReward,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDaily': isDaily,
      'isCustom': isCustom,
      'isDeleted': isDeleted,
      'activityType': activityType,
      'target': target,
      'targetSteps': targetSteps,
      'targetDistanceKm': targetDistanceKm,
      'targetDurationMinutes': targetDurationMinutes,
      'currentSteps': currentSteps,
      'currentDistanceKm': currentDistanceKm,
      'currentDurationMinutes': currentDurationMinutes,
      'trackingStartedAt': trackingStartedAt != null 
          ? Timestamp.fromDate(trackingStartedAt!) 
          : null,
      'lastUpdatedAt': lastUpdatedAt != null 
          ? Timestamp.fromDate(lastUpdatedAt!) 
          : null,
      'detectedActivity': detectedActivity,
    };
  }

  /// Get effective target value
  int get effectiveTarget {
    return target ?? 
           targetSteps ?? 
           targetDurationMinutes ?? 
           (targetDistanceKm != null ? (targetDistanceKm! * 1000).toInt() : 0);
  }

  /// Create a copy with modified fields
  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? difficulty,
    int? xpReward,
    int? statBonus,
    int? goldReward,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isDaily,
    bool? isCustom,
    bool? isDeleted,
    String? activityType,
    int? target,
    int? targetSteps,
    double? targetDistanceKm,
    int? targetDurationMinutes,
    int? currentSteps,
    double? currentDistanceKm,
    int? currentDurationMinutes,
    DateTime? trackingStartedAt,
    DateTime? lastUpdatedAt,
    String? detectedActivity,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      statBonus: statBonus ?? this.statBonus,
      goldReward: goldReward ?? this.goldReward,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isDaily: isDaily ?? this.isDaily,
      isCustom: isCustom ?? this.isCustom,
      isDeleted: isDeleted ?? this.isDeleted,
      activityType: activityType ?? this.activityType,
      target: target ?? this.target,
      targetSteps: targetSteps ?? this.targetSteps,
      targetDistanceKm: targetDistanceKm ?? this.targetDistanceKm,
      targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
      currentSteps: currentSteps ?? this.currentSteps,
      currentDistanceKm: currentDistanceKm ?? this.currentDistanceKm,
      currentDurationMinutes: currentDurationMinutes ?? this.currentDurationMinutes,
      trackingStartedAt: trackingStartedAt ?? this.trackingStartedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      detectedActivity: detectedActivity ?? this.detectedActivity,
    );
  }
}

/// Quest difficulty levels
enum QuestDifficulty {
  easy,
  medium,
  hard,
}
