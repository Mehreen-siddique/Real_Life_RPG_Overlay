
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_life_rpg/Models/users.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Services/AuthenticationServices/AuthServices.dart';
import 'package:real_life_rpg/Services/DataServices/dataServices.dart';
import 'package:real_life_rpg/Services/QuestFirestore/questfirestore.dart';
import 'package:real_life_rpg/utils/constants.dart';
import 'package:real_life_rpg/Screens/profile/AchievementsScreen.dart';
import 'package:real_life_rpg/Screens/Settings/SettingsScreen.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  final String? userId; // Optional - if null, shows current user
  
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _levelUpController;
  late AnimationController _rewardController;
  late Animation<double> _levelUpAnimation;
  late Animation<double> _rewardAnimation;
  
  int _previousLevel = 1;
  int _previousCoins = 0;
  int _previousXP = 0;

  /// Prevent showing "level up" dialogs on initial data hydration / user switch.
  bool _didInitializeProgress = false;
  String? _progressUserId;
  
  // Real quest statistics from Firebase
  int _totalQuests = 0;
  int _completedQuests = 0;
  int _daysActive = 1;
  bool _isLoadingQuestStats = false;
  
  // Track if viewing another user (not current user)
  bool _isViewingOtherUser = false;
  UserModel? _displayUserData; // Separate data for display when viewing others
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _levelUpController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rewardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _levelUpAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _levelUpController,
      curve: Curves.elasticOut,
    ));
    
    _rewardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rewardController,
      curve: Curves.elasticOut,
    ));
    
    // Fetch user data and quest statistics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
      _fetchQuestStatistics();
      
      // 🔄 Listen for real-time updates
      final dataService = Provider.of<DataService>(context, listen: false);
      dataService.addListener(_onDataServiceChanged);
    });
  }
  
  @override
  void dispose() {
    _levelUpController.dispose();
    _rewardController.dispose();
    final dataService = Provider.of<DataService>(context, listen: false);
    dataService.removeListener(_onDataServiceChanged);
    super.dispose();
  }
  
  // Auto-refresh when user data changes (quest completion, level up, etc.)
  void _onDataServiceChanged() {
    if (mounted) {
      // Only current user's progress should trigger level/reward dialogs.
      if (_isViewingOtherUser) {
        _fetchQuestStatistics();
        setState(() {});
        return;
      }

      final dataService = Provider.of<DataService>(context, listen: false);
      final current = dataService.currentUserData;
      if (current == null) {
        setState(() {});
        return;
      }

      // If the logged-in user changed while this screen was alive, reset tracking.
      if (_progressUserId != current.uid) {
        _progressUserId = current.uid;
        _didInitializeProgress = false;
      }

      // Initialize baseline values once to avoid false "level reached" dialogs.
      if (!_didInitializeProgress) {
        _previousLevel = current.level;
        _previousCoins = current.coins;
        _previousXP = current.currentXP;
        _didInitializeProgress = true;
      } else {
        _checkForLevelUpAndRewards(current.level, current.coins, current.currentXP);
      }

      _fetchQuestStatistics();
      setState(() {});
    }
  }

  void _fetchUserData() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dataService = Provider.of<DataService>(context, listen: false);
    
    final targetUserId = widget.userId ?? authService.user?.uid;
    final isCurrentUser = widget.userId == null || widget.userId == authService.user?.uid;
    
    if (targetUserId != null) {
      if (isCurrentUser) {
        // Viewing own profile - use normal method that updates current user data
        _isViewingOtherUser = false;
        _displayUserData = null;
        _didInitializeProgress = false; // reset baseline to prevent false dialogs
        _progressUserId = targetUserId;
        dataService.fetchUserData(targetUserId);
      } else {
        // Viewing another user's profile - use separate method to not affect current user data
        _isViewingOtherUser = true;
        _fetchOtherUserData(targetUserId);
      }
    }
  }
  
  // Fetch other user's data without affecting current user data
  Future<void> _fetchOtherUserData(String userId) async {
    final dataService = Provider.of<DataService>(context, listen: false);
    
    final otherUser = await dataService.fetchOtherUserData(userId);
    if (mounted && otherUser != null) {
      setState(() {
        _displayUserData = otherUser;
      });
    }
  }
  
  void _checkForLevelUpAndRewards(int currentLevel, int currentCoins, int currentXP) {
    if (currentLevel > _previousLevel) {
      _triggerLevelUpAnimation();
      _showLevelUpDialog(currentLevel);
    }
    
    if (currentCoins > _previousCoins) {
      _triggerRewardAnimation();
    }
    
    if (currentXP > _previousXP) {
      _triggerRewardAnimation();
    }
    
    _previousLevel = currentLevel;
    _previousCoins = currentCoins;
    _previousXP = currentXP;
  }
  
  void _triggerLevelUpAnimation() {
    if (mounted) {
      _levelUpController.reset();
      _levelUpController.forward();
    }
  }
  
  void _triggerRewardAnimation() {
    if (mounted) {
      _rewardController.reset();
      _rewardController.forward();
    }
  }
  
  void _refreshProfileData() {
    _fetchUserData();
    _fetchQuestStatistics();
  }
  
  // Fetch real quest statistics from Firebase
  Future<void> _fetchQuestStatistics() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingQuestStats = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final dataService = Provider.of<DataService>(context, listen: false);
      
      // Determine which user to fetch stats for: widget.userId for other users, current user for own profile
      final targetUserId = widget.userId ?? authService.user?.uid;
      final isCurrentUser = widget.userId == null || widget.userId == authService.user?.uid;
      
      if (targetUserId == null) {
        return;
      }
      
      final questService = QuestServiceFirestore();
      
      // For other users, we need to fetch their quests directly
      if (!isCurrentUser) {
        // Fetch other user's quests from their subcollection
        final QuerySnapshot questSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(targetUserId)
            .collection('quests')
            .get();
        
        final allQuests = questSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Quest(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            type: QuestType.values.firstWhere(
              (e) => e.toString() == data['type'],
              orElse: () => QuestType.exercise,
            ),
            difficulty: QuestDifficulty.medium,
            xpReward: data['xpReward']?.toInt() ?? 10,
            goldReward: data['goldReward']?.toInt() ?? 5,
            statBonus: data['statBonus']?.toInt() ?? 0,
            isCompleted: data['isCompleted'] ?? false,
            icon: Icons.directions_walk,
            gradientColors: [AppColors.primaryPurple, AppColors.accentBlue],
          );
        }).toList();
        
        final totalQuests = allQuests.length;
        final completedQuests = allQuests.where((quest) => quest.isCompleted).length;
        
        // Calculate days active from other user's createdAt
        final otherUserData = _displayUserData;
        final createdAt = otherUserData?.createdAt;
        final daysActive = createdAt != null 
            ? DateTime.now().difference(createdAt).inDays + 1 
            : 1;
        
        if (mounted) {
          setState(() {
            _totalQuests = totalQuests;
            _completedQuests = completedQuests;
            _daysActive = daysActive;
            _isLoadingQuestStats = false;
          });
        }
        return;
      }
      
      // Fetch all quests for the current user (both active and completed)
      final allQuestsStream = questService.userQuestsStream(includeCompleted: true);
      final allQuests = await allQuestsStream.first;
      
      // Calculate real statistics
      final totalQuests = allQuests.length;
      final completedQuests = allQuests.where((quest) => quest.isCompleted).length;
      
      // Calculate days active from user creation date
      final userData = dataService.currentUserData;
      final createdAt = userData?.createdAt;
      final daysActive = createdAt != null 
          ? DateTime.now().difference(createdAt).inDays + 1 
          : 1;
      
      if (mounted) {
        setState(() {
          _totalQuests = totalQuests;
          _completedQuests = completedQuests;
          _daysActive = daysActive;
          _isLoadingQuestStats = false;
        });
      }
    } catch (e) {
      debugPrint('ProfileScreen: Error fetching quest statistics: $e');
      if (mounted) {
        setState(() {
          _isLoadingQuestStats = false;
        });
      }
    }
  }
  
  void _showLevelUpDialog(int newLevel) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _LevelUpDialog(
          newLevel: newLevel,
          onAnimationComplete: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Consumer<DataService>(
          builder: (context, dataService, child) {
            final bg = Theme.of(context).scaffoldBackgroundColor;
            // Get real user data or show loading
            if (dataService.isLoading) {
              return Scaffold(
                backgroundColor: bg,
                body: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryPurple),
                ),
              );
            }

            if (dataService.error != null) {
              return Scaffold(
                backgroundColor: bg,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading profile',
                        style: AppTextStyles.subheading,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dataService.error!,
                        style: AppTextStyles.body.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Use real data or fallback to dummy data if not available
            // When viewing other user, use _displayUserData; otherwise use current user data
            final UserModel? displayData = _isViewingOtherUser ? _displayUserData : dataService.currentUserData;
            final String userName = displayData?.username ?? 'Player';
            final String userClass = displayData?.username ?? 'Explorer';
            final int userLevel = displayData?.level ?? 1;
            final int currentXP = displayData?.currentXP ?? 0;
            final int requiredXP = displayData?.xpForNextLevel ?? 100;
            final int currentCoins = displayData?.coins ?? 0;
            
            // Level-up and reward dialogs are triggered in _onDataServiceChanged.
            
            // Quest statistics - fetch REAL data from Firebase
            final int totalQuests = _totalQuests;
            final int completedQuests = _completedQuests;
            final int successRate = totalQuests > 0 ? ((completedQuests / totalQuests) * 100).toInt() : 0;
            final int daysActive = _daysActive;

            // Unlocked achievements count - estimate from level
            final List<bool> achievementChecks = [
              completedQuests >= 1,
              completedQuests >= 50,
              (displayData?.streak ?? 0) >= 7,
              (displayData?.streak ?? 0) >= 30,
              userLevel >= 10,
              currentCoins >= 1000,
              totalQuests >= 25,
            ];
            final int unlockedAchievements = achievementChecks.where((value) => value).length;
            final int totalAchievements = achievementChecks.length;

            final double xpProgress = requiredXP > 0 ? currentXP / requiredXP : 0.0;

            return Scaffold(
              backgroundColor: bg,
              body: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: AppSizes.paddingMD),
                        _buildProfileHeader(userName, userClass, userLevel, currentXP, requiredXP, xpProgress),
                        SizedBox(height: AppSizes.paddingLG),
                        _buildAchievementsSection(
                          unlockedAchievements,
                          totalAchievements,
                          userLevel,
                          completedQuests,
                          totalQuests,
                          displayData?.streak ?? 0,
                          currentCoins,
                        ),
                        SizedBox(height: AppSizes.paddingLG),
                        _buildProgressDashboard(
                          totalQuests: totalQuests,
                          completedQuests: completedQuests,
                          successRate: successRate,
                          daysActive: daysActive,
                          coins: currentCoins,
                        ),
                        SizedBox(height: 120), // Extra bottom spacing for better UX
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.secondaryPurple,
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: Text(
            'Profile',
            style: AppTextStyles.headingWhite.copyWith(fontSize: 20),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: AppColors.textWhite),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(String userName, String userClass, int userLevel, int currentXP, int requiredXP, double xpProgress) {
    return AnimatedBuilder(
      animation: Listenable.merge([_levelUpAnimation, _rewardAnimation]),
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
          child: Container(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: AppColors.primaryPurple.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Avatar with level-up animation
                Transform.scale(
                  scale: 1.0 + (_levelUpAnimation.value * 0.2),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.primaryPurple,
                      border: Border.all(
                        color: AppColors.borderGold,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.3 + _levelUpAnimation.value * 0.4),
                          blurRadius: 15 + _levelUpAnimation.value * 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'P',
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                        // Level-up badge
                        if (_levelUpAnimation.value > 0.5)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Transform.scale(
                              scale: _levelUpAnimation.value,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.whiteBackground, width: 3),
                                ),
                                child: Icon(
                                  Icons.star,
                                  color: AppColors.whiteBackground,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.padding),

                // Name & Class
                Text(
                  userName,
                  style: AppTextStyles.heading,
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSM + 4,
                    vertical: AppSizes.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryPurple,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                  child: Text(
                    userClass,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.padding),

                // Level & XP with animation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      transform: Matrix4.rotationZ(_levelUpAnimation.value * 0.1),
                      child: Icon(Icons.stars, color: AppColors.highlightGold, size: 24),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Level $userLevel',
                      style: AppTextStyles.subheading.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.paddingSM),

                // XP Progress Bar
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      child: LinearProgressIndicator(
                        value: xpProgress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.statsBackground,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                        minHeight: 10,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$currentXP / $requiredXP XP',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.padding),

              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAchievementsSection(
    int unlockedAchievements,
    int totalAchievements,
    int userLevel,
    int completedQuests,
    int totalQuests,
    int streak,
    int coins,
  ) {
    final bool sevenDayUnlocked = streak >= 7;
    final bool questMasterUnlocked = completedQuests >= 50;
    final bool level10Unlocked = userLevel >= 10;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: AppTextStyles.subheading,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AchievementsScreen(
                        userLevel: userLevel,
                        completedQuests: completedQuests,
                        totalQuests: totalQuests,
                        streak: streak,
                        coins: coins,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.primaryPurple,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingSM),
          Container(
            padding: EdgeInsets.all(AppSizes.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.whiteBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                // Achievement Progress Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: AppColors.highlightGold, size: 28),
                    SizedBox(width: 8),
                    Text(
                      '$unlockedAchievements / $totalAchievements',
                      style: AppTextStyles.statValueLarge.copyWith(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  child: LinearProgressIndicator(
                    value: totalAchievements > 0 ? unlockedAchievements / totalAchievements : 0.0,
                    backgroundColor: AppColors.statsBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.highlightGold),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${totalAchievements > 0 ? ((unlockedAchievements / totalAchievements) * 100).toInt() : 0}% Complete',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSizes.padding),
                Divider(),
                SizedBox(height: AppSizes.paddingSM),

                // Recent Achievements
                Text(
                  'Recent Unlocked',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: AppSizes.paddingSM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAchievementBadge(
                      title: '7 Day Streak',
                      icon: Icons.local_fire_department,
                      gradient: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      isUnlocked: sevenDayUnlocked,
                      progressText: '${streak}/7',
                    ),
                    _buildAchievementBadge(
                      title: 'Quest Master',
                      icon: Icons.emoji_events,
                      gradient: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      isUnlocked: questMasterUnlocked,
                      progressText: '${completedQuests}/50',
                    ),
                    _buildAchievementBadge(
                      title: 'Level 10',
                      icon: Icons.stars,
                      gradient: AppColors.gradientPrimaryPurple,
                      isUnlocked: level10Unlocked,
                      progressText: '$userLevel/10',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge({
    required String title,
    required IconData icon,
    required List<Color> gradient,
    required bool isUnlocked,
    required String progressText,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: isUnlocked ? LinearGradient(colors: gradient) : null,
            color: isUnlocked ? null : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? AppColors.borderGold : Colors.grey.shade400,
              width: 2,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isUnlocked ? icon : Icons.lock_outline,
            color: isUnlocked ? AppColors.textWhite : Colors.grey.shade700,
            size: 28,
          ),
        ),
        SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          progressText,
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: isUnlocked ? AppColors.primaryPurple : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressDashboard({
    required int totalQuests,
    required int completedQuests,
    required int successRate,
    required int daysActive,
    required int coins,
  }) {
    final activeQuests = (totalQuests - completedQuests).clamp(0, totalQuests);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Dashboard',
                style: AppTextStyles.subheading.copyWith(fontSize: 18),
              ),
              if (_isLoadingQuestStats)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryPurple,
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _dashboardCard('Total Quests', '$totalQuests', Icons.list_alt, AppColors.primaryPurple),
              _dashboardCard('Completed', '$completedQuests', Icons.check_circle, Colors.green),
              _dashboardCard('Active', '$activeQuests', Icons.bolt, Colors.blue),
              _dashboardCard('Success Rate', '$successRate%', Icons.insights, Colors.orange),
              _dashboardCard('Days Active', '$daysActive', Icons.calendar_today, Colors.teal),
              _dashboardCard('Coins', '$coins', Icons.monetization_on, AppColors.highlightGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.subheading.copyWith(color: color, fontWeight: FontWeight.bold)),
                Text(label, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// Level Up Celebration Dialog
class _LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final VoidCallback onAnimationComplete;

  const _LevelUpDialog({
    required this.newLevel,
    required this.onAnimationComplete,
  });

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _controller.forward();
    
    // Auto-close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple,
                    AppColors.accentBlue,
                    AppColors.highlightGold,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sparkle effects
                  if (_sparkleAnimation.value > 0)
                    ...List.generate(6, (index) {
                      final angle = (index * 60) * (pi / 180);
                      final distance = 80.0 * _sparkleAnimation.value;
                      return Positioned(
                        top: 50 + sin(angle) * distance,
                        left: 150 + cos(angle) * distance,
                        child: Transform.scale(
                          scale: _sparkleAnimation.value,
                          child: Icon(
                            Icons.star,
                            color: AppColors.whiteBackground,
                            size: 20,
                          ),
                        ),
                      );
                    }),

                  // Main content
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Level up icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.whiteBackground,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.whiteBackground.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: AppColors.primaryPurple,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'LEVEL UP!',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.whiteBackground,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Level info
                        Text(
                          'You reached Level ${widget.newLevel}!',
                          style: AppTextStyles.subheading.copyWith(
                            color: AppColors.whiteBackground,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          'Keep up the amazing work!',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.whiteBackground.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Progress indicator
                        Container(
                          width: 200,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.whiteBackground.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _controller.value,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.whiteBackground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
