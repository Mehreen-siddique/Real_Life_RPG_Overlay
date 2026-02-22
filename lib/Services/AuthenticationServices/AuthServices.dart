
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


}
