import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../DataServices/dataServices.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  User? _user;
  AuthStatus _status = AuthStatus.unauthenticated;
  String? _errorMessage;

  // Getters

  User? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  AuthService() {
    // // Listen to auth state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }


  void _onAuthStateChanged(User? user) {
    _user = user;
    _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
    print('Auth state changed: ${user != null ? "Logged in (   ${user!.uid})" : "Logged out"}');

    final dataService = DataService();
    // dataService.clearAllData();
    // if (user != null) {
    //   dataService.startRealtimeForUser(user.uid);
    //   SensorService().start();
    // } else {
    //   SensorService().stop();
    // }
  }
  /// ==================== GOOGLE SIGN-IN ====================

  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled sign-in
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // Obtain auth details

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,

        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase

      await _auth.signInWithCredential(credential);

      _user = _auth.currentUser;

      // Store user data in Firestore
      if (_user != null) {
        await _handleNewUserCreation(_user!, _user!.displayName ?? 'User');
      }


      // if (_user != null) {
      //   await _storeUserDataInFirestore(
      //     _user!.uid,
      //     _user!.email ?? '',
      //     _user!.displayName ?? 'User',
      //     1,
      //     0,
      //     0,
      //     0,
      //   );
      // }

      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      //
      _handleAuthError(e);
      //
      return false;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: $e';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;
    }
  }

  /// ==================== CLEAR ERROR ====================
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== STORE USER DATA IN FIRESTORE ====================
  Future<void> _storeUserDataInFirestore(
    String userId,
    String email,
    String username,
    int level,
    int xp,
    int coins,
    int streak,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'email': email,
          'username': username.toLowerCase(),
          'level': level,
          'currentXP': xp,
          'xpForNextLevel': level * 100,
          'coins': coins,
          'streak': streak,
          'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('User data stored successfully in Firestore');
    } catch (e) {
      print('Error storing user data in Firestore: $e');
    }
  }

  // ==================== SIGN UP ====================

  Future<bool> signUp({
    required String email,

    required String password,

    required String name,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name (username)

      await credential.user?.updateDisplayName(name);

      await credential.user?.reload();

      _user = _auth.currentUser;

      // Store user data in Firestore
      if (_user != null) {
        await _handleNewUserCreation(_user!, name);
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);

      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// ==================== ERROR HANDLING ====================
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        _errorMessage = 'Password is too weak. Use at least 6 characters.';

        break;

      case 'email-already-in-use':
        _errorMessage =
            'This email is already registered. Please use a different email or try logging in.';

        break;

      case 'invalid-email':
        _errorMessage = 'Invalid email address.';
        break;
      case 'user-not-found':
        _errorMessage = 'No account found with this email.';
        break;

      case 'wrong-password':
        _errorMessage = 'Incorrect password. Try again.';
        break;
      case 'user-disabled':
        _errorMessage = 'This account has been disabled.';

        break;
      case 'too-many-requests':
        _errorMessage = 'Too many attempts. Try again later.';
        break;
      case 'operation-not-allowed':
        _errorMessage = 'This sign-in method is not enabled.';

        break;
      case 'network-request-failed':
        _errorMessage = 'Network error. Check your connection.';
        break;
      case 'invalid-credential':
        _errorMessage =
            'Invalid credentials. Please check your email and password.';

        break;

      case 'session-expired':
        _errorMessage = 'Session expired. Please login again.';

        break;
      case 'account-exists-with-different-credential':
        _errorMessage = 'Account exists with different sign-in method.';

        break;
      case 'requires-recent-login':
        _errorMessage = 'Please login again to perform this action.';
        break;
      default:
        _errorMessage = 'Authentication error: ${e.message}';
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ==================== LOGIN ====================
  Future<bool> login({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;

      _errorMessage = null;

      notifyListeners();
      // Basic validation

      if (email.isEmpty) {
        _errorMessage = 'Email is required';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;
      }
      if (password.isEmpty) {
        _errorMessage = 'Password is required';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;
      }
      // Sign in with Firebase Auth

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),

        password: password,
      );

      _user = _auth.currentUser;

      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);

      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;
    }
  }

  // ==================== FORGOT PASSWORD ====================
  Future<bool> resetPassword({required String email}) async {
    try {
      _status = AuthStatus.loading;

      _errorMessage = null;

      notifyListeners();

      // Enhanced validation

      if (email.isEmpty) {
        _errorMessage = 'Please enter your email address';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;
      }

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(email)) {
        _errorMessage = 'Please enter a valid email address';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      print('Password reset email sent successfully to: $email');

      print(' Check inbox and spam folder');

      print(' Link expires in 24 hours');

      _status = AuthStatus.unauthenticated;

      _errorMessage =
          'Password reset email sent! Please check your inbox (including spam folder).';

      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print(' Firebase Auth Error in reset password:');

      print(' Code: ${e.code}');

      print(' Message: ${e.message}');

      print('Email: ${e.email}');

      print(' Stack Trace: ${e.stackTrace}');
      // Enhanced error handling

      switch (e.code) {
        case 'user-not-found':
          _errorMessage =
              'No account found with this email address. Please sign up first.';

          break;

        case 'invalid-email':
          _errorMessage =
              'Invalid email address format. Please check and try again.';

          break;

        case 'too-many-requests':
          _errorMessage =
              'Too many requests. Please wait 15-30 minutes before trying again.';

          break;

        case 'network-request-failed':
          _errorMessage =
              'Network error. Please check your internet connection and try again.';

          break;

        case 'auth/configuration-not-found':
          _errorMessage =
              'Firebase configuration error. Please contact support.';

          break;

        case 'auth/invalid-api-key':
          _errorMessage = 'API key error. Please contact support.';

          break;

        default:
          _errorMessage = 'Failed to send reset email: ${e.message}';
      }

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;
    } catch (e) {
      print(' Unexpected error in reset password: $e');

      _errorMessage =
          'An unexpected error occurred. Please try again or contact support.';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;
    }
  }

  //=================Logout======================
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      notifyListeners();
    }
  }

  /// ==================== CHECK AUTH STATUS ====================
  Future<void> checkAuthStatus() async {
    _user = _auth.currentUser;

    _status =
        _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    notifyListeners();
  }

///=============Handle new user ======================
  Future<void> _handleNewUserCreation(User user, String fallbackName) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _storeUserDataInFirestore(
        user.uid,
        user.email ?? '',
        user.displayName ?? fallbackName,
        1, 0, 0, 0,
      );
    }
  }
}
