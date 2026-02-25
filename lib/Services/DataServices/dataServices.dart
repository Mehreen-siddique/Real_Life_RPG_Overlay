


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:real_life_rpg/Models/users.dart';

class DataService with ChangeNotifier{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUserData;
  UserModel? get currentUserData => _currentUserData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchUserData(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        _currentUserData = UserModel.fromFirestore(
          docSnapshot.data()!,
          uid,
        );
        print('User data fetched: ${_currentUserData?.username} (Level: ${_currentUserData?.level})');
      } else {
        _error = 'User document not found for UID: $uid';
        print(_error);
      }
    } catch (e) {
      _error = 'Error fetching user data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



// for real time update
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot.data()!, uid);
      }
      return null;
    });
  }


  // Real-time listen karo..
  void startListeningToUser(String uid) {
    _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _currentUserData = UserModel.fromFirestore(snapshot.data()!, uid);
        notifyListeners();
        print('Real-time user update: Level ${ _currentUserData?.level }, Coins ${ _currentUserData?.coins }');
      } else {
        print('No user document found in real-time stream');
      }
    }, onError: (error) {
      print('Real-time stream error: $error');
    });
  }

// for clearence of previous data
  void clearUserData() {
    _currentUserData = null;
    _error = null;
    notifyListeners();
  }

}