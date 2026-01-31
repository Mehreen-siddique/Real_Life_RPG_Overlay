import 'package:flutter/foundation.dart';
import '../models/leaderboard_user.dart';

class LeaderboardProvider with ChangeNotifier {
  LeaderboardProvider();

  List<LeaderboardUser> _allUsers = [];
  List<LeaderboardUser> get allUsers => _allUsers;
  
  List<LeaderboardUser> _filteredUsers = [];
  List<LeaderboardUser> get filteredUsers => _filteredUsers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void initialize() {
    // Stub initialization. Leaderboard logic replaces the provider with normal Firestore snapshots in the screen.
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers
          .where((user) => 
              user.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}
