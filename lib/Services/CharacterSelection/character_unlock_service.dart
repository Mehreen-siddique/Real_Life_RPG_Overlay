import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../CharacterSelection/character_selection_service.dart';
import '../../ArView/AR_Screen.dart';

/// Service to track character unlock state and notify when new characters become unlocked
class CharacterUnlockService {
  static const String _lastUnlockedCharactersKey = 'last_unlocked_characters';
  
  static final CharacterUnlockService _instance = CharacterUnlockService._internal();
  factory CharacterUnlockService() => _instance;
  CharacterUnlockService._internal();

  // Unused Firebase fields removed to clean up warnings

  /// Check for newly unlocked characters and return them
  Future<List<ARCharacterItem>> checkForNewUnlocks(
    int userLevel,
    int userCoins,
    int userXp,
  ) async {
    final characterService = CharacterSelectionService.instance;
    final allCharacters = characterService.getAllCharacters();
    final prefs = await SharedPreferences.getInstance();
    
    // Get previously unlocked character IDs
    final previouslyUnlocked = prefs.getStringList(_lastUnlockedCharactersKey) ?? [];
    
    final newlyUnlocked = <ARCharacterItem>[];
    
    for (final character in allCharacters) {
      if (previouslyUnlocked.contains(character.id)) continue;
      
      // Check if character is now unlocked
      if (userLevel >= character.requiredLevel &&
          userCoins >= character.requiredCoins &&
          userXp >= character.requiredXP) {
        newlyUnlocked.add(character);
      }
    }
    
    // Update stored unlocked characters if any new unlocks
    if (newlyUnlocked.isNotEmpty) {
      final updatedUnlocked = [...previouslyUnlocked];
      for (final character in newlyUnlocked) {
        if (!updatedUnlocked.contains(character.id)) {
          updatedUnlocked.add(character.id);
        }
      }
      await prefs.setStringList(_lastUnlockedCharactersKey, updatedUnlocked);
    }
    
    return newlyUnlocked;
  }

  /// Show character unlock celebration dialog
  Future<void> showUnlockCelebration(
    BuildContext context,
    List<ARCharacterItem> newlyUnlocked,
    int userLevel,
    int userCoins,
  ) async {
    if (newlyUnlocked.isEmpty || !context.mounted) return;

    for (final character in newlyUnlocked) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => _buildUnlockDialog(context, character, userLevel, userCoins),
      );
    }
  }

  Widget _buildUnlockDialog(
    BuildContext context,
    ARCharacterItem character,
    int userLevel,
    int userCoins,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
 constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: character.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: character.gradient.first.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(character.Icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              '🎉 CHARACTER UNLOCKED!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: character.gradient.first,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Character name
            Text(
              character.name,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: character.gradient,
                  ).createShader(Rect.fromLTWH(0, 0, 200, 40)),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Character class
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: character.gradient),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                character.characterClass,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Unlock requirements met
            Text(
              'Requirements Met:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (character.requiredLevel > 1)
                  _buildRequirementChip(Icons.stars, 'Level ${character.requiredLevel}'),
                if (character.requiredCoins > 0) ...[
                  const SizedBox(width: 8),
                  _buildRequirementChip(Icons.monetization_on, '${character.requiredCoins} coins'),
                ],
              ],
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Later',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _selectCharacterAndNavigate(context, character);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: character.gradient.first,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Select Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _selectCharacterAndNavigate(BuildContext context, ARCharacterItem character) {
    final characterService = CharacterSelectionService.instance;
    characterService.selectCharacter(character);
    
    // Navigate to AR screen
    Navigator.pushReplacementNamed(context, '/ar_screen');
  }

  /// Reset unlock tracking (useful for testing or account reset)
  Future<void> resetUnlockTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUnlockedCharactersKey);
  }

  /// Get list of all unlocked character IDs
  Future<List<String>> getUnlockedCharacterIds(
    int userLevel,
    int userCoins,
    int userXp,
  ) async {
    final characterService = CharacterSelectionService.instance;
    final allCharacters = characterService.getAllCharacters();
    
    return allCharacters
        .where((c) =>
            userLevel >= c.requiredLevel &&
            userCoins >= c.requiredCoins &&
            userXp >= c.requiredXP)
        .map((c) => c.id)
        .toList();
  }
}
