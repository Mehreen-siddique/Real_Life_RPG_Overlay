import 'package:flutter/cupertino.dart';

enum RankMovement { up, down, stable }

class LeaderboardUser {
  final String name;
  final int xp;
  final int rank;
  final int previousRank;
  final IconData avatar;
  final int streak;
  final bool isActive;

  LeaderboardUser({
    required this.name,
    required this.xp,
    required this.rank,
    required this.previousRank,
    required this.avatar,
    this.streak = 0,
    this.isActive = false,
  });


  RankMovement get movement {
    if (previousRank > rank) return RankMovement.up;
    if (previousRank < rank) return RankMovement.down;
    return RankMovement.stable;
  }

}
