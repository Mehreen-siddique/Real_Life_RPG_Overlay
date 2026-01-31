/// Simple unlock criteria used across AR selection and other progression.
class UnlockRule {
  final int requiredLevel;
  final int requiredCoins;
  final int requiredXP;

  const UnlockRule({
    required this.requiredLevel,
    this.requiredCoins = 0,
    this.requiredXP = 0,
  });

  bool isUnlocked({
    required int level,
    required int coins,
    required int xp,
  }) {
    return level >= requiredLevel && coins >= requiredCoins && xp >= requiredXP;
  }
}

