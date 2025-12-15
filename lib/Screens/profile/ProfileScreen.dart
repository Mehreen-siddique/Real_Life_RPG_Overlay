//
// import 'package:flutter/material.dart';
// import 'package:real_life_rpg/Models/users.dart';
// import 'package:real_life_rpg/Screens/Settings/SettingsScreen.dart';
// import 'package:real_life_rpg/Screens/profile/EditProfile.dart';
// import 'package:real_life_rpg/utils/constants.dart';
//
// class profileScreen extends StatefulWidget {
//   const profileScreen({super.key});
//
//   @override
//   State<profileScreen> createState() => _profileScreenState();
// }
//
// class _profileScreenState extends State<profileScreen> {
//   late UserModel user;
//
//   @override
//   void initState() {
//     super.initState();
//     user = UserModel.dummy();
//   }
// // statistics card section
//
//   Widget _buildStatCard({
//     required IconData icon,
//     required String label,
//     required int value,
//     required int maxValue,
//     required Color color,
//     bool showProgress = true,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground,
//         borderRadius: BorderRadius.circular(AppSizes.radius),
//         boxShadow: AppShadows.cardShadow,
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 32),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: AppTextStyles.caption,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '$value',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           if (showProgress) ...[
//             const SizedBox(height: 8),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(4),
//               child: LinearProgressIndicator(
//                 value: value / maxValue,
//                 minHeight: 6,
//                 backgroundColor: AppColors.lightBackground,
//                 valueColor: AlwaysStoppedAnimation<Color>(color),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.body.copyWith(fontSize: 15),
//         ),
//         Text(
//           value,
//           style: AppTextStyles.bodyDark.copyWith(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     );
//   }
//
//   //Achievements section
//
//   Widget _buildAchievementRow({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required bool isUnlocked,
//   }) {
//     return Row(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: isUnlocked
//                 ? color.withOpacity(0.2)
//                 : AppColors.textGray.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             icon,
//             color: isUnlocked ? color : AppColors.textGray,
//             size: 28,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: AppTextStyles.bodyDark.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: isUnlocked ? AppColors.textDark : AppColors.textGray,
//                 ),
//               ),
//               Text(
//                 subtitle,
//                 style: AppTextStyles.caption,
//               ),
//             ],
//           ),
//         ),
//         if (isUnlocked)
//           Icon(Icons.check_circle, color: color, size: 24)
//         else
//           Icon(Icons.lock_outline, color: AppColors.textGray, size: 24),
//       ],
//     );
//   }
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//       body: CustomScrollView(
//         slivers: [
//
//        //AppBar
//         SliverAppBar(
//         expandedHeight: 250,
//         pinned: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => EditProfileScreen(),
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => SettingsScreen()),
//               );
//             },
//           ),
//         ],
//
//         flexibleSpace: FlexibleSpaceBar(
//           background: ClipRRect(
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(30),
//               bottomRight: Radius.circular(30),
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: AppGradients.primaryPurple,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 60),
//
//                   // Avatar
//                   Container(
//                     width: 100,
//                     height: 100,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       // border: Border.all(
//                       //   color: AppColors.highlightGold,
//                       //   width: 4,
//                       // ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.highlightGold.withOpacity(0.5),
//                           blurRadius: 20,
//                           spreadRadius: 3,
//                         ),
//                       ],
//                     ),
//                     child: CircleAvatar(
//                       backgroundColor: Colors.white,
//                       child: Icon(
//                         Icons.person,
//                         size: 50,
//                         color: AppColors.primaryPurple,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   Text(
//                     user.name,
//                     style: AppTextStyles.headingWhite.copyWith(fontSize: 24),
//                   ),
//
//                   const SizedBox(height: 8),
//
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: AppColors.highlightGold,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       'LEVEL ${user.level}',
//                       style: AppTextStyles.bodyDark,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//
//         SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: AppColors.whiteBackground,
//                       borderRadius: BorderRadius.circular(AppSizes.radius),
//                       boxShadow: AppShadows.cardShadow,
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Level ${user.level}',
//                               style: AppTextStyles.subheading,
//                             ),
//                             Text(
//                               '${user.currentXP} / ${user.xpForNextLevel} XP',
//                               style: AppTextStyles.body.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.primaryPurple,
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 12,),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: user.xpProgress,
//                             minHeight: 16,
//                             backgroundColor: AppColors.lightBackground,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               AppColors.highlightGold,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 8,),
//                         Text('${((user.xpProgress) * 100).toInt()}% to next level',
//                           style: AppTextStyles.caption,)
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24,),
//                   Text(
//                     'Character Stats',
//                     style: AppTextStyles.subheading.copyWith(fontSize: 18),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                   child: _buildStatCard(
//                   icon: Icons.favorite,
//                     label: 'Health',
//                     value: user.health,
//                     maxValue: user.maxHealth,
//                     color: AppColors.accentGreen,
//                   ),
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: _buildStatCard(
//                           icon: Icons.fitness_center,
//                           label: 'Strength',
//                           value: user.strength,
//                           maxValue: user.maxStrength,
//                           color: AppColors.highlightGold,
//                         ),
//                       ),
//
//
//                     ],
//                   ),
//                   SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildStatCard(
//                           icon: Icons.monetization_on,
//                           label: 'Gold',
//                           value: user.goldCoins,
//                           maxValue: 9999,
//                           color: AppColors.highlightGold,
//                           showProgress: false,
//                         ),
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: _buildStatCard(
//                           icon: Icons.school,
//                           label: 'Intelligence',
//                           value: user.intelligence,
//                           maxValue: user.maxIntelligence,
//                           color: AppColors.accentBlue,
//                         ),
//                       ),
//
//
//                     ],
//                   ),
//                   SizedBox(height: 24,),
//                   Text(
//                     'Achievements',
//                     style: AppTextStyles.subheading.copyWith(fontSize: 18),
//                   ),
//                   SizedBox(height: 16),
//                   Container(
//                     padding: EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: AppColors.whiteBackground,
//                       borderRadius: BorderRadius.circular(AppSizes.radius),
//                       boxShadow: AppShadows.cardShadow,
//                     ),
//                     child: Column(
//                       children: [
//                         _buildAchievementRow(
//                           icon: Icons.local_fire_department,
//                           title: '7 Day Streak',
//                           subtitle: 'Keep the momentum going!',
//                           color: AppColors.highlightGold,
//                           isUnlocked: true,
//                         ),
//                         Divider(height: 24),
//                         _buildAchievementRow(
//                           icon: Icons.star,
//                           title: 'First Quest',
//                           subtitle: 'Completed your first quest',
//                           color: AppColors.highlightGold,
//                           isUnlocked: true,
//                         ),
//                         Divider(height: 24),
//                         _buildAchievementRow(
//                           icon: Icons.emoji_events,
//                           title: 'Level 10',
//                           subtitle: 'Reached level 10',
//                           color: AppColors.primaryPurple,
//                           isUnlocked: true,
//                         ),
//                         Divider(height: 24),
//                         _buildAchievementRow(
//                           icon: Icons.people,
//                           title: 'Social Butterfly',
//                           subtitle: 'Complete 10 social quests',
//                           color: AppColors.textGray,
//                           isUnlocked: false,
//                         ),
//
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   // Statistics
//                   Text(
//                     'Statistics',
//                     style: AppTextStyles.subheading.copyWith(fontSize: 18),
//                   ),
//                   SizedBox(height: 16),
//                   Container(
//                     padding:EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: AppColors.whiteBackground,
//                       borderRadius: BorderRadius.circular(AppSizes.radius),
//                       boxShadow: AppShadows.cardShadow,
//                     ),
//                     child: Column(
//                       children: [
//                         _buildStatRow('Total Quests', '156'),
//                          Divider(height: 24),
//                         _buildStatRow('Completed', '142'),
//                          Divider(height: 24),
//                         _buildStatRow('Success Rate', '91%'),
//                         Divider(height: 24),
//                         _buildStatRow('Days Active', '45'),
//                       ],
//                     ),
//
//                   ),
//                   SizedBox(height: 80),
//
//                 ],
//               ),
//
//             ),
//           ),
//
//
//         ],
//       ),
//
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_life_rpg/Screens/Settings/SettingsScreen.dart';
import 'package:real_life_rpg/Screens/profile/AchievementsScreen.dart';
import 'package:real_life_rpg/Screens/profile/EditProfile.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dummy user data
  final String userName = 'Warrior Khan';
  final String userClass = 'Explorer';
  final int userLevel = 12;
  final int currentXP = 850;
  final int requiredXP = 1200;
  final int totalQuests = 145;
  final int completedQuests = 128;
  final int daysActive = 45;

  // Character stats
  final int health = 85;
  final int strength = 72;
  final int intelligence = 68;
  final int gold = 1250;

  // Unlocked achievements count
  final int unlockedAchievements = 8;
  final int totalAchievements = 15;

  // Recent achievements (just for display)
  final List<Map<String, dynamic>> recentAchievements = [
    {
      'title': '7 Day Streak',
      'icon': Icons.local_fire_department,
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    },
    {
      'title': 'Quest Master',
      'icon': Icons.emoji_events,
      'gradient': [Color(0xFFFFD700), Color(0xFFFFA500)],
    },
    {
      'title': 'Level 10',
      'icon': Icons.stars,
      'gradient': AppColors.gradientPrimaryPurple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double xpProgress = currentXP / requiredXP;
    final int successRate = ((completedQuests / totalQuests) * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: AppSizes.paddingMD),
                _buildProfileHeader(xpProgress),
                SizedBox(height: AppSizes.paddingLG),
                _buildStatsSection(),
                SizedBox(height: AppSizes.paddingLG),
                _buildAchievementsSection(),
                SizedBox(height: AppSizes.paddingLG),
                _buildGeneralStats(successRate),
                SizedBox(height: AppSizes.paddingLG),
                _buildActionButtons(),
                SizedBox(height: AppSizes.paddingXL),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.secondaryPurple,
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            'Profile',
            style: AppTextStyles.headingWhite.copyWith(fontSize: 20),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: AppColors.textWhite),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(double xpProgress) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingLG),
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.primaryPurple,
                border: Border.all(
                  color: AppColors.borderGold,
                  width: 3,
                ),
                boxShadow: AppShadows.glowPurple,
              ),
              child: Center(
                child: Text(
                  userName.substring(0, 1),
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.padding),

            // Name & Class
            Text(
              userName,
              style: AppTextStyles.heading,
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSM + 4,
                vertical: AppSizes.paddingXS,
              ),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryPurple,
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              ),
              child: Text(
                userClass,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: AppSizes.padding),

            // Level & XP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stars, color: AppColors.highlightGold, size: 24),
                SizedBox(width: 8),
                Text(
                  'Level $userLevel',
                  style: AppTextStyles.subheading.copyWith(
                    color: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSizes.paddingSM),

            // XP Progress Bar
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  child: LinearProgressIndicator(
                    value: xpProgress,
                    backgroundColor: AppColors.statsBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                    minHeight: 10,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$currentXP / $requiredXP XP',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Character Stats',
            style: AppTextStyles.subheading,
          ),
          SizedBox(height: AppSizes.paddingSM),
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                _buildStatBar('Health', health, Icons.favorite, AppColors.errorRed),
                SizedBox(height: AppSizes.paddingSM),
                _buildStatBar('Strength', strength, Icons.fitness_center, AppColors.accentGreen),
                SizedBox(height: AppSizes.paddingSM),
                _buildStatBar('Intelligence', intelligence, Icons.lightbulb, AppColors.accentBlue),
                SizedBox(height: AppSizes.paddingSM),
                Divider(),
                SizedBox(height: AppSizes.paddingSM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on, color: AppColors.highlightGold, size: 28),
                    SizedBox(width: 8),
                    Text(
                      '$gold Gold',
                      style: AppTextStyles.statValueLarge.copyWith(
                        color: AppColors.highlightGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: AppSizes.paddingSM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyles.body),
                  Text(
                    '$value/100',
                    style: AppTextStyles.captionBold.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                child: LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: AppColors.statsBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: AppTextStyles.subheading,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AchievementsScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingSM),
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                // Achievement Progress Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: AppColors.highlightGold, size: 28),
                    SizedBox(width: 8),
                    Text(
                      '$unlockedAchievements / $totalAchievements',
                      style: AppTextStyles.statValueLarge.copyWith(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  child: LinearProgressIndicator(
                    value: unlockedAchievements / totalAchievements,
                    backgroundColor: AppColors.statsBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.highlightGold),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${((unlockedAchievements / totalAchievements) * 100).toInt()}% Complete',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSizes.padding),
                Divider(),
                SizedBox(height: AppSizes.paddingSM),

                // Recent Achievements
                Text(
                  'Recent Unlocked',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: AppSizes.paddingSM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: recentAchievements.map((achievement) {
                    return _buildAchievementBadge(
                      achievement['title'] as String,
                      achievement['icon'] as IconData,
                      achievement['gradient'] as List<Color>,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String title, IconData icon, List<Color> gradient) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textWhite, size: 28),
        ),
        SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralStats(int successRate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: AppTextStyles.subheading,
          ),
          SizedBox(height: AppSizes.paddingSM),
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                _buildStatItem(
                  'Total Quests',
                  totalQuests.toString(),
                  Icons.list_alt,
                  AppColors.primaryPurple,
                ),
                SizedBox(height: AppSizes.padding),
                _buildStatItem(
                  'Completed',
                  completedQuests.toString(),
                  Icons.check_circle,
                  AppColors.accentGreen,
                ),
                SizedBox(height: AppSizes.padding),
                _buildStatItem(
                  'Success Rate',
                  '$successRate%',
                  Icons.trending_up,
                  AppColors.accentBlue,
                ),
                SizedBox(height: AppSizes.padding),
                _buildStatItem(
                  'Days Active',
                  daysActive.toString(),
                  Icons.calendar_today,
                  AppColors.highlightGold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSizes.paddingSM),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: AppSizes.padding),
        Expanded(
          child: Text(label, style: AppTextStyles.body),
        ),
        Text(
          value,
          style: AppTextStyles.statValue.copyWith(
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  EditProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                elevation: 0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryPurple,
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 4),
                alignment: Alignment.center,
                child: Text(
                  'Edit Profile',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.paddingSM),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  AchievementsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 4),
                side: BorderSide(color: AppColors.primaryPurple, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                ),
              ),
              child: Text(
                'View Achievements',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
