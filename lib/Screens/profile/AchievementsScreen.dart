import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../../Services/Achievements/achievement_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int targetValue;
  final int currentValue;
  final String category;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.currentValue,
    required this.category,
    required this.isUnlocked,
  });

  double get progress => currentValue / targetValue;
}

class AchievementsScreen extends StatefulWidget {
  final int userLevel;
  final int completedQuests;
  final int totalQuests;
  final int streak;
  final int coins;

  const AchievementsScreen({
    Key? key,
    required this.userLevel,
    required this.completedQuests,
    required this.totalQuests,
    required this.streak,
    required this.coins,
  }) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Quests',
    'Social',
    'Streaks',
    'Levels',
    'Steps',
    'Challenges',
  ];

  /// Used only as a fallback for the old UI flow.
  /// The real data for this screen is loaded from Firestore via [AchievementService].
  List<Achievement> _achievements = const [];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Ensure achievement docs exist (idempotent).
      AchievementService().initializeAchievementsForUser(uid);
    }
  }

  IconData _iconForAchievementId(String id) {
    switch (id) {
      case AchievementService.firstQuestId:
        return Icons.check_circle;
      case AchievementService.questMaster50Id:
        return Icons.emoji_events;
      case AchievementService.streak7Id:
        return Icons.local_fire_department;
      case AchievementService.streak30Id:
        return Icons.military_tech;
      case AchievementService.level10Id:
      case AchievementService.level20Id:
      case AchievementService.level30Id:
        return Icons.stars;
      case AchievementService.steps10kId:
        return Icons.directions_walk;
      case AchievementService.partyJoinFirstId:
        return Icons.people_alt_outlined;
      case AchievementService.firstChallengeWinId:
        return Icons.emoji_events_outlined;
      default:
        return Icons.lock;
    }
  }

  List<Achievement> get _filteredAchievements {
    if (_selectedCategory == 'All') {
      return _achievements;
    }
    return _achievements.where((a) => a.category == _selectedCategory).toList();
  }


  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return GestureDetector(
      onTap: () => _showAchievementDetail(achievement),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(20),
          border: achievement.isUnlocked
              ? Border.all(color: AppColors.highlightGold.withOpacity(0.5), width: 2)
              : null,
          boxShadow: achievement.isUnlocked
              ? [
            BoxShadow(
              color: AppColors.highlightGold.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              : AppShadows.cardShadow,
        ),
        child: Stack(
          children: [
            // Locked Overlay
            if (!achievement.isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with gradient background
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: achievement.isUnlocked
                          ? AppGradients.primaryPurple
                          : LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade500],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: achievement.isUnlocked
                          ? AppShadows.cardShadowLarge
                          : [],
                    ),
                    child: Icon(
                      achievement.isUnlocked ? achievement.icon : Icons.lock,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: achievement.isUnlocked
                          ? AppColors.textDark
                          : AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    achievement.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar (for locked achievements)
                  if (!achievement.isUnlocked) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: achievement.progress,
                        backgroundColor: AppColors.progressTrack,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPurple),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${achievement.currentValue}/${achievement.targetValue}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Unlocked Badge
                  if (achievement.isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.highlightGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'UNLOCKED',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.highlightGold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: achievement.isUnlocked
                      ? AppGradients.primaryPurple
                      : LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade500],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: achievement.isUnlocked ? AppShadows.cardShadowLarge: [],
                ),
                child: Icon(
                  achievement.isUnlocked ? achievement.icon : Icons.lock,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 20),

              // Progress
              if (!achievement.isUnlocked) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: AppColors.lightBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightPurple),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${achievement.currentValue} / ${achievement.targetValue}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${((achievement.progress) * 100).toInt()}% Complete',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.highlightGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.highlightGold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'UNLOCKED',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.highlightGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: AppColors.lightPurple,
                    elevation: 0,
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Achievements',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('Please login to view achievements.')),
      );
    }

    return StreamBuilder<List<UserAchievement>>(
      stream: AchievementService().getAchievementsStream(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Achievements',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final backendAchievements = snapshot.data ?? <UserAchievement>[];
        final achievements = backendAchievements
            .map(
              (a) => Achievement(
                id: a.id,
                title: a.title,
                description: a.description,
                icon: _iconForAchievementId(a.id),
                targetValue: a.targetValue,
                currentValue: a.currentValue,
                category: a.category,
                isUnlocked: a.isUnlocked,
              ),
            )
            .toList();

        final unlockedCount = achievements.where((a) => a.isUnlocked).length;
        final totalCount = achievements.length;

        final filteredAchievements = _selectedCategory == 'All'
            ? achievements
            : achievements.where((a) => a.category == _selectedCategory).toList();

        final progressPct = totalCount <= 0 ? 0 : ((unlockedCount / totalCount) * 100).toInt();

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Achievements',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Stats Header
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryPurple,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.cardShadowLarge,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.emoji_events,
                      value: '$unlockedCount',
                      label: 'Unlocked',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white30,
                    ),
                    _buildStatItem(
                      icon: Icons.lock_open,
                      value: '$progressPct%',
                      label: 'Progress',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white30,
                    ),
                    _buildStatItem(
                      icon: Icons.stars,
                      value: '$totalCount',
                      label: 'Total',
                    ),
                  ],
                ),
              ),

              // Category Filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = category);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppGradients.primaryPurple : null,
                          color: isSelected ? null : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow:
                              isSelected ? AppShadows.cardShadowLarge : [],
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Achievements Grid
              Expanded(
                child: achievements.isEmpty
                    ? Center(
                        child: Text(
                          'No achievements yet.',
                          style: GoogleFonts.poppins(
                            color: AppColors.textGray,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement = filteredAchievements[index];
                          return _buildAchievementCard(achievement);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }


}
