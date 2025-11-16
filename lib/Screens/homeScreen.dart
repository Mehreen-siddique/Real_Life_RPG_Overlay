import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Widgets/stats_bar.dart';
import 'package:real_life_rpg/Widgets/xp_progress.dart';
import 'package:real_life_rpg/utils/constants.dart';

import '../Models/users.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late UserModel user;
  late List<Quest> quests;

  @override
  void initState() {
    super.initState();
    // Load dummy data
    user = UserModel.dummy();
    quests = Quest.getDailyQuests();
  }

  void _completeQuest(Quest quest) {
    setState(() {
      // Find and update quest
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
          color: quest.color,
        );

        // Update user XP
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

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quest completed! +${quest.xpReward} XP'),
            backgroundColor: AppColors.emeraldGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }



  //header of the screen...
  Widget buildHeader(){
    return Row(
      children: [
        //Avatar
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              AppColors.primaryPurple,
              AppColors.electricBlue
            ]),
            border: Border.all(
              color: AppColors.goldYellow,
              width: 3
            )
          ),
      child:  Icon(
        Icons.person,
        color: Colors.white,
        size: 32,
      ),
    ),
        SizedBox(width: 12,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assalam Alaikum! 👋',
              style: AppTextStyles.body,
            ),
    const SizedBox(width: 8),
    Text(
    '${user.goldCoins}',
    style: AppTextStyles.statValue.copyWith(
    color: AppColors.goldYellow,
    )
    ),




          ],
        )

      ],
    );
  }

  Widget buildCharacterStats(){
    return Container(
 padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.3),
          width: 1,
        )
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            '⚔️ Character Stats',
            style: AppTextStyles.subheading,
          ),
           SizedBox(height: 16),

          StatBar(
            label: 'Health',
            current: user.health,
            max: user.maxHealth,
            color: AppColors.emeraldGreen,
            icon: Icons.favorite,
          ),

          StatBar(
            label: 'Strength',
            current: user.strength,
            max: user.maxStrength,
            color: AppColors.rubyRed,
            icon: Icons.fitness_center,
          ),

          StatBar(
            label: 'Intelligence',
            current: user.intelligence,
            max: user.maxIntelligence,
            color: AppColors.electricBlue,
            icon: Icons.school,
          ),

        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
          child:
      SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            SizedBox(height: 20),
            // xp progress bar

            XPProgressBar(
              level: user.level,
              currentXP: user.currentXP,
              xpForNextLevel: user.xpForNextLevel,
            ),

            SizedBox(height: 20),

                //character stats
            buildCharacterStats(),


            SizedBox(height: 24),




          ],
        ),
      )

      ),
    );
  }
}
