
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/quest.dart';
import '../../Services/AuthenticationServices/AuthServices.dart';
import '../../Services/DataServices/dataServices.dart';
import '../../Widgets/xp_progress.dart';
import '../../utils/constants.dart' show AppColors, AppTextStyles; // AuthService import

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
    // User data load real-time start karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthService>(context, listen: false);
      final dataService = Provider.of<DataService>(context, listen: false);

      if (auth.isAuthenticated && auth.user != null) {
        dataService.startListeningToUser(auth.user!.uid);
      }
    });
  }

  Future<void> _completeQuest(Quest quest) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);

    if (quest.id == null || !auth.isAuthenticated || auth.user == null) return;

    try {

      int xpToAdd = quest.xpReward ?? 0;
      int coinsToAdd = quest.goldReward ?? 10;
      int healthBonus = quest.statBonus ?? 0;

      _showCompletionAnimation(quest);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't complete quest: $e")),
        );
      }
    }
  }

  void _showCompletionAnimation(Quest quest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.leaderboardSilver.withOpacity(0.9), AppColors.cardBackground],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.leaderboardSilver, width: 2),
            boxShadow: [
              BoxShadow(color: AppColors.leaderboardSilver.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.accentGreen, size: 80),
              const SizedBox(height: 16),
              Text('Quest Completed!', style: AppTextStyles.heading.copyWith(fontSize: 22)),
              const SizedBox(height: 12),
              Text(quest.title, style: AppTextStyles.subheading, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.highlightGold, borderRadius: BorderRadius.circular(20)),
                    child: Text('+${quest.xpReward} XP', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.accentGreen, borderRadius: BorderRadius.circular(20)),
                    child: Text('+${quest.statBonus ?? 0} Health', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Awesome!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dataService = Provider.of<DataService>(context);

    if (dataService.isLoading || dataService.currentUserData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userData = dataService.currentUserData!;

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
                boxShadow: [BoxShadow(color: AppColors.highlightGold.withOpacity(0.3), blurRadius: 3, spreadRadius: 2)],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData.username ?? 'Adventurer',
                  style: AppTextStyles.heading.copyWith(fontSize: 20),
                ),
                Text(
                  'Level ${userData.level ?? 1}',
                  style: AppTextStyles.body.copyWith(color: AppColors.primaryPurple),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppColors.highlightGold, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              const Icon(FontAwesomeIcons.coins, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              Text(
                '${userData.coins ?? userData.coins ?? 0}',
                style: AppTextStyles.statValue.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Quests",
                style: AppTextStyles.subheading.copyWith(fontSize: 20, color: AppColors.primaryPurple),
              ),
            ],
          ),
        ),
        // const SizedBox(height: 16),
        //
        // StreamBuilder<List<Quest>>(
        //   stream: _questService.userQuestsStream(includeCompleted: false),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple));
        //     }
        //
        //     if (snapshot.hasError) {
        //       return Center(child: Text("Error loading quests\n${snapshot.error}", textAlign: TextAlign.center));
        //     }
        //
        //     final activeQuests = snapshot.data ?? [];
        //     final todayQuests = activeQuests.where((q) => q.isDaily == true).toList();
        //
        //     final completedCount = activeQuests.where((q) => q.isCompleted).length;
        //     final totalActive = todayQuests.length;
        //
        //     if (todayQuests.isEmpty) {
        //       return Padding(
        //         padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        //         child: Center(
        //           child: Column(
        //             children: [
        //               Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
        //               const SizedBox(height: 16),
        //               Text("No daily quests today", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
        //             ],
        //           ),
        //         ),
        //       );
        //     }
        //
        //     return Column(
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.only(left: 8, bottom: 12),
        //           child: Align(
        //             alignment: Alignment.centerLeft,
        //             child: Text(
        //               "$completedCount completed • $totalActive active today",
        //               style: TextStyle(color: AppColors.textGray, fontWeight: FontWeight.w600),
        //             ),
        //           ),
        //         ),
        //         ListView.builder(
        //           shrinkWrap: true,
        //           physics: const NeverScrollableScrollPhysics(),
        //           itemCount: todayQuests.length,
        //           itemBuilder: (context, index) {
        //             final quest = todayQuests[index];
        //             return QuestCard(
        //               quest: quest,
        //               onTap: () {
        //                 if (!quest.isCompleted) {
        //                   _showQuestDialog(quest);
        //                 }
        //               },
        //             );
        //           },
        //         ),
        //       ],
        //     );
        //   },
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final data = Provider.of<DataService>(context);

    if (!auth.isAuthenticated) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    if (data.isLoading || data.currentUserData == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple)),
              const SizedBox(height: 16),
              Text('Loading your adventure...', style: AppTextStyles.bodyDark),
            ],
          ),
        ),
      );
    }

    final userData = data.currentUserData!;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              XPProgressBar(
                level: data.currentUserData?.level ?? 1,
                currentXP: data.currentUserData?.currentXP ?? 0,
                xpForNextLevel: data.currentUserData?.xpForNextLevel ?? 100,
              ),
              const SizedBox(height: 24),
              _buildQuestsSection(),
              // Optional: Logout button for testing

            ],
          ),
        ),
      ),
    );
  }
}