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
            //
            // _policySection(
            //   title: '1. Overview',
            //   body:
            //   'Real Life RPG Overlay is a student project app. Is policy ka purpose yeh batana hai ke app user data ko kaise handle karegi.',
            // ),
            // _policySection(
            //   title: '2. What Data We Collect',
            //   body:
            //   'App aapka basic profile (name/class), quests data (title, difficulty, completion), achievements progress, aur optionally camera/gallery image (sirf agar aap choose karein) collect kar sakti hai.',
            // ),
            // _policySection(
            //   title: '3. Why We Collect Data',
            //   body:
            //   'Data ka use aapki progress track karne, XP/level calculate karne, AR character experience improve karne, aur (future) family/leaderboard features ke liye hota hai.',
            // ),
            // _policySection(
            //   title: '4. Camera & Photos',
            //   body:
            //   'Camera/gallery access sirf tab use hota hai jab user manually choose kare (e.g., avatar/cartoon conversion). App background mein silently camera use nahi karti.',
            // ),
            // _policySection(
            //   title: '5. Storage & Security',
            //   body:
            //   'Basic version mein data local storage ya backend (Firebase) par store ho sakta hai. Production-level security practices (auth rules, permissions, secure storage) backend ke sath add hongi.',
            // ),
            // _policySection(
            //   title: '6. Sharing & Third Parties',
            //   body:
            //   'User data third parties ke saath sell/share nahi kiya jata. Future mein agar analytics ya cloud services use hon to unka purpose sirf app improvement hoga.',
            // ),
            // _policySection(
            //   title: '7. Your Controls',
            //   body:
            //   'Aap quests edit/delete kar sakte hain. Settings se logout, aur future backend mein “delete account” option available hoga.',
            // ),
            // _policySection(
            //   title: '8. Changes to This Policy',
            //   body:
            //   'Project evolve hone par is policy ko update kiya ja sakta hai. Updated policy app ke andar reflect ho gi.',
            // ),
            // _policySection(
            //   title: '9. Contact',
            //   body:
            //   'Agar aapko privacy related question ho to aap app ke Help & FAQ section se contact support use kar sakte hain (backend integration ke baad).',
            // ),
            //
            // SizedBox(height: AppSizes.paddingLG),
            // _footerNote(context),
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



  ///Other Sections

  // Widget _policySection({required String title, required String body}) {
  //   return Container(
  //     width: double.infinity,
  //     margin: EdgeInsets.only(bottom: AppSizes.paddingSM),
  //     padding: EdgeInsets.all(AppSizes.paddingLG),
  //     decoration: BoxDecoration(
  //       color: AppColors.whiteBackground,
  //       borderRadius: BorderRadius.circular(AppSizes.radiusMD),
  //       boxShadow: AppShadows.cardShadow,
  //       border: Border.all(color: AppColors.borderLight),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(title, style: AppTextStyles.subheading),
  //         SizedBox(height: 8),
  //         Text(
  //           body,
  //           style: AppTextStyles.body.copyWith(color: AppColors.textDark),
  //         ),
  //       ],
  //     ),
  //   );
  // }


  ///Last Section
  // Widget _footerNote(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.all(AppSizes.padding),
  //     decoration: BoxDecoration(
  //       color: AppColors.lightPurple,
  //       borderRadius: BorderRadius.circular(AppSizes.radius),
  //     ),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Icon(Icons.info_outline, color: AppColors.primaryPurple),
  //         SizedBox(width: AppSizes.paddingSM),
  //         Expanded(
  //           child: Text(
  //             'Note: Ye policy student project ke liye simplified hai. Agar aap production publish karte hain to proper legal policy + consent screens recommended hain.',
  //             style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
