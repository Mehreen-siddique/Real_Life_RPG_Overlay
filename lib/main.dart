import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:real_life_rpg/Screens/SplashScreen.dart';
import 'package:real_life_rpg/Screens/Notifications/notification_center_screen.dart';
import 'package:real_life_rpg/Services/DataServices/dataServices.dart';
import 'package:real_life_rpg/Services/AuthenticationServices/AuthServices.dart';
import 'package:real_life_rpg/Services/CharacterSelection/character_selection_service.dart';
import 'package:real_life_rpg/Services/AnimatedProgress/animated_progress_service.dart';
import 'package:real_life_rpg/Services/Leaderboard/leaderboard_service.dart';
import 'package:real_life_rpg/Services/Notifications/notification_service.dart';
import 'package:real_life_rpg/Services/Notifications/enhanced_notification_service.dart';
import 'package:real_life_rpg/Services/Notifications/notification_center_service.dart';
import 'package:real_life_rpg/Services/Streaks/streaks_service.dart';
import 'package:real_life_rpg/features/leaderboard/providers/leaderboard_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_life_rpg/Services/Theme/app_theme_helper.dart';
import 'package:real_life_rpg/Services/Theme/app_theme_service.dart';
import 'package:real_life_rpg/Services/Notifications/match_request_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ═══════════════════════════════════════════════════════════════════════════════
  // FIRESTORE OFFLINE PERSISTENCE - Enable offline support
  // ═══════════════════════════════════════════════════════════════════════════════
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  print('[MAIN] Firestore offline persistence enabled');

  // ═══════════════════════════════════════════════════════════════════════════════
  // FCM BACKGROUND HANDLER - Register before app runs
  // ═══════════════════════════════════════════════════════════════════════════════
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
  print('[MAIN] FCM background handler registered');
  
  // Theme persistence (SharedPreferences) - required by SettingsScreen.
  final initialDarkMode = await AppThemeService.loadInitialDarkMode();

  // Run app with navigatorKey for showing dialogs from notifications
  // IMPORTANT: Run the app FIRST before initializing services
  runApp(MyApp(initialDarkMode: initialDarkMode));
  print('[MAIN] App launched, initializing services in background...');
  
  // Initialize all services AFTER the app runs - NON-BLOCKING
  // This ensures the splash screen shows immediately while services load in background
  Future.microtask(() async {
    await _initializeServices();
    print('[MAIN] All services initialized successfully');
  });
}

// REAL FIX: Global navigator key for showing dialogs from notification handlers
class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final bool initialDarkMode;
  const MyApp({super.key, required this.initialDarkMode});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DataService()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => NotificationCenterService()),
        ChangeNotifierProvider(
          create: (_) => AppThemeService(initialDarkMode: initialDarkMode),
        ),
      ],
      child: Consumer<AppThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'Real Life RPG',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: AppThemeHelper.lightTheme,
            darkTheme: AppThemeHelper.darkTheme,
            themeMode: themeService.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/notifications': (context) => const NotificationCenterScreen(),
            },
          );
        },
      ),
    );
  }
}

// Initialize all services
Future<void> _initializeServices() async {
  // ═══════════════════════════════════════════════════════════════════════════════
  // FIREBASE CLOUD MESSAGING (FCM) - Save device token for push notifications
  // ═══════════════════════════════════════════════════════════════════════════════
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  // Request notification permissions with timeout
  // FIXED: Wrap in try-catch and add timeout to prevent blocking
  NotificationSettings settings;
  try {
    settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    ).timeout(const Duration(seconds: 5), onTimeout: () {
      print('[FCM] Permission request timed out (non-blocking)');
      return const NotificationSettings(
        authorizationStatus: AuthorizationStatus.notDetermined,
        alert: AppleNotificationSetting.notSupported,
        announcement: AppleNotificationSetting.notSupported,
        badge: AppleNotificationSetting.notSupported,
        carPlay: AppleNotificationSetting.notSupported,
        criticalAlert: AppleNotificationSetting.notSupported,
        lockScreen: AppleNotificationSetting.notSupported,
        notificationCenter: AppleNotificationSetting.notSupported,
        showPreviews: AppleShowPreviewSetting.notSupported,
        timeSensitive: AppleNotificationSetting.notSupported,
        sound: AppleNotificationSetting.notSupported,
        providesAppNotificationSettings: AppleNotificationSetting.notSupported,
      );
    });
  } catch (e) {
    print('[FCM] Permission request failed (non-blocking): $e');
    settings = const NotificationSettings(
      authorizationStatus: AuthorizationStatus.notDetermined,
      alert: AppleNotificationSetting.notSupported,
      announcement: AppleNotificationSetting.notSupported,
      badge: AppleNotificationSetting.notSupported,
      carPlay: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.notSupported,
      notificationCenter: AppleNotificationSetting.notSupported,
      showPreviews: AppleShowPreviewSetting.notSupported,
      timeSensitive: AppleNotificationSetting.notSupported,
      sound: AppleNotificationSetting.notSupported,
      providesAppNotificationSettings: AppleNotificationSetting.notSupported,
    );
  }
  
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    // Get FCM token and save to Firestore
    // FIXED: Wrap in try-catch to prevent blocking app launch when Firebase Installations Service is unavailable
    try {
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
            'fcmToken': fcmToken,
          });
          print('[FCM] Token saved to Firestore: $fcmToken');
        }
      }
    } catch (e) {
      print('[FCM] Failed to get token (non-blocking): $e');
      // App continues to launch even if FCM token retrieval fails
    }
    
    // Listen for token refresh
    try {
      messaging.onTokenRefresh.listen((newToken) async {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          try {
            await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
              'fcmToken': newToken,
            });
            print('[FCM] Token refreshed and saved: $newToken');
          } catch (e) {
            print('[FCM] Failed to save refreshed token: $e');
          }
        }
      });
    } catch (e) {
      print('[FCM] Failed to set up token refresh listener: $e');
    }
  }
  
  // Initialize notification services with error handling
  // FIXED: Wrap in try-catch to prevent blocking when services fail
  try {
    final notificationService = NotificationService();
    await notificationService.initialize().timeout(const Duration(seconds: 3));
    await notificationService.requestPermissions().timeout(const Duration(seconds: 3));
    print('[MAIN] Notification service initialized');
  } catch (e) {
    print('[MAIN] Notification service failed (non-blocking): $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // ENHANCED NOTIFICATION SERVICE - FCM and Local Notifications
  // ═══════════════════════════════════════════════════════════════════════════════
  try {
    final enhancedNotificationService = EnhancedNotificationService();
    await enhancedNotificationService.initialize(
      onNotificationTap: (type, data) {
        print('[MAIN] Notification tapped: type=$type, data=$data');
        handleNotificationTap(type, data);
      },
    ).timeout(const Duration(seconds: 3));
    await enhancedNotificationService.requestPermissions().timeout(const Duration(seconds: 3));
    print('[MAIN] Enhanced notification service initialized');
  } catch (e) {
    print('[MAIN] Enhanced notification service failed (non-blocking): $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // NOTIFICATION CENTER SERVICE - In-app notification management
  // ═══════════════════════════════════════════════════════════════════════════════
  try {
    final notificationCenterService = NotificationCenterService();
    await notificationCenterService.initialize().timeout(const Duration(seconds: 3));
    print('[MAIN] Notification center service initialized');
  } catch (e) {
    print('[MAIN] Notification center service failed (non-blocking): $e');
  }

  // Match request (friend request) local notifications based on user settings.
  try {
    await MatchRequestNotificationService().initialize().timeout(const Duration(seconds: 3));
    print('[MAIN] Match request notification service initialized');
  } catch (e) {
    print('[MAIN] Match request service failed (non-blocking): $e');
  }

  // ═══════════════════════════════════════════════════════════════════════════════
  // STREAKS SERVICE - Daily streak calculation and badges
  // ═══════════════════════════════════════════════════════════════════════════════
  try {
    final streaksService = StreaksService();
    await streaksService.initialize().timeout(const Duration(seconds: 3));
    print('[MAIN] Streaks service initialized');
  } catch (e) {
    print('[MAIN] Streaks service failed (non-blocking): $e');
  }
  
  // Initialize character selection service
  try {
    final characterService = CharacterSelectionService.instance;
    await characterService.initialize().timeout(const Duration(seconds: 3));
    print('[MAIN] Character selection service initialized');
  } catch (e) {
    print('[MAIN] Character selection service failed (non-blocking): $e');
  }
  
  // Initialize animated progress service
  final progressService = AnimatedProgressService.instance;
  
  // Initialize leaderboard service
  final leaderboardService = LeaderboardService.instance;
  
  debugPrint('Real Life RPG initialized with leaderboard, notifications, streaks, and offline support');
}

/// Handle notification tap - top-level function for global access
void handleNotificationTap(String type, Map<String, dynamic> data) async {
  // Wait for app to fully initialize
  await Future.delayed(const Duration(seconds: 1));
  
  if (type == 'party_invitation') {
    // Navigate to leaderboard screen and show invitations
    print('[FCM] Navigating to invitations section');
    
    // Use navigator key to navigate
    final context = MyApp.navigatorKey.currentContext;
    if (context != null) {
      // Navigate to leaderboard screen
      Navigator.pushNamed(context, '/leaderboard');
    }
  } else if (type == 'badge_earned') {
    // Navigate to profile/achievements screen
    print('[FCM] Navigating to achievements');
  } else if (type == 'quest_completed') {
    // Navigate to quests screen
    print('[FCM] Navigating to quests');
  } else if (type == 'streak_milestone') {
    // Navigate to streak details
    print('[FCM] Navigating to streak details');
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  
  // ═══════════════════════════════════════════════════════════════════════════════
  // FCM NOTIFICATION HANDLERS - Handle notification taps and app opens
  // ═══════════════════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _setupFCMListeners();
  }
  
  /// Setup FCM notification listeners for app foreground, background, and terminated states
  void _setupFCMListeners() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Handle notification when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM] Foreground message received: ${message.notification?.title}');
      // Show local notification or update UI
      _handleNotification(message.data);
    });
    
    // Handle notification tap when app is in background but running
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('[FCM] Background message opened: ${message.notification?.title}');
      handleNotificationTap(message.data['type'] ?? 'general', message.data);
    });
    
    // Handle notification tap when app was terminated
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('[FCM] App opened from terminated state via notification');
      handleNotificationTap(initialMessage.data['type'] ?? 'general', initialMessage.data);
    }
  }
  
  /// Handle notification data payload - REAL FIX: Show invitation dialog for party invitations
  void _handleNotification(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'party_invitation') {
      // REAL FIX: Show invitation dialog when party invitation received in foreground
      print('[FCM] Party invitation received: ${data['invitationId']}');
      _showInvitationDialog(data);
    } else if (type == 'gift_received') {
      print('[FCM] Gift received: ${data['itemType']}');
    }
  }
  
  /// REAL FIX: Show party invitation dialog when user receives invitation
  void _showInvitationDialog(Map<String, dynamic> data) {
    // Use the global navigator key to show dialog from any context
    final navigatorKey = MyApp.navigatorKey;
    if (navigatorKey.currentContext == null) return;
    
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚔️ Party Invitation!'),
        content: Text(data['message'] ?? 'You have been invited to join a party!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeclineInvitation(data['invitationId']);
            },
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAcceptInvitation(data['invitationId'], data['partyId']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2CBF),
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
  
  /// REAL FIX: Handle accepting a party invitation from notification
  Future<void> _handleAcceptInvitation(String invitationId, String partyId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) return;
      
      // Update invitation status to accepted
      await firestore.collection('partyInvitations').doc(invitationId).update({
        'status': 'accepted',
      });
      
      // Add user to party
      await firestore.collection('parties').doc(partyId).update({
        'memberIds': FieldValue.arrayUnion([currentUser.uid]),
      });
      
      // Update user's party reference
      final partyDoc = await firestore.collection('parties').doc(partyId).get();
      final partyName = partyDoc.data()?['name'] ?? 'Unknown Party';
      
      await firestore.collection('users').doc(currentUser.uid).update({
        'partyId': partyId,
        'partyName': partyName,
      });
      
      print('[FCM] Successfully accepted invitation and joined party');
    } catch (e) {
      print('[FCM] Error accepting invitation: $e');
    }
  }
  
  /// REAL FIX: Handle declining a party invitation from notification
  Future<void> _handleDeclineInvitation(String invitationId) async {
    try {
      await FirebaseFirestore.instance.collection('partyInvitations').doc(invitationId).update({
        'status': 'declined',
      });
      print('[FCM] Invitation declined');
    } catch (e) {
      print('[FCM] Error declining invitation: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DataService()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: MaterialApp(
        title: 'Real Life RPG',
        debugShowCheckedModeBanner: false,
        navigatorKey: MyApp.navigatorKey, // REAL FIX: Required for showing dialogs from notifications
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
        },
      ),
    );
  }
}
