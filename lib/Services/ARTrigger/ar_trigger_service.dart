
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:math';
import '../CharacterSelection/character_selection_service.dart';
import '../CharacterSelection/ar_character_selection_storage.dart';
import '../../ArView/AR_Screen.dart';
import '../../utils/constants.dart';
import '../../models/unlock_rule.dart';

class ARTriggerService {
  static final ARTriggerService _instance = ARTriggerService._internal();
  factory ARTriggerService() => _instance;
  ARTriggerService._internal();

  final ARCharacterSelectionStorage _selectionStorage = ARCharacterSelectionStorage();

  // Get user-selected character for celebrations.
  // If nothing is selected, fall back to the first unlocked character using the user's progress.
  Future<ARCharacterItem> getCharacterForQuestCompletion({
    required int userLevel,
    required int userCoins,
    required int userXp,
    required String questType,
  }) async {
    final characters = CharacterSelectionService.instance.getAllCharacters();
    final storedCharacterId = await _selectionStorage.getSelectedCharacterId();

    // Build list of unlocked characters for deterministic fallback.
    final unlockedCharacters = characters.where((c) {
      return UnlockRule(
        requiredLevel: c.requiredLevel,
        requiredCoins: c.requiredCoins,
        requiredXP: c.requiredXP,
      ).isUnlocked(level: userLevel, coins: userCoins, xp: userXp);
    }).toList(growable: false);

    if (unlockedCharacters.isEmpty) {
      return characters.first;
    }

    // Requirement 7/8: use selected character only if it is unlocked.
    if (storedCharacterId != null) {
      final stored = characters.firstWhere(
        (c) => c.id == storedCharacterId,
        orElse: () => unlockedCharacters.first,
      );

      final storedUnlocked = UnlockRule(
        requiredLevel: stored.requiredLevel,
        requiredCoins: stored.requiredCoins,
        requiredXP: stored.requiredXP,
      ).isUnlocked(level: userLevel, coins: userCoins, xp: userXp);

      if (storedUnlocked) return stored;
    }

    // Default to the first unlocked character.
    return unlockedCharacters.first;
  }

  // Trigger AR celebration animation with better effects
  Future<void> triggerQuestCompletionCelebration(
    BuildContext context, {
    required int userLevel,
    required int userCoins,
    required int userXp,
    required String questType,
    required int xpGained,
    required int coinsGained,
    required bool leveledUp,
  }) async {
    try {
      final character = await getCharacterForQuestCompletion(
        userLevel: userLevel,
        userCoins: userCoins,
        userXp: userXp,
        questType: questType,
      );

      // Requirement 4/6: only play stored animation if it is unlocked; else idle.
      final storedAnimationId = await _selectionStorage.getSelectedAnimationId();
      final unlockedAnimationIds = await _selectionStorage.getUnlockedAnimationIds();

      CharacterAnimMode initialAnimationMode = CharacterAnimMode.idle;
      if (storedAnimationId != null) {
        final isIdle = storedAnimationId.toLowerCase() == 'idle';
        final selectedMode = isIdle ? CharacterAnimMode.idle : CharacterAnimMode.action;

        // If we have unlocked animation info, respect it. If not (empty list), fall back to character unlock.
        final characterUnlocked = UnlockRule(
          requiredLevel: character.requiredLevel,
          requiredCoins: character.requiredCoins,
          requiredXP: character.requiredXP,
        ).isUnlocked(level: userLevel, coins: userCoins, xp: userXp);

        final hasUnlockList = unlockedAnimationIds.isNotEmpty;
        final selectedAnimUnlocked = hasUnlockList
            ? unlockedAnimationIds.contains(storedAnimationId)
            : characterUnlocked;

        if (selectedAnimUnlocked) {
          initialAnimationMode = selectedMode;
        }
      }
      
      // Show immediate celebration dialog with auto-animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return _EnhancedQuestCompletionDialog(
            character: character,
            xpGained: xpGained,
            coinsGained: coinsGained,
            leveledUp: leveledUp,
            onLaunchAR: () {
              Navigator.of(context).pop();
              _launchARCelebrationScreen(context, character, initialAnimationMode);
            },
            onSkip: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('ARTrigger: Error triggering celebration: $e');
      debugPrint('ARTrigger: Stack trace: $stackTrace');
    }
  }

  void _launchARCelebrationScreen(
    BuildContext context,
    ARCharacterItem character,
    CharacterAnimMode initialAnimationMode,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ARCelebrationScreen(
          character: character,
          initialAnimation: initialAnimationMode,
        ),
      ),
    );
  }
}

// Enhanced celebration dialog with animations
class _EnhancedQuestCompletionDialog extends StatefulWidget {
  final ARCharacterItem character;
  final int xpGained;
  final int coinsGained;
  final bool leveledUp;
  final VoidCallback onLaunchAR;
  final VoidCallback onSkip;

  const _EnhancedQuestCompletionDialog({
    required this.character,
    required this.xpGained,
    required this.coinsGained,
    required this.leveledUp,
    required this.onLaunchAR,
    required this.onSkip,
  });

  @override
  State<_EnhancedQuestCompletionDialog> createState() => _EnhancedQuestCompletionDialogState();
}

class _EnhancedQuestCompletionDialogState extends State<_EnhancedQuestCompletionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    print(' [DIALOG] Enhanced dialog initState called');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    print('🎉 [DIALOG] Starting animation controller');
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(' [DIALOG] Enhanced dialog build called');
    
    //  FIXED: Get screen size to prevent overflow
    final screenSize = MediaQuery.of(context).size;
    final maxDialogWidth = screenSize.width * 0.9;
    final maxDialogHeight = screenSize.height * 0.8;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: maxDialogWidth,
                maxHeight: maxDialogHeight,
              ),
              padding: const EdgeInsets.all(20), //  Reduced padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.character.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.character.gradient.first.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: SingleChildScrollView( //  Added scroll view
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🎉 Animated Character Icon
                    Transform.rotate(
                      angle: _sparkleAnimation.value * 2 * pi,
                      child: Container(
                        width: 80, //  Reduced from 100
                        height: 80, //  Reduced from 100
                        decoration: BoxDecoration(
                          color: AppColors.whiteBackground.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.whiteBackground,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.whiteBackground.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.character.Icon,
                          color: AppColors.whiteBackground,
                          size: 40, //  Reduced from 50
                        ),
                      ),
                    ),
                    const SizedBox(height: 16), //  Reduced from 20
                    
                    //  Title with fade animation
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.leveledUp ? ' LEVEL UP! ' : ' QUEST COMPLETE! ',
                        style: AppTextStyles.subheading.copyWith(
                          color: AppColors.whiteBackground,
                          fontSize: 22, //  Reduced from 26
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2, //  Added max lines
                        overflow: TextOverflow.ellipsis, //  Added overflow handling
                      ),
                    ),
                    const SizedBox(height: 10), //  Reduced from 12
                    
                    // Character Name
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        '${widget.character.name} celebrates with ${widget.character.actionLabel}!',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.whiteBackground.withOpacity(0.95),
                          fontSize: 14, //  Reduced from 16
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2, //  Added max lines
                        overflow: TextOverflow.ellipsis, //  Added overflow handling
                      ),
                    ),
                    const SizedBox(height: 16), //  Reduced from 24
                    
                    //  Enhanced Rewards Display
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16), //  Reduced from 20
                        decoration: BoxDecoration(
                          color: AppColors.whiteBackground.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.whiteBackground.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildAnimatedRewardItem(Icons.star, '+${widget.xpGained} XP', AppColors.whiteBackground),
                                _buildAnimatedRewardItem(Icons.monetization_on, '+${widget.coinsGained} Coins', AppColors.whiteBackground),
                              ],
                            ),
                            if (widget.leveledUp) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.whiteBackground,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.character.gradient.first.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  ' NEW LEVEL UNLOCKED! ',
                                  style: AppTextStyles.caption.copyWith(
                                    color: widget.character.gradient.first,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12, //  Reduced from 14
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), //  Reduced from 28
                    
                    // 🎮 Action Buttons
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.whiteBackground.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: widget.onSkip,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.whiteBackground.withOpacity(0.1),
                                      foregroundColor: AppColors.whiteBackground,
                                      padding: const EdgeInsets.symmetric(vertical: 12), // 🚀 Reduced from 14
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Skip',
                                      style: AppTextStyles.button.copyWith(
                                        color: AppColors.whiteBackground,
                                        fontSize: 14, //  Reduced from 16
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.whiteBackground.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: widget.onLaunchAR,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.whiteBackground,
                                      foregroundColor: widget.character.gradient.first,
                                      padding: const EdgeInsets.symmetric(vertical: 12), // 🚀 Reduced from 14
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.view_in_ar, size: 18),
                                        const SizedBox(width: 6), //  Reduced from 8
                                        Flexible( //  Added Flexible for text wrapping
                                          child: Text(
                                            'View Animation',
                                            style: AppTextStyles.button.copyWith(
                                              color: widget.character.gradient.first,
                                              fontSize: 14, //  Reduced from 16
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedRewardItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.whiteBackground.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

//  ENHANCED: AR Celebration Screen with ONLY action animations
class _ARCelebrationScreen extends StatefulWidget {
  final ARCharacterItem character;
  final CharacterAnimMode initialAnimation;

  const _ARCelebrationScreen({
    required this.character,
    required this.initialAnimation,
  });

  @override
  State<_ARCelebrationScreen> createState() => _ARCelebrationScreenState();
}

class _ARCelebrationScreenState extends State<_ARCelebrationScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _fadeAnimation; //  Added missing fade animation
  
  late CharacterAnimMode _currentMode;
  bool _showCelebrationEffects = true;
  int _celebrationCount = 0;

  @override
  void initState() {
    super.initState();

    _currentMode = widget.initialAnimation;
    
    //  Celebration animation controller
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    //  Particle effects controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
    ));
    
    // Start animations immediately
    _celebrationController.forward();
    _particleController.repeat(reverse: true);
    
    // Loop celebration animations
    _startCelebrationLoop();
  }

  void _startCelebrationLoop() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _celebrationCount++;
        print(' [CELEBRATION] Loop #$_celebrationCount for ${widget.character.name}');
        
        _celebrationController.reset();
        _celebrationController.forward();
        
        // Continue looping
        _startCelebrationLoop();
      }
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          //  Enhanced Background with celebration effects
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  widget.character.gradient.first.withOpacity(0.2),
                  widget.character.gradient.last.withOpacity(0.1),
                  AppColors.lightBackground,
                ],
              ),
            ),
            child: _buildParticleEffects(),
          ),
          
          //  Character Display Area
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //  Animated Character Container
                AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 350,
                        height: 350,
                        decoration: BoxDecoration(
                          color: AppColors.whiteBackground,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: widget.character.gradient.first.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                          border: Border.all(
                            color: widget.character.gradient.first.withOpacity(0.4),
                            width: 3,
                          ),
                        ),
                        child: Stack(
                          children: [
                            //  Character Model Viewer
                            Positioned.fill(
                              child: _buildCharacterModel(),
                            ),
                            
                            //  Celebration Overlay Effects
                            if (_showCelebrationEffects)
                              Positioned.fill(
                                child: _buildCelebrationOverlay(),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
                
                //  Animation Status with enhanced styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: widget.character.gradient.first.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: widget.character.gradient.first.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _celebrationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 0.1,
                        child: Text(
                          '${widget.character.actionLabel}! 🎉',
                          style: AppTextStyles.body.copyWith(
                            color: widget.character.gradient.first,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                //  Celebration Counter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.character.gradient.first.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.character.gradient.first.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Celebration Loop #$_celebrationCount',
                    style: AppTextStyles.caption.copyWith(
                      color: widget.character.gradient.first,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          //  Close Button
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.whiteBackground,
                shape: BoxShape.circle,
                boxShadow: AppShadows.cardShadow,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Floating Celebration Text
          if (_showCelebrationEffects)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_celebrationController.value * 0.3),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          ' VICTORY CELEBRATION! ',
                          style: AppTextStyles.heading.copyWith(
                            color: widget.character.gradient.first,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: widget.character.gradient.first.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharacterModel() {
    final bool isIdle = _currentMode == CharacterAnimMode.idle;
    final String src = isIdle ? widget.character.idleModel : widget.character.actionModel;
    final String modelPathForAnim = src;

    return ModelViewer(
      key: ValueKey('${widget.character.id}_celebration'),
      src: src,
      alt: isIdle ? '${widget.character.name} Idle' : '${widget.character.name} ${widget.character.actionLabel}',

      //  ANIMATION - Always action mode with correct animation names
      autoPlay: true,
      animationName: _getCorrectAnimationName(modelPathForAnim),

      // AR Settings
      ar: true,
      arModes: const ['scene-viewer', 'webxr', 'quick-look'],
      arScale: ArScale.fixed,

      // Viewer Settings
      cameraControls: true,
      autoRotate: true,
      backgroundColor: Colors.transparent,

      // Remove overlays
      interactionPrompt: InteractionPrompt.none,
      loading: Loading.eager,

      // Camera Settings
      cameraOrbit: "0deg 75deg 2.5m",
      minCameraOrbit: "auto auto 2m",
      maxCameraOrbit: "auto auto 5m",

      shadowIntensity: 1.2,
      shadowSoftness: 0.8,
      exposure: 1.2,
    );
  }

  //  HELPER: Get correct animation name based on model file
  String _getCorrectAnimationName(String modelPath) {
    if (modelPath.contains('fightingpose')) {
      return 'fightingpose'; // For warrior
    } else if (modelPath.contains('1HipHop')) {
      return 'HipHop'; // For scholar  
    } else if (modelPath.contains('3Excited')) {
      return 'Excited'; // For explorer
    } else if (modelPath.contains('1Dancing')) {
      return 'Dancing'; // Alternative dancing animation
    } else if (modelPath.contains('3HipHop')) {
      return 'HipHop'; // Alternative hip hop
    } else if (modelPath.contains('clap')) {
      return 'Clap';
    } else if (modelPath.contains('salsa')) {
      return 'Salsa';
    } else if (modelPath.contains('victory')) {
      return 'Victory';
    } else {
      return 'Idle'; // Fallback
    }
  }

  Widget _buildCelebrationOverlay() {
    return CustomPaint(
      painter: _CelebrationPainter(
        progress: _celebrationController.value,
        particleProgress: _particleAnimation.value,
        color: widget.character.gradient.first,
      ),
      child: Container(),
    );
  }

  Widget _buildParticleEffects() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            progress: _particleAnimation.value,
            color: widget.character.gradient.first,
          ),
          child: Container(),
        );
      },
    );
  }
}

//  Enhanced Celebration Painter
class _CelebrationPainter extends CustomPainter {
  final double progress;
  final double particleProgress;
  final Color color;

  _CelebrationPainter({
    required this.progress,
    required this.particleProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6 * (1 - progress))
      ..style = PaintingStyle.fill;

    // Draw celebration particles in circular pattern
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30.0) * (3.14159 / 180);
      final radius = 80.0 + (progress * 150);
      final x = size.width / 2 + radius * cos(angle);
      final y = size.height / 2 + radius * sin(angle);
      
      canvas.drawCircle(
        Offset(x, y),
        12.0 * (1 - progress) + particleProgress * 5,
        paint,
      );
    }

    // Draw sparkles
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0) * (3.14159 / 180);
      final radius = 120.0 + (particleProgress * 100);
      final x = size.width / 2 + radius * cos(angle + progress * 2);
      final y = size.height / 2 + radius * sin(angle + progress * 2);
      
      final sparklePaint = Paint()
        ..color = color.withOpacity(0.8 * particleProgress)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 4.0, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.particleProgress != particleProgress;
  }
}

//  Particle Effects Painter
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3 * progress)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.04);
      final y = size.height * 0.5 + sin(progress * 2 * pi + i) * 100;
      
      canvas.drawCircle(
        Offset(x, y),
        3.0 * progress,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
