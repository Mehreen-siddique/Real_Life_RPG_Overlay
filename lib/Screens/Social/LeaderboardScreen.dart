
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUserName = 'Hero Knight';
  late List<LeaderboardUser> _availableFamilyCandidates;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _availableFamilyCandidates = _globalUsers
        .where((user) => !_familyUsers.any((f) => f.name == user.name))
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<LeaderboardUser> _globalUsers = [
    LeaderboardUser(name: 'Iron First', xp: 2850, rank: 1, avatar: Icons.sports_kabaddi),
    LeaderboardUser(name: 'Hero Knight', xp: 2650, rank: 2, avatar: Icons.person),
    LeaderboardUser(name: 'Wise Sage', xp: 2600, rank: 3, avatar: Icons.face),
    LeaderboardUser(name: 'Swift Runner', xp: 2450, rank: 4, avatar: Icons.directions_run),
    LeaderboardUser(name: 'Study Master', xp: 2300, rank: 5, avatar: Icons.school),
  ];

  final List<LeaderboardUser> _familyUsers = [
    LeaderboardUser(name: 'Hero Knight', xp: 2650, rank: 1, avatar: Icons.person),
    LeaderboardUser(name: 'Iron First', xp: 2850, rank: 2, avatar: Icons.sports_kabaddi),
    LeaderboardUser(name: 'Wise Sage', xp: 2600, rank: 3, avatar: Icons.face),
  ];



  void _addFamilyMemberFromPool() {
    if (_availableFamilyCandidates.isEmpty) return;

    final newMember = _availableFamilyCandidates.removeAt(0);

    setState(() {
      _familyUsers.add(
        LeaderboardUser(
          name: newMember.name,
          xp: newMember.xp,
          rank: _familyUsers.length + 1,
          avatar: newMember.avatar,
        ),
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Tab Bar
          _buildTabBar(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFamilyTab(),
                _buildGlobalTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryPurple,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.highlightGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.emoji_events, color: Colors.black, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '#1 Family',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compete and climb to the top!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightBackgroundBox,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 0.01,
        indicatorColor: Colors.transparent,


        indicator: BoxDecoration(
          gradient: AppGradients.primaryPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.primaryPurple,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 18),
                SizedBox(width: 6),
                Text('Family'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.public, size: 18),
                SizedBox(width: 6),
                Text('Global'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total Family XP Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            color: AppColors.lightBackgroundBox,
              borderRadius: BorderRadius.circular(AppSizes.radius),
              boxShadow: AppShadows.cardShadow,
              border: Border.all(
                  color: AppColors.strokeColor, width: 1.5
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 10,),

                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events,
                    color: AppColors.primaryPurple,
                    size: 32,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Total Family XP',
                          style: AppTextStyles.bodyDark,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '11,850',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '🏆 Family Season (Weekly)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Ends in 2 days',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
            ),
          ),
           SizedBox(height: 15),

          // Podium (Top 3)
          _buildPodium(_familyUsers.take(3).toList()),
          SizedBox(height: 24),

          // Rest of rankings
          Text(
            'Other Family Members',
            style: AppTextStyles.subheading,
          ),

          SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: _addFamilyMemberFromPool,
            icon: const Icon(Icons.person_add),
            label: const Text('Invite Family Member'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),

           SizedBox(height: 12),
          ..._familyUsers.skip(3).map((user) => _buildRankingCard(user)),

          SizedBox(height: 100,)
        ],
      ),
    );
  }

  // Widget _buildGlobalTab() {
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: _globalUsers.length,
  //     itemBuilder: (context, index) {
  //       return _buildRankingCard(_globalUsers[index]);
  //     },
  //   );
  // }

  Widget _buildGlobalTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Challenge banner (scrolls with list)
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.lightBackgroundBox,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryPurple),
          ),
          child: Row(
            children: [
              const Icon(Icons.public, color: AppColors.primaryPurple),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Global Challenge',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ends in 5 hours',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You joined the challenge')),
                  );
                },
                child: const Text('JOIN'),
              ),
            ],
          ),
        ),

        // Leaderboard items
        ..._globalUsers.map((user) => _buildRankingCard(user)),
      ],
    );
  }



  Widget _buildPodium(List<LeaderboardUser> topThree) {
    if (topThree.length < 3) return const SizedBox();

    // Reorder for podium: 2nd, 1st, 3rd
    final first = topThree[0];
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return SizedBox(
      height: 350,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (second != null)
            Expanded(
              child: _buildPodiumItem(
                user: second,
                height: 150,
                color: AppColors.leaderboardSilver,
                rank: 2,
              ),
            ),
          const SizedBox(width: 12),

          // 1st Place (Tallest)
          Expanded(
            child: _buildPodiumItem(
              user: first,
              height: 180,
              color: AppColors.highlightGold,
              rank: 1,
              isWinner: true,
            ),
          ),
          const SizedBox(width: 12),

          // 3rd Place
          if (third != null)
            Expanded(
              child: _buildPodiumItem(
                user: third,
                height: 120,
                color: AppColors.leaderboardBronze,
                rank: 3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required LeaderboardUser user,
    required double height,
    required Color color,
    required int rank,
    bool isWinner = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar with crown (if winner)
        if (isWinner)
          Icon(
            Icons.auto_awesome,
            color: AppColors.highlightGold,
            size: 32,
          ),
        const SizedBox(height: 4),

        // Avatar
        Container(
          width: isWinner ? 70 : 60,
          height: isWinner ? 70 : 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:AppColors.gradientPrimary,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(user.avatar, color: AppColors.whiteBackground, size: isWinner ? 35 : 30),
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          user.name,
          style: TextStyle(
            fontSize: isWinner ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // XP
        Text(
          '${user.xp} XP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),

        // Podium
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.7), color],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: isWinner ? 48 : 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(LeaderboardUser user) {
    final isCurrentUser = user.name == currentUserName;


    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.lightPurple
            : AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: isCurrentUser
            ? Border.all(color: AppColors.primaryPurple, width: 2)
            : null,
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRankColor(user.rank).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${user.rank}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(user.rank),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple.withOpacity(0.3),
                  AppColors.primaryPurple.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryPurple, width: 2),
            ),
            child: Icon(
              user.avatar,
              color: AppColors.primaryPurple,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Name & XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.bodyDark.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 14,
                      color: AppColors.highlightGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.xp} XP',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.highlightGold,
                      ),
                    ),




                  ],
                ),
                LinearProgressIndicator(
                  value: (user.xp % 1000) / 1000,
                  backgroundColor: Colors.grey.shade300,
                  color: AppColors.primaryPurple,
                  minHeight: 6,
                ),
              ],
            ),
          ),

          // Badge (if current user)
          if (isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'YOU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return AppColors.highlightGold;
    if (rank == 2) return AppColors.leaderboardSilver;
    if (rank == 3) return AppColors.leaderboardBronze;
    return AppColors.primaryPurple;
  }
}

class LeaderboardUser {
  final String name;
  final int xp;
  final int rank;
  final IconData avatar;

  LeaderboardUser({
    required this.name,
    required this.xp,
    required this.rank,
    required this.avatar,
  });
}
