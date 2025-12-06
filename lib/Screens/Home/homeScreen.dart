// screens/home_screen.dart
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Widgets/BottomBar.dart';
import 'package:real_life_rpg/Widgets/stats_bar.dart';
import '../../Models/users.dart';
import '../../widgets/xp_progress.dart';
import '../../widgets/quest_card.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserModel user;
  late List<Quest> quests;

  @override
  void initState() {
    super.initState();
    user = UserModel.dummy();
    quests = Quest.getDailyQuests();
  }

  void _completeQuest(Quest quest) {
    setState(() {
      int index = quests.indexWhere((q) => q.id == quest.id);
      if (index != -1) {
        quests[index] = Quest(
          id: quest.id,
          title: quest.title,
          description: quest.description,
          type: quest.type,
          xpReward: quest.xpReward,
          statBonus: quest.statBonus,
          isCompleted: true,
          icon: quest.icon,
          gradientColors: quest.gradientColors,
        );

        user = UserModel(
          id: user.id,
          name: user.name,
          level: user.level,
          currentXP: user.currentXP + quest.xpReward,
          xpForNextLevel: user.xpForNextLevel,
          health: user.health + quest.statBonus,
          maxHealth: user.maxHealth,
          strength: user.strength,
          maxStrength: user.maxStrength,
          intelligence: user.intelligence,
          maxIntelligence: user.maxIntelligence,
          goldCoins: user.goldCoins + 10,
        );

        _showCompletionAnimation(quest);
      }
    });
  }

  void _showCompletionAnimation(Quest quest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.leaderboardSilver.withOpacity(0.9),
                    AppColors.cardBackground,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.leaderboardSilver, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.leaderboardSilver.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.accentGreen,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quest Completed!',
                    style: AppTextStyles.heading.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quest.title,
                    style: AppTextStyles.subheading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.highlightGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${quest.xpReward} XP',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${quest.statBonus} Health',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }


  void _showQuestDialog(Quest quest) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.cardBackground,
                    AppColors.leaderboardSilver,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                // border: Border.all(color: , width: 2),
                // boxShadow: [
                //   BoxShadow(
                //     color: quest.color.withOpacity(0.4),
                //     blurRadius: 20,
                //     spreadRadius: 3,
                //   ),
                // ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      // color: quest.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                      // border: Border.all(color: quest.color, width: 3),
                    ),
                    child: Icon(
                      quest.icon,
                      color: AppColors.leaderboardSilver,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    quest.title,
                    style: AppTextStyles.heading.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quest.description,
                    style: AppTextStyles.body.copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Rewards',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRewardChip(
                              icon: Icons.stars,
                              color: AppColors.highlightGold,
                              text: '+${quest.xpReward} XP',
                            ),
                            _buildRewardChip(
                              icon: Icons.favorite,
                              color: AppColors.accentGreen,
                              text: '+${quest.statBonus}',
                            ),
                            _buildRewardChip(
                              icon: Icons.monetization_on,
                              color: AppColors.highlightGold,
                              text: '+10',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(color: AppColors.textGray),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textGray,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _completeQuest(quest);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.leaderboardSilver,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Complete Quest',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }


  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              color: AppColors.primaryPurple,
                border: Border.all(color: AppColors.highlightGold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.highlightGold.withOpacity(0.3),
                    blurRadius: 3,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  user.name,
                  style: AppTextStyles.heading.copyWith(fontSize: 20),
                ),
                Text(
                  'Assalam Alaikum! 👋',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primaryPurple
                  )
                ),
                const SizedBox(height: 4),
              ],
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [
            //     AppColors.highlightGold.withOpacity(0.3),
            //     AppColors.highlightGold.withOpacity(0.1),
            //   ],
            // ),
            color: AppColors.highlightGold,
            borderRadius: BorderRadius.circular(20),
            // // border: Border.all(color: AppColors.highlightGold, width: 2),
            // boxShadow: [
            //   BoxShadow(
            //     color: AppColors.highlightGold.withOpacity(0.3),
            //     blurRadius: 10,
            //     spreadRadius: 1,
            //   ),
            // ],
          ),
          child: Row(
            children: [
              const Icon(
                FontAwesomeIcons.coins,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${user.goldCoins}',
                style: AppTextStyles.statValue.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowPurple.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield,
                color: AppColors.highlightGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Character Stats',
                style: AppTextStyles.subheading,
              ),
            ],
          ),
          const SizedBox(height: 20),

          StatBar(
            label: 'Health',
            current: user.health,
            max: user.maxHealth,
            color: AppColors.accentGreen,
            icon: Icons.favorite,
          ),

         SizedBox(height: 10,),
          StatBar(
            label: 'Strength',
            current: user.strength,
            max: user.maxStrength,
            color: Color(0xFFF87171),
            icon: Icons.fitness_center,
          ),

          SizedBox(height: 10,),

          StatBar(
            label: 'Intelligence',
            current: user.intelligence,
            max: user.maxIntelligence,
            color: AppColors.accentBlue,
            icon: Icons.school,
          ),
        ],
      ),
    );
  }


  Widget _buildQuestsSection(int completed, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 8),
            Text(

              'Today\'s Quests',
              style: AppTextStyles.subheading.copyWith(
                fontSize: 20,
                color: AppColors.primaryPurple

              ),
            ),
            SizedBox(width: 150,),
            Text(
              '$completed/$total',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textGray,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quests.length,
          itemBuilder: (context, index) {
            return QuestCard(
              quest: quests[index],
              onTap: () {
                if (!quests[index].isCompleted) {
                  _showQuestDialog(quests[index]);
                }
              },
            );
          },
        ),
      ],
    );
  }


  Widget _buildRewardChip({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    int completedQuests = quests
        .where((q) => q.isCompleted)
        .length;
    int totalQuests = quests.length;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBody: true, // Important for transparent bottom nav
      body: Container(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 100, // Space for bottom nav
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                XPProgressBar(
                  level: user.level,
                  currentXP: user.currentXP,
                  xpForNextLevel: user.xpForNextLevel,
                ),
                const SizedBox(height: 24),

                _buildCharacterStats(),
                const SizedBox(height: 24),

                _buildQuestsSection(completedQuests, totalQuests),
              ],
            ),
          ),
        ),
      ),


      // bottomNavigationBar: RPGBottomNavBar(
      //   currentIndex: _currentNavIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _currentNavIndex = index;
      //     });
      //
      //     // Show coming soon for other tabs
      //     if (index != 0) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(
      //           content: Text(_getTabName(index) + ' - Coming Soon!'),
      //           backgroundColor: AppColors.primaryPurple,
      //           duration: const Duration(seconds: 1),
      //         ),
      //       );
      //     }
      //   },
      // ),



    );
  }
}
