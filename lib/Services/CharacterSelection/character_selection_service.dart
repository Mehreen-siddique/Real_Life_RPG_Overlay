import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ArView/AR_Screen.dart';

///  Service to manage user's selected character preference
/// Tracks which character the user wants to see in AR celebrations
class CharacterSelectionService {
  static const String _selectedCharacterKey = 'selected_character_id';
  static CharacterSelectionService? _instance;
  static CharacterSelectionService get instance => _instance ??= CharacterSelectionService._();
  
  CharacterSelectionService._();
  
  ARCharacterItem? _selectedCharacter;
  ARCharacterItem get selectedCharacter => _selectedCharacter ?? _getDefaultCharacter();
  
  ///  Initialize the service and load user's character preference
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final characterId = prefs.getString(_selectedCharacterKey);
      
      if (characterId != null) {
        _selectedCharacter = _getCharacterById(characterId);
        print(' [CHAR-SELECT] Loaded selected character: ${_selectedCharacter?.name}');
      } else {
        _selectedCharacter = _getDefaultCharacter();
        print(' [CHAR-SELECT] Using default character: ${_selectedCharacter?.name}');
      }
    } catch (e) {
      print(' [CHAR-SELECT] Error loading character preference: $e');
      _selectedCharacter = _getDefaultCharacter();
    }
  }
  
  ///  Set user's selected character and save preference
  Future<void> selectCharacter(ARCharacterItem character) async {
    try {
      _selectedCharacter = character;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedCharacterKey, character.id);
      
      print(' [CHAR-SELECT] Character selected: ${character.name} (${character.id})');
      print(' [CHAR-SELECT] Character saved to preferences');
    } catch (e) {
      print(' [CHAR-SELECT] Error saving character preference: $e');
    }
  }
  
  ///  Get all available characters for selection
  List<ARCharacterItem> getAllCharacters() {
    return [
      const ARCharacterItem(
        id: 'scholar',
        name: 'Scholar Ali',
        characterClass: 'Scholar',
        Icon: Icons.shield,
        idleModel: 'assets/images/4idle.glb',
        actionModel: 'assets/models/1HipHop.glb',
        actionLabel: 'Hip Hop Dance',
        thumbnail: 'assets/images/scholor.jpg',
        gradient: [Color(0xFF667EEA), Color(0xFF764BA2)], // Blue to Purple
        requiredLevel: 1, // FREE at level 1
        requiredCoins: 0,
      ),
      const ARCharacterItem(
        id: 'explorer',
        name: 'Explorer Fatima',
        characterClass: 'Explorer',
        Icon: Icons.auto_fix_high,
        idleModel: 'assets/images/3idle.glb',
        actionModel: 'assets/models/3Excited.glb',
        actionLabel: 'Excited Jump',
        thumbnail: 'assets/images/explorero.jpg',
        gradient: [Color(0xFFF093FB), Color(0xFFF5576C)], // Pink to Red
        requiredLevel: 3,
        requiredCoins: 200,
      ),
      const ARCharacterItem(
        id: 'victory',
        name: 'Victory Champ',
        characterClass: 'Champion',
        Icon: Icons.emoji_events,
        idleModel: 'assets/models/sitting.glb',
        actionModel: 'assets/models/victory.glb',
        actionLabel: 'Victory',
        thumbnail: '🏆',
        gradient: [Color(0xFFF6D365), Color(0xFFFDA085)],
        requiredLevel: 4,
        requiredCoins: 300,
      ),
      const ARCharacterItem(
        id: 'hiphop2',
        name: 'Street Dancer',
        characterClass: 'HipHop',
        Icon: Icons.sports_basketball,
        idleModel: 'assets/images/2idle.glb',
        actionModel: 'assets/models/3HipHop.glb',
        actionLabel: 'Street Dance',
        thumbnail: 'assets/images/explorero.jpg',
        gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
        requiredLevel: 5,
        requiredCoins: 500,
      ),
      const ARCharacterItem(
        id: 'swing',
        name: 'Swing Master',
        characterClass: 'Swing',
        Icon: Icons.swap_horiz,
        idleModel: 'assets/images/3idle.glb',
        actionModel: 'assets/models/swing.glb',
        actionLabel: 'Swing',
        thumbnail: 'assets/images/scholor.jpg',
        gradient: [Color(0xFFFC5C7D), Color(0xFF6A82FB)],
        requiredLevel: 6,
        requiredCoins: 700,
      ),
      const ARCharacterItem(
        id: 'stand',
        name: 'Stand Star',
        characterClass: 'Stand',
        Icon: Icons.person,
        idleModel: 'assets/images/4idle.glb',
        actionModel: 'assets/models/standup.glb',
        actionLabel: 'Stand Up',
        thumbnail: '🏆',
        gradient: [Color(0xFFA8E063), Color(0xFF56AB2F)],
        requiredLevel: 7,
        requiredCoins: 1000,
      ),
    ];
  }
  
  ///  Get character by ID
  ARCharacterItem _getCharacterById(String id) {
    final characters = getAllCharacters();
    return characters.firstWhere((char) => char.id == id, orElse: () => _getDefaultCharacter());
  }
  
  ///  Get default character (Explorer for new users)
  ARCharacterItem _getDefaultCharacter() {
    final characters = getAllCharacters();
    return characters.first; // Explorer Fatima as default
  }
  
  ///  Reset to default character
  Future<void> resetToDefault() async {
    await selectCharacter(_getDefaultCharacter());
  }
  
  ///  Get character selection stats
  Map<String, dynamic> getCharacterStats() {
    return {
      'selectedCharacterId': _selectedCharacter?.id,
      'selectedCharacterName': _selectedCharacter?.name,
      'totalAvailableCharacters': getAllCharacters().length,
      'isCustomSelection': _selectedCharacter?.id != _getDefaultCharacter().id,
    };
  }
}
