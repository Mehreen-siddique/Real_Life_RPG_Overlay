import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Privacy Policy',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            SizedBox(height: AppSizes.paddingMD),

            _policySection(
              title: '1. Overview',
              body:
              'Real Life RPG Overlay is a student project application. This Privacy Policy explains how the app collects, uses, and handles user data.',
            ),
            _policySection(
              title: '2. What Data We Collect',
              body:
              'The app may collect basic profile information (such as name or class), quest-related data (including titles, difficulty, and completion status), achievement progress, and optional camera or gallery images if the user chooses to provide them.',
            ),
            _policySection(
              title: '3. Why We Collect Data',
              body:
              'Collected data is used to track user progress, calculate experience points and levels, enhance the in-app character experience, and support future features such as family or leaderboard systems.',
            ),
            _policySection(
              title: '4. Camera & Photos',
              body:
              'Camera or gallery access is only used when the user explicitly chooses to do so, such as for avatar or image customization features. The app does not access the camera or photos in the background.',
            ),
            _policySection(
              title: '5. Storage & Security',
              body:
              'User data may be stored locally on the device or on a backend service such as Firebase. Production-level security practices, including authentication rules, permissions, and secure storage, may be implemented as the project evolves.',
            ),
            _policySection(
              title: '6. Sharing & Third Parties',
              body:
              'User data is not sold or shared with third parties. If analytics or cloud services are introduced in the future, they will be used solely for application improvement purposes.',
            ),
            _policySection(
              title: '7. Your Controls',
              body:
              'Users can edit or delete quests within the app. Logout options are available, and a “delete account” feature may be introduced in future backend-enabled versions.',
            ),
            _policySection(
              title: '8. Changes to This Policy',
              body:
              'This Privacy Policy may be updated as the project evolves. Any updates will be reflected within the application.',
            ),
            _policySection(
              title: '9. Contact',
              body:
              'If you have any questions regarding this Privacy Policy, you may contact support through the app’s Help or FAQ section when backend support becomes available.',
            ),

            SizedBox(height: AppSizes.paddingLG),
            _footerNote(context),
          ],
        ),
      ),
    );
  }


  ///Header Section
  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryPurple,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        boxShadow: AppShadows.glowPurple,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.whiteBackground.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Icon(Icons.privacy_tip_outlined, color: AppColors.textWhite, size: 28),
          ),
          SizedBox(width: AppSizes.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy matters',
                  style: AppTextStyles.headingWhite.copyWith(fontSize: 18),
                ),
                SizedBox(height: 4),
                Text(
                  'Read how we handle your data in the RPG journey.',
                  style: AppTextStyles.bodyWhite.copyWith(
                    fontSize: 12,
                    color: AppColors.textWhite.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  ///Policy Section

  Widget _policySection({required String title, required String body}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.paddingSM),
      padding: EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        boxShadow: AppShadows.cardShadow,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subheading),
          SizedBox(height: 8),
          Text(
            body,
            style: AppTextStyles.body.copyWith(color: AppColors.textDark),
          ),
        ],
      ),
    );
  }


  ///FooterNote Section
  Widget _footerNote(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryPurple),
          SizedBox(width: AppSizes.paddingSM),
          Expanded(
            child: Text(
              'Note: This policy applies to a student project. For production deployment, a professionally reviewed privacy policy and consent flow are recommended.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
