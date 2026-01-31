import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Services/Leaderboard/leaderboard_service.dart';
import 'package:real_life_rpg/Services/QRCode/qr_code_service.dart';
import 'package:real_life_rpg/Services/AuthenticationServices/AuthServices.dart';
import 'package:real_life_rpg/utils/constants.dart';

/// 👤 User Profile Screen
/// Shows detailed user profile with stats and achievements
class UserProfileScreen extends StatefulWidget {
  final String userId;
  
  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _profileController;
  late Animation<double> _profileAnimation;
  
  final LeaderboardService _leaderboardService = LeaderboardService.instance;
  
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isCurrentUser = false;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserProfile();
  }
  
  void _initializeAnimations() {
    _profileController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _profileAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileController,
      curve: Curves.easeOutBack,
    ));
  }
  
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      // Check if this is current user
      final authService = Provider.of<AuthService>(context, listen: false);
      _isCurrentUser = authService.user?.uid == widget.userId;
      
      // Get user profile from leaderboard service
      final entry = await _leaderboardService.getUserPosition(widget.userId);
      
      if (entry != null) {
        _userProfile = UserProfile(
          userId: entry.userId,
          username: entry.username,
          email: entry.email,
          level: entry.level,
          currentXP: entry.currentXP,
          totalQuestsCompleted: entry.totalQuestsCompleted,
          coins: entry.coins,
          streak: entry.streak,
          rank: entry.rank,
          lastActive: entry.lastActive,
        );
        
        // Start animation
        _profileController.forward();
      }
    } catch (e) {
      debugPrint('🚨 [USER-PROFILE] Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingWidget() : _buildBody(),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _userProfile?.username ?? 'User Profile',
        style: AppTextStyles.screenHeading.copyWith(
          color: AppColors.whiteBackground,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.primaryPurple,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.whiteBackground),
      actions: [
        if (_isCurrentUser)
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.whiteBackground),
            onPressed: _shareProfile,
          ),
      ],
    );
  }
  
  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryPurple,
      ),
    );
  }
  
  Widget _buildBody() {
    if (_userProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: AppColors.textGray,
            ),
            const SizedBox(height: 16),
            Text(
              'User not found',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(),
          const SizedBox(height: 24),
          
          // Stats Grid
          _buildStatsGrid(),
          const SizedBox(height: 24),
          
          // Progress Section
          _buildProgressSection(),
          const SizedBox(height: 24),
          
          // Achievements Section
          _buildAchievementsSection(),
          const SizedBox(height: 24),
          
          // Activity Section
          _buildActivitySection(),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return AnimatedBuilder(
      animation: _profileAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _profileAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryPurple,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.cardShadow,
            ),
            child: Column(
              children: [
                // Rank Badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.whiteBackground,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _userProfile!.rankBadge,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.whiteBackground,
                        fontSize: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Username
                Text(
                  _userProfile!.username,
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.whiteBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Level and Rank
                Text(
                  'Level ${_userProfile!.level} • Rank #${_userProfile!.rank}',
                  style: AppTextStyles.subheading.copyWith(
                    color: AppColors.whiteBackground.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Last Active
                Text(
                  'Active ${_userProfile!.lastActiveText}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.whiteBackground.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistics',
            style: AppTextStyles.subheading.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'XP',
                '${_userProfile!.currentXP}',
                Icons.star,
                Colors.amber,
              ),
              _buildStatCard(
                'Coins',
                '${_userProfile!.coins}',
                Icons.monetization_on,
                Colors.orange,
              ),
              _buildStatCard(
                'Quests',
                '${_userProfile!.totalQuestsCompleted}',
                Icons.emoji_events,
                Colors.purple,
              ),
              _buildStatCard(
                'Streak',
                '${_userProfile!.streak}',
                Icons.local_fire_department,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Level Progress',
            style: AppTextStyles.subheading.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Level Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level ${_userProfile!.level}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Level ${_userProfile!.level + 1}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _userProfile!.progressPercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                '${_userProfile!.currentXP} / ${_userProfile!.level * 100} XP',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: AppTextStyles.subheading.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Achievement badges (placeholder for now)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAchievementBadge('🏆', 'Champion', 'Reach top 10'),
              _buildAchievementBadge('⭐', 'Rising Star', 'Complete 50 quests'),
              _buildAchievementBadge('🔥', 'On Fire', '7-day streak'),
              _buildAchievementBadge('💎', 'Dedicated', 'Reach level 10'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementBadge(String emoji, String title, String description) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          description,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textGray,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildActivitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: AppTextStyles.subheading.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Activity list (placeholder)
          _buildActivityItem('Completed "Morning Walk"', '2 hours ago', Icons.check_circle, Colors.green),
          _buildActivityItem('Level up to ${_userProfile!.level}', '1 day ago', Icons.trending_up, Colors.purple),
          _buildActivityItem('Started 7-day streak', '3 days ago', Icons.local_fire_department, Colors.orange),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _shareProfile() {
    // Share profile functionality
    final qrService = QRCodeService.instance;
    qrService.shareQRCode(context);
  }
  
  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }
}
