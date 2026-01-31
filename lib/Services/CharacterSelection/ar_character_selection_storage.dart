import 'package:shared_preferences/shared_preferences.dart';

/// Local storage for AR character selection + animation selection.
class ARCharacterSelectionStorage {
  static const String selectedCharacterIdKey = 'selected_character_id';
  static const String selectedAnimationIdKey = 'selected_animation_id';

  static const String unlockedCharacterIdsKey = 'unlocked_character_ids';
  static const String unlockedAnimationIdsKey = 'unlocked_animation_ids';

  Future<String?> getSelectedCharacterId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedCharacterIdKey);
  }

  Future<void> setSelectedCharacterId(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedCharacterIdKey, characterId);
  }

  Future<String?> getSelectedAnimationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedAnimationIdKey);
  }

  Future<void> setSelectedAnimationId(String animationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedAnimationIdKey, animationId);
  }

  Future<List<String>> getUnlockedCharacterIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(unlockedCharacterIdsKey) ?? <String>[];
  }

  Future<void> setUnlockedCharacterIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(unlockedCharacterIdsKey, ids);
  }

  Future<List<String>> getUnlockedAnimationIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(unlockedAnimationIdsKey) ?? <String>[];
  }

  Future<void> setUnlockedAnimationIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(unlockedAnimationIdsKey, ids);
  }
}

