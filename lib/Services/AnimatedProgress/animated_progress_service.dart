import 'package:flutter/material.dart';
import 'dart:async';

///  Service to handle animated progress updates for XP, coins, and levels
/// Provides smooth transitions and visual effects for stat changes
class AnimatedProgressService {
  static AnimatedProgressService? _instance;
  static AnimatedProgressService get instance => _instance ??= AnimatedProgressService._();
  
  AnimatedProgressService._();
  
  final StreamController<ProgressUpdate> _progressController = 
      StreamController<ProgressUpdate>.broadcast();
  
  ///  Stream to listen for progress updates
  Stream<ProgressUpdate> get progressStream => _progressController.stream;
  
  ///  Animate XP gain with smooth transition
  void animateXPGain({
    required int currentXP,
    required int xpGained,
    required int totalXPForNextLevel,
    int? currentLevel,
    int? newLevel,
  }) {
    final update = ProgressUpdate(
      type: ProgressType.xp,
      currentValue: currentXP,
      targetValue: currentXP + xpGained,
      maxValue: totalXPForNextLevel,
      duration: Duration(milliseconds: 1500),
      levelUp: newLevel != null && newLevel > (currentLevel ?? 1),
      newLevel: newLevel,
      message: '+$xpGained XP',
      color: Colors.amber,
      icon: Icons.star,
    );
    
    _progressController.add(update);
    print(' [PROGRESS] XP Gain: $currentXP → ${currentXP + xpGained} (+$xpGained)');
  }
  
  ///  Animate coin gain with counting effect
  void animateCoinGain({
    required int currentCoins,
    required int coinsGained,
  }) {
    final update = ProgressUpdate(
      type: ProgressType.coins,
      currentValue: currentCoins,
      targetValue: currentCoins + coinsGained,
      maxValue: null,
      duration: Duration(milliseconds: 1200),
      message: '+$coinsGained Coins',
      color: Colors.orange, // Changed from gold to orange
      icon: Icons.monetization_on,
    );
    
    _progressController.add(update);
    print(' [PROGRESS] Coin Gain: $currentCoins → ${currentCoins + coinsGained} (+$coinsGained)');
  }
  
  ///  Animate level up with celebration effect
  void animateLevelUp({
    required int currentLevel,
    required int newLevel,
    required int currentXP,
    required int xpForNextLevel,
  }) {
    final update = ProgressUpdate(
      type: ProgressType.level,
      currentValue: currentLevel,
      targetValue: newLevel,
      maxValue: null,
      duration: Duration(milliseconds: 2000),
      levelUp: true,
      newLevel: newLevel,
      message: 'LEVEL UP! $currentLevel → $newLevel',
      color: Colors.purple,
      icon: Icons.trending_up,
      xpProgress: XPProgress(
        currentXP: currentXP,
        totalXPForNextLevel: xpForNextLevel,
      ),
    );
    
    _progressController.add(update);
    print(' [PROGRESS] Level Up: $currentLevel → $newLevel');
  }
  
  ///  Animate quest completion with combined effects
  void animateQuestCompletion({
    required int currentXP,
    required int xpGained,
    required int totalXPForNextLevel,
    required int currentCoins,
    required int coinsGained,
    required int currentLevel,
    int? newLevel,
  }) {
    // Animate XP gain first
    animateXPGain(
      currentXP: currentXP,
      xpGained: xpGained,
      totalXPForNextLevel: totalXPForNextLevel,
      currentLevel: currentLevel,
      newLevel: newLevel,
    );
    
    // Animate coin gain with slight delay
    Future.delayed(Duration(milliseconds: 300), () {
      animateCoinGain(
        currentCoins: currentCoins,
        coinsGained: coinsGained,
      );
    });
    
    // Animate level up if applicable
    if (newLevel != null && newLevel > currentLevel) {
      Future.delayed(Duration(milliseconds: 600), () {
        animateLevelUp(
          currentLevel: currentLevel,
          newLevel: newLevel,
          currentXP: currentXP + xpGained,
          xpForNextLevel: totalXPForNextLevel,
        );
      });
    }
  }
  
  ///  Dispose the service
  void dispose() {
    _progressController.close();
  }
}

///  Progress update data model
class ProgressUpdate {
  final ProgressType type;
  final int currentValue;
  final int targetValue;
  final int? maxValue;
  final Duration duration;
  final String message;
  final Color color;
  final IconData icon;
  final bool levelUp;
  final int? newLevel;
  final XPProgress? xpProgress;
  
  ProgressUpdate({
    required this.type,
    required this.currentValue,
    required this.targetValue,
    this.maxValue,
    required this.duration,
    required this.message,
    required this.color,
    required this.icon,
    this.levelUp = false,
    this.newLevel,
    this.xpProgress,
  });
  
  ///  Calculate progress percentage (for XP bars)
  double get progressPercentage {
    if (maxValue == null || maxValue == 0) return 1.0;
    return (targetValue % maxValue!) / maxValue!;
  }
}

///  Progress types
enum ProgressType {
  xp,
  coins,
  level,
}

///  XP progress data
class XPProgress {
  final int currentXP;
  final int totalXPForNextLevel;
  
  XPProgress({
    required this.currentXP,
    required this.totalXPForNextLevel,
  });
  
  ///  Get XP percentage
  double get percentage {
    if (totalXPForNextLevel == 0) return 1.0;
    return (currentXP % totalXPForNextLevel) / totalXPForNextLevel;
  }
}
