import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Terms & Conditions',
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

            _termsSection(
              title: '1. Acceptance of Terms',
              body:
              'By accessing or using Real Life RPG Overlay, you agree to be bound by these Terms & Conditions. If you do not agree with any part of these terms, you must discontinue use of the application immediately.',
            ),
            _termsSection(
              title: '2. Description of Service',
              body:
              'Real Life RPG Overlay is a gamified productivity application developed as a student project. The app allows users to track tasks, progress, and achievements in an RPG-style format for personal use only.',
            ),
            _termsSection(
              title: '3. Eligibility',
              body:
              'The app is intended for general audiences. Users are responsible for ensuring that their use of the app complies with applicable local laws and regulations.',
            ),
            _termsSection(
              title: '4. User Responsibilities',
              body:
              'Users are responsible for managing their own quests, experience points (XP), and progress. The app does not guarantee data retention or recovery, particularly in student or experimental versions.',
            ),
            _termsSection(
              title: '5. Camera & Media Usage',
              body:
              'If users choose to access camera or gallery features, such access is used solely for intended app features such as avatars or customization. The app does not access media without user consent.',
            ),
            _termsSection(
              title: '6. Intellectual Property',
              body:
              'All user interface elements, concepts, designs, and source code are the intellectual property of the developer. Unauthorized reuse, copying, or redistribution is strictly prohibited.',
            ),
            _termsSection(
              title: '7. Feature Changes',
              body:
              'The developer reserves the right to add, modify, or remove features at any time without prior notice. As a student project, some features may be experimental or subject to change.',
            ),
            _termsSection(
              title: '8. Limitation of Liability',
              body:
              'Use of the application is at your own risk. The developer shall not be held liable for any direct, indirect, incidental, or consequential damages arising from the use of the app.',
            ),
            _termsSection(
              title: '9. Termination',
              body:
              'Access to the application may be restricted or terminated if a user violates these Terms & Conditions.',
            ),
            _termsSection(
              title: '10. Updates to Terms',
              body:
              'These Terms & Conditions may be updated from time to time. Any changes will be reflected within the application. Continued use of the app constitutes acceptance of the updated terms.',
            ),


            SizedBox(height: AppSizes.paddingLG),
            _footerNote(),
          ],
        ),
      ),
    );
  }

  /// Header Section
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
            child: Icon(
              Icons.gavel_outlined,
              color: AppColors.textWhite,
              size: 28,
            ),
          ),
          SizedBox(width: AppSizes.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fair use matters',
                  style: AppTextStyles.headingWhite.copyWith(fontSize: 18),
                ),
                SizedBox(height: 4),
                Text(
                  'Understand the rules of your RPG journey.',
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

  /// Terms Section
  Widget _termsSection({required String title, required String body}) {
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

  /// Footer Note
  Widget _footerNote() {
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
'These Terms & Conditions are provided for a student project and early-stage application. For commercial release, professional legal review is recommended.' ,
              style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
