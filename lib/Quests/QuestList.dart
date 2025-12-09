// screens/quest/quest_list_screen.dart

import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Quests/QuestDetails.dart';
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
  int _selectedTabIndex = 0;
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
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quest Log',style: AppTextStyles.screenHeading,
          ),
          SizedBox(height: 10,),
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightBackgroundBox,
              border: Border.all(
                  color: AppColors.strokeColor, width: 1.5
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SizedBox(width: 10,),
                Icon(
                  Icons.search,
                  color: AppColors.textGray,
                  size: 20,

                ),
                SizedBox(width: 10,),
                Text(
                  "Search Quest",
                  style: AppTextStyles.body,
                )

              ],
            ),
          )

        ],
      ),
    );
  }


  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Container(
        child: Row(
          children: [
            // All Quest Button
            Expanded(
              child: _buildTabButton(
                title: "All Quest",
                count: _allQuests.length,
                isSelected: _selectedTabIndex == 0,
                onTap: () {
                  setState(() {
                    _selectedTabIndex = 0;
                    _tabController.index = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),

            // Active Button
            Expanded(
              child: _buildTabButton(
                title: "Active",
                count: _activeQuests.length,
                isSelected: _selectedTabIndex == 1,
                onTap: () {
                  setState(() {
                    _selectedTabIndex = 1;
                    _tabController.index = 1;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),

            // completed Button
            Expanded(
              child: _buildTabButton(
                title: "completed",
                count: _completedQuests.length,
                isSelected: _selectedTabIndex == 2,
                onTap: () {
                  setState(() {
                    _selectedTabIndex = 2;
                    _tabController.index = 2;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppGradients.secondaryPurple
              : null,
          color: isSelected ? null : AppColors.lightBackgroundBox,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: isSelected? AppTextStyles.tabSelected: AppTextStyles.tabUnselected
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: isSelected? AppTextStyles.tabSelected : AppTextStyles.tabUnselected

            ),
          ],
        ),
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
        return QuestCard(
          quest: quests[index],
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestDetailScreen(quest: quests[index]),
              ),
            );

            if (result == true) {
              _loadQuests();
            }
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

           //header section
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
