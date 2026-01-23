import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_life_rpg/Screens/Authentication/ForgotPassword.dart';
import 'package:real_life_rpg/Screens/Settings/Support/Help&FAQ.dart';
import 'package:real_life_rpg/Screens/Settings/Support/PrivacyPolicy.dart';
import 'package:real_life_rpg/Screens/Settings/Support/TermsAndConditions.dart';
import 'package:real_life_rpg/Screens/profile/EditProfile.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  bool _darkModeEnabled = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
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
              subtitle: 'Get reminders for daily quests',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
                activeColor: AppColors.lightPurple,
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Audio & Haptics'),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.volume_up,
              title: 'Sound Effects',
              subtitle: 'Play sounds on quest completion',
              trailing: Switch(
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                },
                activeColor: AppColors.lightPurple,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Vibrate on interactions',
              trailing: Switch(
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() => _vibrationEnabled = value);
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
        color: AppColors.textGray,
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
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
                          color: titleColor ?? AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textGray,
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
        Navigator.pop(context);
      },
    );
  }

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
            onPressed: () {
              Navigator.pop(context);
              // Perform logout
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
