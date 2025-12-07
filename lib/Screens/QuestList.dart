import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/utils/constants.dart';

import '../widgets/quest_card.dart';

class Questlist extends StatefulWidget {
  const Questlist({super.key});

  @override
  State<Questlist> createState() => _QuestlistState();
}

class _QuestlistState extends State<Questlist> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Quest> _allQuests = [];
  List<Quest> _activeQuests = [];
  List<Quest> _completedQuests = [];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadQuests();
  }

  void _loadQuests() {
    _allQuests = Quest.getDailyQuests();
    _activeQuests = _allQuests.where((q) => !q.isCompleted).toList();
    _completedQuests = _allQuests.where((q) => q.isCompleted).toList();
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }




//header build...
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientPrimaryPurple,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: AppColors.highlightGold,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '7 Day Streak',
                      style: AppTextStyles.bodyWhite.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Quest Log',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_activeQuests.length} active quests',
            style: AppTextStyles.bodyWhite.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  //tab section
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 5),
          ),
       ],
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        indicator: BoxDecoration(
          gradient: AppGradients.primaryPurple,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGray,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        labelPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        tabs: [
          Tab(text: 'All  (${_allQuests.length})'),
          Tab(text: 'Active  (${_activeQuests.length})'),
          Tab(text: 'Done  (${_completedQuests.length})'),
        ],
      ),
    );
  }

//quest section

  Widget _buildQuestList(List<Quest> quests) {
    // Empty State
    if (quests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_late_outlined,
                size: 90,
                color: AppColors.textGray.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                'No quests in this tab',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 20,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'All your quests will appear here when created.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textGray.withOpacity(0.7),
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Real Quest List - Using Your Perfect QuestCard
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Extra bottom for FAB
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: QuestCard(
            quest: quest,
            onTap: () {
              // QuestsScreen pe tap karne se kuch nahi hoga (dialog nahi khulega)
              // Tum yahan swipe to complete, long press, ya button se complete karogi
              // Abhi ke liye blank rakha hai — bilkul safe aur clean
            },
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: AppColors.lightBackground,
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          // header section
          _buildHeader(),

          //tab bar section
          _buildTabBar(),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestList(_allQuests),
                _buildQuestList(_activeQuests),
                _buildQuestList(_completedQuests),
              ],
            ),
          ),

        ],
      )),
    );
  }
}
