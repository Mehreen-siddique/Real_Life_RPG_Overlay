import '../../models/challenge_match.dart';

/// Compare participants for ranking.
///
/// Rules:
/// - Higher `progress` => better rank
/// - If `progress` equal:
///   - Completed users rank ahead
///   - If both completed: earlier `completedAt` ranks ahead
///   - If both not completed: earlier `updatedAt` ranks ahead
int compareParticipantsForRank(ChallengeParticipant a, ChallengeParticipant b) {
  const eps = 0.0001;
  final dp = a.progress - b.progress;
  if (dp.abs() > eps) {
    // Higher progress wins.
    return b.progress.compareTo(a.progress);
  }

  if (a.isCompleted != b.isCompleted) {
    // Completed wins.
    return (b.isCompleted ? 1 : 0) - (a.isCompleted ? 1 : 0);
  }

  if (a.isCompleted && b.isCompleted) {
    final ac = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bc = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return ac.compareTo(bc);
  }

  // Neither completed: earlier updatedAt wins.
  return a.updatedAt.compareTo(b.updatedAt);
}

