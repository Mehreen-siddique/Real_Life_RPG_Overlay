import 'dart:async';



import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../DataServices/dataServices.dart';

import '../Leaderboard/leaderboard_service.dart';

import '../QuestFirestore/questfirestore.dart';

import '../Achievements/achievement_service.dart';

import '../../Models/quest.dart';

import '../../utils/constants.dart';

import 'auth_validation_service.dart';



enum AuthStatus { authenticated, unauthenticated, loading }



class AuthService with ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;



  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  final GoogleSignIn _googleSignIn = GoogleSignIn(

    scopes: <String>['email', 'profile'],

    // Force account picker to show every time by NOT using signInSilently

  );



  User? _user;

  AuthStatus _status = AuthStatus.unauthenticated;

  String? _errorMessage;

  String? _successMessage; // For success notifications



  // Getters



  User? get user => _user;

  AuthStatus get status => _status;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  

  /// Clears both error and success messages

  void clearMessages() {

    _errorMessage = null;

    _successMessage = null;

    notifyListeners();

  }

  AuthService() {

    // // Listen to auth state changes

    _auth.authStateChanges().listen(_onAuthStateChanged);

    

    // REAL FIX: Listen for FCM token refresh to keep token updated

    // This ensures invitations can reach users even when token changes

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {

      if (_user != null) {

        _saveFCMToken(_user!.uid);

      }

    });

  }





  Future<void> _onAuthStateChanged(User? user) async {

    _user = user;

    _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;

    

    final dataService = DataService();

    final leaderboardService = LeaderboardService.instance;

    

    if (user != null) {

      // User logged in - start services

      dataService.startListeningToUser(user.uid);

      // Initialize achievements docs in Firestore (idempotent).

      // FIXED: Wrap in try-catch to prevent blocking when Firestore quota is exceeded

      try {

        await AchievementService().initializeAchievementsForUser(user.uid);

        debugPrint('[AUTH] Achievements initialized');

      } catch (e) {

        debugPrint('[AUTH] Error initializing achievements (non-blocking): $e');

        // App continues to launch even if achievement initialization fails

      }

      

      debugPrint('Services started for user: ${user.uid}');

    } else {

      // User logged out - stop services

      dataService.clearUserData();

      debugPrint('Services stopped');

    }

    

    notifyListeners();

    debugPrint('Auth state changed: ${user != null ? "Logged in (${user!.uid})" : "Logged out"}');

  }

  /// ==================== GOOGLE SIGN-IN ====================



  Future<bool> signInWithGoogle() async {

    try {

      _status = AuthStatus.loading;

      _errorMessage = null;

      notifyListeners();



      // Force sign out first to ensure account picker is shown

      // This allows user to choose different account each time

      try {

        await _googleSignIn.signOut();

        debugPrint('[GOOGLE] Signed out previous session');

      } catch (e) {

        // Ignore signOut errors (e.g., no previous session)

        debugPrint('[GOOGLE] No previous session to sign out');

      }



      // Start Google Sign-In with timeout protection

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(

        const Duration(seconds: 30),

        onTimeout: () {

          throw TimeoutException('Google Sign-In timed out. Please try again.');

        },

      );



      if (googleUser == null) {

        // User cancelled sign-in

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      // Obtain auth details with timeout

      final GoogleSignInAuthentication googleAuth =

          await googleUser.authentication.timeout(

        const Duration(seconds: 15),

        onTimeout: () {

          throw TimeoutException('Authentication failed. Please try again.');

        },

      );



      // Create credential

      final credential = GoogleAuthProvider.credential(

        accessToken: googleAuth.accessToken,

        idToken: googleAuth.idToken,

      );



      // Sign in to Firebase with timeout

      await _auth.signInWithCredential(credential).timeout(

        const Duration(seconds: 20),

        onTimeout: () {

          throw TimeoutException('Firebase connection timed out. Please check your internet.');

        },

      );



      _user = _auth.currentUser;



      // Store user data in Firestore - run in parallel for speed

      if (_user != null) {

        // Fire-and-forget: Don't wait for these to complete before returning success

        // This makes login feel instant while data syncs in background

        Future.microtask(() async {

          try {

            await _handleNewUserCreation(_user!, _user!.displayName ?? 'User');

            await _saveFCMToken(_user!.uid);

            debugPrint('[GOOGLE] Background user setup completed');

          } catch (e) {

            debugPrint('[GOOGLE] Background setup error (non-blocking): $e');

          }

        });

      }



      _status = AuthStatus.authenticated;

      notifyListeners();

      return true;



    } on FirebaseAuthException catch (e) {

      _handleAuthError(e);

      return false;

    } on TimeoutException catch (e) {

      _errorMessage = e.message ?? 'Connection timed out. Please try again.';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

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

    _successMessage = null;

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

      debugPrint('[STORE_DATA] Storing user data - username: "$username"');

      await _firestore.collection('users').doc(userId).set({

          'uid': userId,

          'email': email,

          'username': username,

          'level': level,

          'currentXP': xp,

          'xpForNextLevel': level * 100,

          'coins': coins,

          'streak': streak,

          'createdAt': FieldValue.serverTimestamp(),

      }, SetOptions(merge: true));



      debugPrint('[STORE_DATA] User data stored successfully');

    } catch (e) {

      debugPrint('[STORE_DATA] Error storing user data: $e');

    }

  }



  // REAL FIX: Save FCM token to Firestore for push notifications

  // This enables users to receive party invitations as push notifications

  Future<void> _saveFCMToken(String userId) async {

    try {

      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {

        await _firestore.collection('users').doc(userId).update({

          'fcmToken': fcmToken,

        });

        debugPrint('[AUTH] FCM token saved for user: $userId');

      }

    } catch (e) {

      debugPrint('[AUTH] Error saving FCM token: $e');

    }

  }



  // ═══════════════════════════════════════════════════════════════════

  //  PRODUCTION SIGN UP WITH EMAIL VERIFICATION

  // ═════════════════════════════════════════════════════════════════════



  /// Signs up a new user with email/password and sends verification email

  /// Returns: true if signup successful (verification email sent), false if error

  Future<bool> signUp({

    required String email,

    required String password,

    required String name,

    required String confirmPassword,

  }) async {

    try {

      debugPrint('[SIGNUP] Starting signup process for: $email');

      _status = AuthStatus.loading;

      _errorMessage = null;

      notifyListeners();



      // ═══ STEP 1: PRE-VALIDATION ═══

      

      // Validate email format

      final emailError = AuthValidationService.validateEmail(email);

      if (emailError != null) {

        _errorMessage = emailError;

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      // Validate name

      final nameError = AuthValidationService.validateName(name);

      if (nameError != null) {

        _errorMessage = nameError;

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      // Validate password strength

      final passwordValidation = AuthValidationService.validatePassword(password);

      if (!passwordValidation.isValid) {

        _errorMessage = 'Password is too weak:\n${passwordValidation.requirements.join('\n')}';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      // Check for common passwords

      final commonPasswordWarning = AuthValidationService.getCommonPasswordWarning(password);

      if (commonPasswordWarning != null) {

        _errorMessage = commonPasswordWarning;

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      // Validate password match

      if (password != confirmPassword) {

        _errorMessage = 'Passwords do not match';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      // Sanitize inputs

      final sanitizedEmail = AuthValidationService.sanitizeEmail(email);

      final sanitizedName = AuthValidationService.sanitizeName(name);



      debugPrint('[SIGNUP] Pre-validation passed, creating user...');



      // ═══ STEP 2: CREATE USER IN FIREBASE AUTH ═══

      // Note: Firebase will automatically throw 'email-already-in-use' if email exists

      final credential = await _auth.createUserWithEmailAndPassword(

        email: sanitizedEmail,

        password: password,

      );



      debugPrint('[SIGNUP] User created successfully: ${credential.user?.uid}');



      // Update display name

      await credential.user?.updateDisplayName(sanitizedName);

      await credential.user?.reload();



      _user = _auth.currentUser;



      // ═══ STEP 4: STORE USER DATA IN FIRESTORE ═══

      if (_user != null) {

        await _handleNewUserCreation(_user!, sanitizedName);

        debugPrint('[SIGNUP] User data stored in Firestore');

      }



      // ═══ STEP 5: SEND EMAIL VERIFICATION ═══

      if (_user != null && !_user!.emailVerified) {

        await _user!.sendEmailVerification();

        debugPrint('[SIGNUP] Verification email sent to: $sanitizedEmail');

      }



      // ═══ STEP 6: SIGN OUT - REQUIRE VERIFICATION BEFORE LOGIN ═══

      // This forces the user to verify email before they can log in

      await _auth.signOut();

      _user = null;

      _status = AuthStatus.unauthenticated;

      _errorMessage = null; // Clear any errors

      _successMessage = 'Verification email sent. Please verify before login.';

      

      notifyListeners();

      

      debugPrint('[SIGNUP] Signup complete. Verification email sent. User must verify before login.');

      return true; // Success - but user needs to verify email



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



  /// Resends email verification to current user

  /// Returns true if email sent successfully, false otherwise

  Future<bool> resendVerificationEmail() async {

    try {

      _status = AuthStatus.loading;

      _errorMessage = null;

      _successMessage = null;

      notifyListeners();

      

      final user = _auth.currentUser;

      if (user == null) {

        _errorMessage = 'No user logged in. Please sign up first.';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }

      

      await user.reload();

      final refreshedUser = _auth.currentUser;

      

      if (refreshedUser == null) {

        _errorMessage = 'User session expired. Please sign up again.';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }

      

      if (refreshedUser.emailVerified) {

        _successMessage = 'Your email is already verified. You can log in now.';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return true;

      }

      

      await refreshedUser.sendEmailVerification();

      _successMessage = 'Verification email sent. Please check your inbox.';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      debugPrint('[AUTH] Verification email resent to: ${refreshedUser.email}');

      return true;

    } on FirebaseAuthException catch (e) {

      _handleAuthError(e);

      return false;

    } catch (e) {

      _errorMessage = 'Failed to resend verification email: $e';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;

    }

  }



  /// Checks if current user's email is verified

  /// Returns false if user is null or not verified

  Future<bool> isEmailVerified() async {

    try {

      await _auth.currentUser?.reload();

      return _auth.currentUser?.emailVerified ?? false;

    } catch (e) {

      debugPrint('[AUTH] Error checking email verification: $e');

      return false;

    }

  }



  /// Reloads user data and returns true if email is verified

  /// Used by verification screen to check if user can proceed to login

  Future<bool> reloadAndCheckVerification() async {

    try {

      _status = AuthStatus.loading;

      _errorMessage = null;

      notifyListeners();

      

      await _auth.currentUser?.reload();

      _user = _auth.currentUser;

      

      if (_user == null) {

        _errorMessage = 'User not found. Please sign up again.';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }

      

      final isVerified = _user!.emailVerified;

      

      if (isVerified) {

        _successMessage = 'Email verified successfully! You can now log in.';

      }

      

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return isVerified;

    } catch (e) {

      _errorMessage = 'Error checking verification status: $e';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;

    }

  }

  

  /// Reloads user data to check email verification status

  @deprecated

  Future<void> reloadUser() async {

    await reloadAndCheckVerification();

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

        _errorMessage = 'No account found with this email. Please sign up first.';

        break;

      case 'wrong-password':

        _errorMessage = 'Incorrect password. Please try again.';

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

      case 'invalid_credentials':

        _errorMessage = 'Invalid email or password. Please check your credentials and try again.';

        break;

      case 'INVALID_LOGIN_CREDENTIALS':

        _errorMessage = 'Invalid email or password. Please check your credentials and try again.';

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



  // ═══════════════════════════════════════════════════════════════════

  //  PRODUCTION LOGIN WITH EMAIL VERIFICATION

  // ═════════════════════════════════════════════════════════════════════



  /// Logs in user with comprehensive validation and email verification check

  Future<bool> login({

    required String email, 

    required String password,

    bool skipVerification = false, // For development/testing only

  }) async {

    try {

      debugPrint('[LOGIN] Starting login process for: $email');

      _status = AuthStatus.loading;

      _errorMessage = null;

      notifyListeners();



      // ═══ STEP 1: PRE-VALIDATION ═══

      

      // Validate email format

      final emailError = AuthValidationService.validateEmail(email);

      if (emailError != null) {

        _errorMessage = emailError;

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      // Validate password is not empty

      if (password.isEmpty) {

        _errorMessage = 'Password is required';

        _status = AuthStatus.unauthenticated;

        notifyListeners();

        return false;

      }



      final sanitizedEmail = AuthValidationService.sanitizeEmail(email);



      // ═══ STEP 2: SIGN IN WITH FIREBASE AUTH ═══

      debugPrint('[LOGIN] Authenticating with Firebase Auth...');

      await _auth.signInWithEmailAndPassword(

        email: sanitizedEmail,

        password: password,

      );



      _user = _auth.currentUser;

      debugPrint('[LOGIN] Firebase Auth login successful: ${_user?.uid}');



      // ═══ STEP 3: CHECK EMAIL VERIFICATION ═══

      if (_user != null && !skipVerification) {

        await _user!.reload();

        final isVerified = _user!.emailVerified;

        

        debugPrint('[LOGIN] Email verification status: $isVerified');

        

        if (!isVerified) {

          // Email not verified - sign out and show error

          await _auth.signOut();

          _user = null;

          _errorMessage = 'Please verify your email before logging in. Check your inbox for the verification link.';

          _status = AuthStatus.unauthenticated;

          notifyListeners();

          debugPrint('[LOGIN] Login blocked - email not verified');

          return false;

        }

      }



      // ═══ STEP 4: ENSURE USER DATA EXISTS ═══

      if (_user != null) {

        debugPrint('[LOGIN] Checking/creating Firestore document...');

        await _ensureUserDocumentExists(_user!);

        

        // Update last login time

        await _updateLastLoginTime(_user!.uid);

      }



      // ═══ STEP 5: LOGIN SUCCESSFUL ═══

      _status = AuthStatus.authenticated;

      notifyListeners();

      debugPrint('[LOGIN] Login completed successfully - user authenticated');

      return true;



    } on FirebaseAuthException catch (e) {

      debugPrint('[LOGIN] Firebase Auth error: ${e.code} - ${e.message}');

      _handleAuthError(e);

      return false;

    } catch (e) {

      debugPrint('[LOGIN] Unexpected error: $e');

      _errorMessage = 'Login failed: ${e.toString()}';

      _status = AuthStatus.unauthenticated;

      notifyListeners();

      return false;

    }

  }



  /// Updates last login time in Firestore

  Future<void> _updateLastLoginTime(String userId) async {

    try {

      await _firestore.collection('users').doc(userId).update({

        'lastLoginAt': FieldValue.serverTimestamp(),

      });

    } catch (e) {

      debugPrint('[LOGIN] Error updating last login time: $e');

      // Non-critical error, don't block login

    }

  }



  // Helper to ensure Firestore document exists for user

  Future<void> _ensureUserDocumentExists(User user) async {

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {

      debugPrint('[ENSURE_DOC] Document missing, creating for: ${user.uid}');

      // Try to use displayName first, fallback to email username

      String username = user.displayName ?? user.email?.split('@').first ?? 'User';

      await _storeUserDataInFirestore(

        user.uid,

        user.email ?? '',

        username,

        1, 0, 0, 0,

      );

      debugPrint('[ENSURE_DOC] Document created successfully');

    } else {

      debugPrint('[ENSURE_DOC] Document already exists');

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



      debugPrint('Password reset email sent successfully to: $email');

      debugPrint('Check inbox and spam folder');

      debugPrint('Link expires in 24 hours');



      _status = AuthStatus.unauthenticated;



      _errorMessage =

          'Password reset email sent! Please check your inbox (including spam folder).';



      notifyListeners();

      return true;

    } on FirebaseAuthException catch (e) {

      debugPrint('Firebase Auth Error in reset password:');

      debugPrint('Code: ${e.code}');

      debugPrint('Message: ${e.message}');

      debugPrint('Email: ${e.email}');

      debugPrint('Stack Trace: ${e.stackTrace}');

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

      debugPrint(' Unexpected error in reset password: $e');



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

  Future<void> _handleNewUserCreation(User user, String username) async {

    debugPrint('[HANDLE_NEW_USER] Checking if user document exists for: ${user.uid}');

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {

      debugPrint('[HANDLE_NEW_USER] Document does not exist, creating with username: $username');

      await _storeUserDataInFirestore(

        user.uid,

        user.email ?? '',

        username,

        1, 0, 0, 0,

      );

      debugPrint('[HANDLE_NEW_USER] User document created successfully');

    } else {

      debugPrint('[HANDLE_NEW_USER] Document already exists, skipping creation');

    }

  }



}

