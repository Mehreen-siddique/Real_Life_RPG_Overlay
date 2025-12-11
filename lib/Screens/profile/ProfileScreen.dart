
import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/users.dart';
import 'package:real_life_rpg/Screens/profile/EditProfile.dart';
import 'package:real_life_rpg/utils/constants.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({super.key});

  @override
  State<profileScreen> createState() => _profileScreenState();
}

class _profileScreenState extends State<profileScreen> {
  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = UserModel.dummy();
  }
// statistics card section

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required int maxValue,
    required Color color,
    bool showProgress = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value / maxValue,
                minHeight: 6,
                backgroundColor: AppColors.lightBackground,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontSize: 15),
        ),
        Text(
          value,
          style: AppTextStyles.bodyDark.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  //Achievements section

  Widget _buildAchievementRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isUnlocked,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isUnlocked
                ? color.withOpacity(0.2)
                : AppColors.textGray.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isUnlocked ? color : AppColors.textGray,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyDark.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? AppColors.textDark : AppColors.textGray,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        if (isUnlocked)
          Icon(Icons.check_circle, color: color, size: 24)
        else
          Icon(Icons.lock_outline, color: AppColors.textGray, size: 24),
      ],
    );
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          //AppBar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.primaryPurple,
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),

            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  EditProfileScreen(),
                    ),);

                },
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryPurple,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                //Avatar Space
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.highlightGold,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.highlightGold.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child:CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ),
                    SizedBox(height: 16,),
                    Text(
                      user.name,
                      style: AppTextStyles.heading.copyWith(fontSize: 24),
                    ),
                    SizedBox(height: 8,),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.highlightGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'LEVEL ${user.level}',
                        style: AppTextStyles.bodyDark,
                      ),
                    )

                  ],
                ),
              ),
            ),

          ),

          //Content of screen
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.whiteBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      boxShadow: AppShadows.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Level ${user.level}',
                              style: AppTextStyles.subheading,
                            ),
                            Text(
                              '${user.currentXP} / ${user.xpForNextLevel} XP',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12,),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: user.xpProgress,
                            minHeight: 16,
                            backgroundColor: AppColors.lightBackground,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.highlightGold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8,),
                        Text('${((user.xpProgress) * 100).toInt()}% to next level',
                          style: AppTextStyles.caption,)
                      ],
                    ),
                  ),
                  SizedBox(height: 24,),
                  Text(
                    'Character Stats',
                    style: AppTextStyles.subheading.copyWith(fontSize: 18),
                  ),
                  Row(
                    children: [
                      Expanded(
                  child: _buildStatCard(
                  icon: Icons.favorite,
                    label: 'Health',
                    value: user.health,
                    maxValue: user.maxHealth,
                    color: AppColors.accentGreen,
                  ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.fitness_center,
                          label: 'Strength',
                          value: user.strength,
                          maxValue: user.maxStrength,
                          color: AppColors.highlightGold,
                        ),
                      ),


                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.monetization_on,
                          label: 'Gold',
                          value: user.goldCoins,
                          maxValue: 9999,
                          color: AppColors.highlightGold,
                          showProgress: false,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.school,
                          label: 'Intelligence',
                          value: user.intelligence,
                          maxValue: user.maxIntelligence,
                          color: AppColors.accentBlue,
                        ),
                      ),


                    ],
                  ),
                  SizedBox(height: 24,),
                  Text(
                    'Achievements',
                    style: AppTextStyles.subheading.copyWith(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.whiteBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      boxShadow: AppShadows.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _buildAchievementRow(
                          icon: Icons.local_fire_department,
                          title: '7 Day Streak',
                          subtitle: 'Keep the momentum going!',
                          color: AppColors.highlightGold,
                          isUnlocked: true,
                        ),
                        Divider(height: 24),
                        _buildAchievementRow(
                          icon: Icons.star,
                          title: 'First Quest',
                          subtitle: 'Completed your first quest',
                          color: AppColors.highlightGold,
                          isUnlocked: true,
                        ),
                        Divider(height: 24),
                        _buildAchievementRow(
                          icon: Icons.emoji_events,
                          title: 'Level 10',
                          subtitle: 'Reached level 10',
                          color: AppColors.primaryPurple,
                          isUnlocked: true,
                        ),
                        Divider(height: 24),
                        _buildAchievementRow(
                          icon: Icons.people,
                          title: 'Social Butterfly',
                          subtitle: 'Complete 10 social quests',
                          color: AppColors.textGray,
                          isUnlocked: false,
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Statistics
                  Text(
                    'Statistics',
                    style: AppTextStyles.subheading.copyWith(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding:EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.whiteBackground,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      boxShadow: AppShadows.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('Total Quests', '156'),
                         Divider(height: 24),
                        _buildStatRow('Completed', '142'),
                         Divider(height: 24),
                        _buildStatRow('Success Rate', '91%'),
                        Divider(height: 24),
                        _buildStatRow('Days Active', '45'),
                      ],
                    ),

                  ),
                  SizedBox(height: 80),

                ],
              ),

            ),
          ),


        ],
      ),

    );
  }
}
