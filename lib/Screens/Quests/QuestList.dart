// screens/quest/quest_list_screen.dart

import 'package:flutter/material.dart';
import 'package:real_life_rpg/Screens/Quests/CreateQuest.dart';
import 'package:real_life_rpg/Screens/Quests/QuestDetails.dart';
import 'package:real_life_rpg/Services/QuestFirestore/questfirestore.dart';
import 'package:real_life_rpg/Widgets/quest_card.dart';
import 'package:real_life_rpg/utils/constants.dart';

import '../../Models/quest.dart';



class QuestListScreen extends StatefulWidget {
  const QuestListScreen({Key? key}) : super(key: key);

  @override
  State<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends State<QuestListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  final QuestServiceFirestore _questService = QuestServiceFirestore();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
// header section
  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? AppColors.darkCard : null;
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: headerBg,
          gradient: isDark ? null : AppGradients.secondaryPurple,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(
                  color: AppColors.primaryPurple.withOpacity(0.4),
                  width: 1,
                )
              : null,
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quest Log', style: AppTextStyles.screenHeading.copyWith(color: Colors.white)),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search quest',
                hintStyle: TextStyle(color: Colors.white.withOpacity(isDark ? 0.7 : 0.85)),
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.white70 : Colors.white),
                filled: true,
                fillColor: isDark ? AppColors.darkCardAlt : Colors.white24,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.primaryPurple.withOpacity(0.4)
                        : Colors.white.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.primaryPurple.withOpacity(0.8) : Colors.white,
                    width: 1.5,
                  ),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            )
          ],
        ),
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
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabBg = isDark ? AppColors.darkCardAlt : AppColors.lightBackgroundBox;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppGradients.secondaryPurple
              : null,
          color: isSelected ? null : tabBg,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.primaryPurple.withOpacity(isDark ? 0.25 : 0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: isSelected
                  ? AppTextStyles.tabSelected
                  : AppTextStyles.tabUnselected.copyWith(
                      color: isDark ? AppColors.textLavender : AppColors.primaryPurple,
                    ),
            ),
          ],
        ),
      ),
    );
  }

// quest card section
  Widget _buildQuestListStream(Stream<List<Quest>> questStream) {
    return StreamBuilder<List<Quest>>(
      stream: questStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryPurple),
                const SizedBox(height: 16),
                Text('Loading quests...', style: AppTextStyles.body.copyWith(color: AppColors.textGray)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  "Error loading quests",
                  style: AppTextStyles.subheading.copyWith(color: Colors.redAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: AppTextStyles.body.copyWith(color: AppColors.textGray),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final quests = snapshot.data ?? [];
        final filteredQuests = _searchQuery.isEmpty
            ? quests
            : quests.where((q) {
                final title = q.title.toLowerCase();
                final description = q.description.toLowerCase();
                return title.contains(_searchQuery) || description.contains(_searchQuery);
              }).toList();

        if (filteredQuests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
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
          itemCount: filteredQuests.length,
          itemBuilder: (context, index) {
            return QuestCard(
              quest: filteredQuests[index],
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestDetailScreen(quest: filteredQuests[index]),
                  ),
                );
                if (result == true) {
                  setState(() {});
                }
              },
            );
          },
        );
      },
    );
  }

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
              setState(() {});
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                  _buildQuestListStream(_questService.allUserQuestsStream()),
                  _buildQuestListStream(_questService.activeQuestsStream()),
                  _buildQuestListStream(_questService.completedQuestsStream()),
                ],
              ),
            ),
            
           
          ],
        ),
      ),

   

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom:90),
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateQuestScreen()));
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
