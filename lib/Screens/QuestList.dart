import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/utils/constants.dart';

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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: AppColors.lightBackground,
      body: SafeArea(child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          // header section
          _buildHeader(),


        ],
      )),
    );
  }
}
