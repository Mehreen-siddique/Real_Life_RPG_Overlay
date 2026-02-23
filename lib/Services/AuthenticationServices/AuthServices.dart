
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus { authenticated, unauthenticated, loading }

class AuthService with ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final GoogleSignIn _googleSignIn = GoogleSignIn(

    scopes: <String>[

      'email',
      'profile',
    ],

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


    // Listen to auth state changes

    // _auth.authStateChanges().listen(_onAuthStateChanged);

  }

  /// ==================== GOOGLE SIGN-IN ====================

  Future<bool> signInWithGoogle() async {

    try {

      _status = AuthStatus.loading;

      _errorMessage = null;

      notifyListeners();



      // Force sign out from Google to show account chooser

      await _googleSignIn.signOut();



      // Trigger Google Sign-In flow with account selection

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();



      if (googleUser == null) {

        // User cancelled sign-in

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      // Obtain auth details

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;



      // Create credential

      final credential = GoogleAuthProvider.credential(

        accessToken: googleAuth.accessToken,

        idToken: googleAuth.idToken,

      );



      // Sign in to Firebase

      await _auth.signInWithCredential(credential);



      _user = _auth.currentUser;



      // Store user data in Firestore

      // if (_user != null) {
      //
      //   await _storeUserDataInFirestore(
      //
      //     _user!.uid,
      //
      //     _user!.email!,
      //
      //     _user!.displayName ?? 'User',
      //
      //   );
      //
      // }



      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;



    }
    on FirebaseAuthException catch (e)
    {
      //
      // _handleAuthError(e);
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
  Future<void> _storeUserDataInFirestore(String userId, String email, String username) async {

    try {

      // Only store essential user data in Firestore

      await _firestore.collection('users').doc(userId).set({

        'uid': userId,

        'email': email,

        'username': username.toLowerCase(),

        'createdAt': FieldValue.serverTimestamp(),

      });

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
        await _storeUserDataInFirestore(_user!.uid, email, name);
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
        _errorMessage = 'This email is already registered. Please use a different email or try logging in.';

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
        _errorMessage = 'Invalid credentials. Please check your email and password.';

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
  Future<bool> login({

    required String email,

    required String password,

  }) async {

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
}
