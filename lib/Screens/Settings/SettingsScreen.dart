import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Screens/Authentication/ForgotPassword.dart';
import 'package:real_life_rpg/Screens/Settings/Support/Help&FAQ.dart';
import 'package:real_life_rpg/Screens/Settings/Support/PrivacyPolicy.dart';
import 'package:real_life_rpg/Screens/Settings/Support/TermsAndConditions.dart';
import 'package:real_life_rpg/Screens/profile/EditProfile.dart';
import '../../Services/AuthenticationServices/AuthServices.dart';
import '../../Services/Notifications/notification_preferences_service.dart';
import '../../Services/Theme/app_theme_service.dart';
import '../../utils/constants.dart';
import '../Authentication/LoginScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _questRemindersEnabled = true;
  bool _streakBreakRemindersEnabled = true;
  bool _matchRequestNotificationsEnabled = true;
  bool _vibrationEnabled = false;
  bool _darkModeEnabled = false;
  String _language = 'English';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = context.read<AppThemeService>().isDarkMode;
    _loadSettingsFromBackend();
  }

  Future<void> _loadSettingsFromBackend() async {
    final uid = context.read<AuthService>().user?.uid;
    // Load notification preferences (from Firestore).
    try {
      final prefs = await NotificationPreferencesService().getForCurrentUser();
      if (!mounted) return;
      setState(() {
        _notificationsEnabled = prefs.notificationsEnabled;
        _questRemindersEnabled = prefs.questReminders;
        _streakBreakRemindersEnabled = prefs.streakBreakReminders;
        _matchRequestNotificationsEnabled = prefs.matchRequestNotifications;
      });
    } catch (_) {}

    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final settings = (doc.data()?['appSettings'] as Map<String, dynamic>?) ?? {};
      if (!mounted) return;
      setState(() {
        _vibrationEnabled = settings['vibrationEnabled'] as bool? ?? _vibrationEnabled;
        _language = settings['language'] as String? ?? _language;
      });
    } catch (_) {}
  }

  Future<void> _saveNotificationPreferencesToBackend() async {
    final uid = context.read<AuthService>().user?.uid;
    if (uid == null) return;
    setState(() => _isSyncing = true);
    try {
      await NotificationPreferencesService().updateForCurrentUser(
        notificationsEnabled: _notificationsEnabled,
        questReminders: _notificationsEnabled && _questRemindersEnabled,
        streakBreakReminders: _notificationsEnabled && _streakBreakRemindersEnabled,
        matchRequestNotifications: _notificationsEnabled && _matchRequestNotificationsEnabled,
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _saveVibrationAndLanguageToBackend() async {
    final uid = context.read<AuthService>().user?.uid;
    if (uid == null) return;

    setState(() => _isSyncing = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'appSettings': {
          'vibrationEnabled': _vibrationEnabled,
          'language': _language,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }


  void _handleLogout() async {
    final authService = context.read<AuthService>();
    authService.clearError();

    await authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }



  @override
  Widget build(BuildContext context) {
    final dark = _darkModeEnabled;
    final scaffoldBg = dark ? const Color(0xFF121212) : AppColors.lightBackground;
    final backIconColor = dark ? AppColors.textWhite : AppColors.textDark;
    final appBarTitleColor = dark ? AppColors.textWhite : AppColors.textDark;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: backIconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: appBarTitleColor,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.notifications_active,
              title: 'Push Notifications',
              subtitle: _notificationsEnabled
                  ? 'All notifications enabled'
                  : 'All notifications blocked',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    _questRemindersEnabled = value;
                    _streakBreakRemindersEnabled = value;
                    _matchRequestNotificationsEnabled = value;
                  });
                  _saveNotificationPreferencesToBackend();
                },
                activeColor: AppColors.lightPurple,
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Haptics'),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Vibrate on interactions',
              trailing: Switch(
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() => _vibrationEnabled = value);
                  _saveVibrationAndLanguageToBackend();
                },
                activeColor: AppColors.lightPurple,
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Appearance'),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Enable dark theme',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  context.read<AppThemeService>().setDarkMode(value);
                },
                activeColor: AppColors.lightPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.language,
              title: 'Language',
              subtitle: _language,
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
              onTap: () {
                _showLanguageDialog();
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Account'),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Update your character info',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
              onTap: () {
                // Navigate to Edit Profile
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfileScreen()));
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.lock,
              title: 'Change Password',
              subtitle: 'Update your password',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPasswordScreen()));
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Support'),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.help_outline,
              title: 'Help & FAQ',
              subtitle: 'Get help and support',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>HelpFaqScreen()));
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
              onTap: () {
                // Navigate to Privacy Policy
                Navigator.push(context, MaterialPageRoute(builder: (context)=>PrivacyPolicyScreen()));
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Read our terms',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
              onTap: () {
                // Navigate to Terms
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TermsConditionsScreen()));
              },
            ),
            const SizedBox(height: 24),

            _buildSettingCard(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.errorRed),
              titleColor: AppColors.errorRed,
              onTap: () {
                _showLogoutDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.errorRed),
              titleColor: AppColors.errorRed,
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),
            const SizedBox(height: 32),

            Center(
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textGray,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _darkModeEnabled
            ? AppColors.textWhite.withOpacity(0.75)
            : AppColors.textGray,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    final cardBg = _darkModeEnabled ? const Color(0xFF1E1E24) : AppColors.lightBackground;
    final defaultTitleColor = _darkModeEnabled ? AppColors.textWhite : AppColors.textDark;
    final defaultSubtitleColor =
        _darkModeEnabled ? AppColors.textWhite.withOpacity(0.7) : AppColors.textGray;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.cardShadow,

      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? defaultTitleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: defaultSubtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('اردو (Urdu)'),
            _buildLanguageOption('हिन्दी (Hindi)'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language, style: GoogleFonts.poppins()),
      value: language,
      groupValue: _language,
      activeColor: AppColors.lightPurple,
      onChanged: (value) {
        setState(() => _language = value!);
        _saveVibrationAndLanguageToBackend();
        Navigator.pop(context);
      },
    );
  }

  // void _showLogoutDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(
  //         'Logout',
  //         style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
  //       ),
  //       content: Text(
  //         'Are you sure you want to logout?',
  //         style: GoogleFonts.poppins(),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Cancel',
  //             style: GoogleFonts.poppins(color: AppColors.textGray),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // Perform logout
  //           },
  //           child: Text(
  //             'Logout',
  //             style: GoogleFonts.poppins(color: AppColors.errorRed),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textGray),
            ),
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context); // close dialog
              _handleLogout() ;
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textGray),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Perform account deletion
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
