import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Widgets/quest_card.dart';
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

  void completeQuest(Quest quest) {
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

  Widget buildBottomNav() {
    return BottomAppBar(
      color: AppColors.cardBackground,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.primaryPurple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.list, color: AppColors.textGray),
            onPressed: () {},
          ),
          const SizedBox(width: 40), // Space for FAB
          IconButton(
            icon: const Icon(Icons.people, color: AppColors.textGray),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.textGray),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

void showQuestDialog(Quest quest) {
  showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(quest.icon, color: quest.color, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  quest.title,
                  style: AppTextStyles.subheading,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(quest.description, style: AppTextStyles.body),
              const SizedBox(height: 16),
              Text(
                'Rewards:',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.stars, color: AppColors.goldYellow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+${quest.xpReward} XP',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.favorite, color: AppColors.emeraldGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+${quest.statBonus} Health',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.body.copyWith(color: AppColors.textGray),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                completeQuest(quest);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: quest.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Complete Quest',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
  );
}

  Widget buildQuestSection(int completed, int total){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // header section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🎯 Today\'s Quests',
              style: AppTextStyles.subheading,
            ),

            Container(
              padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completed/$total',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 16),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          itemCount: quests.length,
            itemBuilder: (context, index){
    return QuestCard(
    quest: quests[index],
    onTap: () {
    if (!quests[index].isCompleted) {
    showQuestDialog(quests[index]);
    }
    });
    }
        )

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedQuests = quests.where((q) => q.isCompleted).length;
    int totalQuests = quests.length;

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
            // Today's Quests
            buildQuestSection(completedQuests, totalQuests),



          ],
        ),
      )

      ),
    );
  }
}
