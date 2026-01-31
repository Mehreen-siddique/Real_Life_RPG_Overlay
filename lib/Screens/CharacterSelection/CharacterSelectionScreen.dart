import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_life_rpg/Services/CharacterSelection/character_selection_service.dart';
import 'package:real_life_rpg/ArView/AR_Screen.dart';
import 'package:real_life_rpg/utils/constants.dart';

///  Screen for users to select their preferred character
/// Shows all available characters with their models and animations
class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  String? _selectedCharacterId;
  bool _isLoading = false;
  List<ARCharacterItem> _characters = [];
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCharacters();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _userStream = FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
    }
  }
  
  void _initializeAnimations() {
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeIn,
    ));
    
    _selectionController.forward();
  }
  
  Future<void> _loadCharacters() async {
    setState(() => _isLoading = true);
    
    try {
      final characterService = CharacterSelectionService.instance;
      await characterService.initialize();
      
      final characters = characterService.getAllCharacters();
      final selectedCharacter = characterService.selectedCharacter;
      
      setState(() {
        _characters = characters;
        _selectedCharacterId = selectedCharacter.id;
        _isLoading = false;
      });
      
      print('🎭 [CHAR-SELECT] Loaded ${characters.length} characters');
      print('🎭 [CHAR-SELECT] Selected: ${selectedCharacter.name}');
    } catch (e) {
      print('🚨 [CHAR-SELECT] Error loading characters: $e');
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _selectCharacter(ARCharacterItem character) async {
    setState(() => _selectedCharacterId = character.id);
    
    // Play selection animation
    _selectionController.reset();
    _selectionController.forward();
    
    try {
      final characterService = CharacterSelectionService.instance;
      await characterService.selectCharacter(character);
      
      print('🎭 [CHAR-SELECT] Character selected: ${character.name}');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${character.name} selected! 🎉'),
            backgroundColor: character.gradient.first,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('🚨 [CHAR-SELECT] Error selecting character: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting character. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Choose Your Character',
          style: TextStyle(
            color: AppColors.whiteBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.whiteBackground),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryPurple,
              ),
            )
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _userStream,
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final userLevel = (data?['level'] as num?)?.toInt() ?? 1;
                final userCoins = (data?['coins'] as num?)?.toInt() ?? 0;
                final userXP = (data?['currentXP'] as num?)?.toInt() ?? 0;
                return _buildCharacterGrid(userLevel, userCoins, userXP);
              },
            ),
    );
  }
  
  Widget _buildCharacterGrid(int userLevel, int userCoins, int userXP) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Select your character for AR celebrations',
            style: AppTextStyles.subheading.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This character will appear when you complete quests!',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 24),
          
          // Character Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _characters.length,
            itemBuilder: (context, index) {
              final character = _characters[index];
              final isSelected = character.id == _selectedCharacterId;
              
              return _buildCharacterCardWithStats(character, isSelected, userLevel, userCoins, userXP);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCharacterId != null
                  ? () {
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: AppColors.whiteBackground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Confirm Selection',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.whiteBackground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCharacterCardWithStats(
    ARCharacterItem character,
    bool isSelected,
    int userLevel,
    int userCoins,
    int userXP,
  ) {
    final isUnlocked = userLevel >= character.requiredLevel &&
        userCoins >= character.requiredCoins &&
        userXP >= character.requiredXP;

    return AnimatedBuilder(
      animation: _selectionController,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () {
              if (!isUnlocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Locked: requires Level ${character.requiredLevel}, '
                      '${character.requiredCoins} coins and ${character.requiredXP} XP',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              _selectCharacter(character);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: character.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.whiteBackground
                      : Colors.transparent,
                  width: isSelected ? 3 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: character.gradient.first.withOpacity(isUnlocked ? 0.3 : 0.1),
                    blurRadius: isSelected ? 20 : 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Character Icon/Thumbnail
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.whiteBackground.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.whiteBackground.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      character.Icon,
                      color: AppColors.whiteBackground,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Character Name
                  Text(
                    character.name,
                    style: AppTextStyles.subheading.copyWith(
                      color: AppColors.whiteBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Character Class
                  Text(
                    character.characterClass,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.whiteBackground.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Action Label / Lock status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.whiteBackground.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isUnlocked ? character.actionLabel : 'Locked',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.whiteBackground,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  if (!isUnlocked) ...[
                    const SizedBox(height: 8),
                    const Icon(Icons.lock, color: Colors.white, size: 20),
                  ],
                  if (isSelected && isUnlocked) ...[
                    const SizedBox(height: 8),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.whiteBackground,
                      size: 24,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }
}
