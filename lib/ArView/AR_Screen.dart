

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Services/DataServices/dataServices.dart';
import '../Services/CharacterSelection/character_selection_service.dart';
import '../Services/CharacterSelection/ar_character_selection_storage.dart';
import '../models/unlock_rule.dart';

import '../../utils/constants.dart';


class ARCharacterItem {
  final String id;
  final String name;
  final String characterClass;
  final String thumbnail;

  /// to store icon of showing character
  final IconData Icon;
  /// GLB model for idle animation.
  final String idleModel;

  /// GLB model for action animation.
  final String actionModel;

  /// Label for action button
  final String actionLabel;

  /// Theme gradient for UI accent
  final List<Color> gradient;
  final int requiredLevel;
  final int requiredCoins;
  final int requiredXP;

  const ARCharacterItem({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.idleModel,
    required this.actionModel,
    required this.actionLabel,
    required this.gradient,
    required this.Icon,
    required this.thumbnail,
    this.requiredLevel = 1,
    this.requiredCoins = 0,
    this.requiredXP = 0,
  });
}

enum CharacterAnimMode { idle, action }

class ARCharacterScreen extends StatefulWidget {
  const ARCharacterScreen({Key? key}) : super(key: key);

  @override
  State<ARCharacterScreen> createState() => _ARCharacterScreenState();
}

class _ARCharacterScreenState extends State<ARCharacterScreen> {
  final CharacterSelectionService _characterService = CharacterSelectionService.instance;
  final ARCharacterSelectionStorage _selectionStorage = ARCharacterSelectionStorage();

  late final List<ARCharacterItem> _characters;

  late ARCharacterItem _selectedCharacter;

  String? _storedSelectedCharacterId;
  bool _hasExplicitCharacterSelection = false;
  bool _isLocalSelectionLoaded = false;

  int? _lastUnlockFingerprint;
  int? _lastSavedUnlockedFingerprint;

  @override
  void initState() {
    super.initState();
    _characters = _characterService.getAllCharacters();
    _selectedCharacter = _characterService.selectedCharacter;
    _loadLocalSelection();
  }

  Future<void> _loadLocalSelection() async {
    final storedCharacterId = await _selectionStorage.getSelectedCharacterId();

    final resolvedCharacter = storedCharacterId == null
        ? _selectedCharacter
        : _characters.firstWhere((c) => c.id == storedCharacterId, orElse: () => _selectedCharacter);

    if (!mounted) return;
    setState(() {
      _storedSelectedCharacterId = storedCharacterId;
      _hasExplicitCharacterSelection = storedCharacterId != null;
      _selectedCharacter = resolvedCharacter;
      _isLocalSelectionLoaded = true;
    });
  }

  bool _isCharacterUnlocked(ARCharacterItem item, int level, int coins, int xp) {
    return UnlockRule(
      requiredLevel: item.requiredLevel,
      requiredCoins: item.requiredCoins,
      requiredXP: item.requiredXP,
    ).isUnlocked(level: level, coins: coins, xp: xp);
  }

  bool _isAnimationUnlockedForMode(
    ARCharacterItem character,
    CharacterAnimMode mode,
    int level,
    int coins,
    int xp,
  ) {
    // Keep unlock progression simple: if the character is unlocked, both idle and action are selectable.
    // Animation lock UI still shows up correctly when the selected character is locked.
    return _isCharacterUnlocked(character, level, coins, xp);
  }

  String _animationIdForMode(CharacterAnimMode mode) {
    return mode == CharacterAnimMode.idle ? 'idle' : 'action';
  }

  String _modelForMode(ARCharacterItem character, CharacterAnimMode mode) {
    return mode == CharacterAnimMode.idle ? character.idleModel : character.actionModel;
  }

  String _displayLabelForMode(ARCharacterItem character, CharacterAnimMode mode) {
    return mode == CharacterAnimMode.idle ? 'Idle' : character.actionLabel;
  }

  String _animationNameForModel(String modelPath, ARCharacterItem character) {
    // Filename heuristics to match typical animationName values inside GLB files.
    // Try to extract animation name from filename first
    final fileName = modelPath.split('/').last.replaceAll('.glb', '').toLowerCase();
    
    // Common animation name mappings
    if (fileName.contains('fightingpose')) return 'fightingpose';
    if (fileName.contains('hiphop') || fileName.contains('1hiphop') || fileName.contains('3hiphop')) return 'HipHop';
    if (fileName.contains('excited') || fileName.contains('3excited')) return 'Excited';
    if (fileName.contains('dancing') || fileName.contains('1dancing')) return 'Dancing';
    if (fileName.contains('clap')) return 'Clap';
    if (fileName.contains('salsa')) return 'Salsa';
    if (fileName.contains('victory')) return 'Victory';
    if (fileName.contains('standup')) return 'Standup';
    if (fileName.contains('sitting')) return 'Sitting';
    if (fileName.contains('swing')) return 'Swing';
    
    // Fallback: use action label if available, otherwise try to use the filename as animation name
    if (character.actionLabel.isNotEmpty && character.actionLabel != 'Action') {
      return character.actionLabel;
    }
    
    // Last resort: return empty string to let ModelViewer use default animation
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dataService = Provider.of<DataService>(context);
    final user = dataService.currentUserData;
    final userLevel = user?.level ?? 1;
    final userCoins = user?.coins ?? 0;
    final userXp = user?.currentXP ?? 0;

    final unlockFingerprint = userLevel * 1000000 + userCoins * 1000 + userXp;

    final selectedCharacterUnlocked =
        _isCharacterUnlocked(_selectedCharacter, userLevel, userCoins, userXp);

    final unlockedCharacters = _characters
        .where((c) => _isCharacterUnlocked(c, userLevel, userCoins, userXp))
        .toList(growable: false);

    final fallbackUnlockedCharacter =
        unlockedCharacters.isNotEmpty ? unlockedCharacters.first : _characters.first;

    // Requirement 8: if there is no local selection, fall back to a default unlocked character.
    final shouldFallbackToDefaultUnlocked =
        _isLocalSelectionLoaded && !_hasExplicitCharacterSelection && !selectedCharacterUnlocked;

    if (shouldFallbackToDefaultUnlocked && _lastUnlockFingerprint != unlockFingerprint) {
      _lastUnlockFingerprint = unlockFingerprint;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _persistFallbackSelection(fallbackUnlockedCharacter);
      });
    }

    final effectiveCharacter = shouldFallbackToDefaultUnlocked
        ? fallbackUnlockedCharacter
        : _selectedCharacter;

    final effectiveCharacterUnlocked =
        _isCharacterUnlocked(effectiveCharacter, userLevel, userCoins, userXp);

    final actionUnlocked =
        _isAnimationUnlockedForMode(effectiveCharacter, CharacterAnimMode.action, userLevel, userCoins, userXp);

    final selectedAnimUnlocked = actionUnlocked;

    final unlockedCharacterIds =
        unlockedCharacters.map((e) => e.id).toList(growable: false);
    final unlockedAnimationIds = <String>[
      if (actionUnlocked) _animationIdForMode(CharacterAnimMode.action),
    ];

    if (_lastSavedUnlockedFingerprint != unlockFingerprint) {
      _lastSavedUnlockedFingerprint = unlockFingerprint;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _persistUnlockedLists(
          unlockedCharacterIds: unlockedCharacterIds,
          unlockedAnimationIds: unlockedAnimationIds,
        );
      });
    }

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppSizes.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              SizedBox(height: AppSizes.paddingSM),

              _viewerCard(
                context,
                character: effectiveCharacter,
                animMode: CharacterAnimMode.action,
                animUnlocked: selectedAnimUnlocked,
                characterUnlocked: effectiveCharacterUnlocked,
              ),
              SizedBox(height: AppSizes.paddingMD),

              _sectionHeader(selectedCharacter: effectiveCharacter),
              SizedBox(height: AppSizes.paddingSM),

              _characterListRow(userLevel, userCoins, userXp, selectedCharacter: effectiveCharacter),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _persistFallbackSelection(ARCharacterItem character) async {
    if (!mounted) return;

    await _characterService.selectCharacter(character);
    await _selectionStorage.setSelectedCharacterId(character.id);

    if (!mounted) return;
    setState(() {
      _storedSelectedCharacterId = character.id;
      _hasExplicitCharacterSelection = true;
      _selectedCharacter = character;
    });
  }

  Future<void> _persistUnlockedLists({
    required List<String> unlockedCharacterIds,
    required List<String> unlockedAnimationIds,
  }) async {
    // Fire-and-forget persistence for unlock UI. If storage is busy, we don't block the UI.
    await _selectionStorage.setUnlockedCharacterIds(unlockedCharacterIds);
    await _selectionStorage.setUnlockedAnimationIds(unlockedAnimationIds);
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingSM,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'AR Character',
              textAlign: TextAlign.center,
              style: AppTextStyles.screenHeading.copyWith(fontSize: 20),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _viewerCard(
    BuildContext context, {
    required ARCharacterItem character,
    required CharacterAnimMode animMode,
    required bool animUnlocked,
    required bool characterUnlocked,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Container(
        height: 420,
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: AppShadows.cardShadowLarge,
          border: Border.all(
            color: character.gradient.first.withOpacity(0.30),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      character.gradient.first.withOpacity(0.10),
                      character.gradient.last.withOpacity(0.05),
                      AppColors.whiteBackground,
                    ],
                  ),
                ),
              ),

              ModelViewer(
                key: ValueKey('${character.id}_${animMode.name}'),
                src: _modelForMode(character, animMode),
                alt: character.name,

                // ANIMATION - Enable auto play for action animations
                autoPlay: true,
                animationName: _animationNameForModel(
                  _modelForMode(character, animMode),
                  character,
                ),

                // AR - Only enabled for unlocked characters
                ar: characterUnlocked,
                arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                arScale: ArScale.fixed,

                // Viewer
                cameraControls: true,
                autoRotate: false,
                backgroundColor: Colors.transparent,

                // Remove overlays
                interactionPrompt: InteractionPrompt.none,
                loading: Loading.eager,

                // Camera
                cameraOrbit: "0deg 75deg 3m",
                minCameraOrbit: "auto auto 1.8m",
                maxCameraOrbit: "auto auto 6m",

                shadowIntensity: 1.0,
                shadowSoftness: 0.8,
                exposure: 1.15,
              ),

              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSM + 4,
                    vertical: AppSizes.paddingXS + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(color: character.gradient.first, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill, size: 16, color: character.gradient.first),
                      SizedBox(width: 6),
                      Text(
                        _displayLabelForMode(character, animMode),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: character.gradient.first,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // AR Badge - only shown for unlocked characters
              if (characterUnlocked)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.view_in_ar,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AR Ready',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!characterUnlocked)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Locked',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({required ARCharacterItem selectedCharacter}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Choose Character', style: AppTextStyles.subheading.copyWith(fontSize: 16)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSM, vertical: AppSizes.paddingXS),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryPurple,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Text(
              '${_characters.indexWhere((c) => c.id == selectedCharacter.id) + 1}/${_characters.length}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _characterListRow(int userLevel, int userCoins, int userXp, {required ARCharacterItem selectedCharacter}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
        itemCount: _characters.length,
        itemBuilder: (context, index) {
          final c = _characters[index];
          final isSelected = c.id == selectedCharacter.id;
          final unlocked = userLevel >= c.requiredLevel &&
              userCoins >= c.requiredCoins &&
              userXp >= c.requiredXP;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCharacter = c;
                  _hasExplicitCharacterSelection = true;
                });
                if (unlocked) {
                  _storedSelectedCharacterId = c.id;
                  _characterService.selectCharacter(c);
                  _selectionStorage.setSelectedCharacterId(c.id);
                  _selectionStorage.setSelectedAnimationId(
                    _animationIdForMode(CharacterAnimMode.action),
                  );
                }
              },
              child: AnimatedContainer(
              duration: AppDurations.normal,
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(colors: c.gradient) : null,
                color: unlocked ? (isSelected ? null : AppColors.lightBackground) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(
                  color: isSelected ? c.gradient.first : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: c.gradient.first.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: Image.asset(
                          c.thumbnail,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.statsBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(c.Icon, color: AppColors.primaryPurple),
                            );
                          },
                        ),
                      ),
                      if (!unlocked)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock, size: 10, color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.characterClass,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: unlocked
                          ? (isSelected ? AppColors.textWhite : AppColors.textDark)
                          : Colors.grey.shade700,
                    ),
                  ),
                  if (!unlocked) ...[
                    const SizedBox(height: 4),
                    Text(
                      c.requiredCoins > 0
                          ? 'Lvl ${c.requiredLevel}+ ${c.requiredCoins} coins'
                          : 'Lvl ${c.requiredLevel}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (isSelected && unlocked) ...[
                    const SizedBox(height: 4),
                    Icon(Icons.check_circle, size: 14, color: AppColors.textWhite),
                  ],
                ],
              ),
            ),
            ),
          );
        },
      ),
      ),
    );
  }
}









