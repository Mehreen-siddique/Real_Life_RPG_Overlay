// screens/quest/quest_list_screen.dart

import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/utils/constants.dart';
import '../Widgets/quest_card.dart' show QuestCard;


class QuestListScreen extends StatefulWidget {
  const QuestListScreen({Key? key}) : super(key: key);

  @override
  State<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends State<QuestListScreen>
    with SingleTickerProviderStateMixin {
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
    // Use existing Quest.getDailyQuests() method
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
// header section
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

  //tabbar section
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppGradients.primaryPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGray,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        tabs: [
          Tab(text: 'All (${_allQuests.length})'),
          Tab(text: 'Active (${_activeQuests.length})'),
          Tab(text: 'Done (${_completedQuests.length})'),
        ],
      ),
    );
  }

// quest card section
  Widget _buildQuestList(List<Quest> quests) {
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: AppColors.textGray.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No quests here',
              style: AppTextStyles.subheading.copyWith(
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first quest to get started!',
              style: AppTextStyles.body,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        // Use existing QuestCard widget from home screen
        return QuestCard(
          quest: quests[index],

          onTap: () async {
            // final result = await Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => QuestDetailScreen(quest: quests[index]),
            //   ),
            // );
            //
            // if (result == true) {
            //   _loadQuests();
            // }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        extendBody: true,
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
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
        ),
      ),

      // Floating Action Button
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: (){
      //     // final result = await Navigator.push(
      //     //   context,
      //     //   MaterialPageRoute(
      //     //     builder: (_) => const CreateQuestScreen(),
      //     //   ),
      //     // );
      //     //
      //     // if (result == true) {
      //     //   _loadQuests();
      //     // }
      //   },
      //   backgroundColor: AppColors.primaryPurple,
      //   icon:  Icon(Icons.add),
      //   label:  Text('New Quest'),
      // ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom:90),
          child: FloatingActionButton.extended(
            onPressed: () {
              // Navigator.push(...).then(...);
            },
            backgroundColor: AppColors.primaryPurple,
            icon: Icon(Icons.add,
              color: AppColors.lightBackground,
            ),
            label: Text('New Quest',
              style: AppTextStyles.bodyWhite,
            ),
          ),
        ),
    );
  }






}
