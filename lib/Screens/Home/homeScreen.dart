import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Services/DataServices/dataServices.dart';
import 'package:real_life_rpg/utils/constants.dart';
import 'package:real_life_rpg/Screens/Quests/CreateQuest.dart';
import 'package:real_life_rpg/Screens/Leaderboard/LeaderboardScreen.dart';
import 'package:real_life_rpg/Services/AuthenticationServices/AuthServices.dart';
import 'package:real_life_rpg/Services/QuestFirestore/questfirestore.dart';
import 'package:real_life_rpg/Widgets/quest_card.dart';
import 'package:real_life_rpg/Widgets/xp_progress.dart';
import 'package:real_life_rpg/ArView/AR_Screen.dart';
import 'package:real_life_rpg/Widgets/reward_notification_overlay.dart';
import 'package:real_life_rpg/Services/Health/health_connect_service.dart';
import 'package:real_life_rpg/Services/QuestEngine/quest_engine.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:real_life_rpg/Models/daily_health_data.dart';
import 'package:real_life_rpg/Widgets/simple_bar_chart.dart';
import 'package:real_life_rpg/Screens/WeeklyReport/weekly_report_screen.dart';
import 'package:real_life_rpg/Screens/Quests/SmartSuggestionsScreen.dart';
import 'package:real_life_rpg/Services/CharacterSelection/character_selection_service.dart';
import 'package:real_life_rpg/Services/Streaks/streaks_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuestServiceFirestore _questService = QuestServiceFirestore();
  final HealthConnectService _healthService = HealthConnectService();
  final QuestEngine _questEngine = QuestEngine();

  late Stream<List<Quest>> _questStream;
  Timer? _evaluationTimer;

  // Quest stream caching
  bool _hasLoadedQuests = false;
  List<Quest> _cachedQuests = [];

  // Health Connect state
  int _todaySteps = 0;
  double? _heartRate;
  bool _isLoadingHealth = false;
  Map<String, int> _weeklySteps = {};
  Map<String, double> _weeklyHeartRate = {};
  List<DailyHealthData> _weekData = [];

  // Local notifications
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _notificationsInitialized = false;

  Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
    _notificationsInitialized = true;
  }

  Future<void> _showCompletionNotification(String questTitle) async {
    await _initNotifications();
    const androidDetails = AndroidNotificationDetails(
      'quest_completion', 'Quest Completion',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(
      0, '🎉 Quest Completed!', questTitle, details,
    );
  }

  void _showQuestCompletionDialog(QuestEvalResult result) {
    if (!mounted) return;
    final quest = result.quest;
    final charService = CharacterSelectionService.instance;
    final character = charService.selectedCharacter;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Character icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: character.gradient,
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(character.Icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text('🎉 Quest Completed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple)),
            const SizedBox(height: 8),
            Text(quest.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            // Rewards with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: quest.xpReward.toDouble()),
              duration: const Duration(milliseconds: 800),
              builder: (_, val, __) => _rewardRow(Icons.star, '${val.toInt()} XP', AppColors.primaryPurple),
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: quest.goldReward.toDouble()),
              duration: const Duration(milliseconds: 800),
              builder: (_, val, __) => _rewardRow(Icons.monetization_on, '${val.toInt()} Coins', Colors.amber),
            ),
            const SizedBox(height: 16),
            // AR button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ARCharacterScreen()));
                },
                icon: const Icon(Icons.view_in_ar),
                label: Text('${character.name} in AR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardRow(IconData icon, String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthService>(context, listen: false);
    if (auth.isAuthenticated && auth.user != null) {
      final dataService = Provider.of<DataService>(context, listen: false);
      if (dataService.currentUserData == null) {
        dataService.fetchUserData(auth.user!.uid);
      }
      dataService.startListeningToUser(auth.user!.uid);
    }

    _questStream = _questService.userQuestsStream(includeCompleted: false);
    _startEvaluationTimer();
    _fetchHealthData(); // Auto-fetch on init
  }

  /// Periodically evaluate quests against health data every 5 seconds
  void _startEvaluationTimer() {
    _evaluationTimer?.cancel();
    _evaluationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_cachedQuests.isEmpty) return;
      try {
        debugPrint('[HomeScreen] Timer: evaluating ${_cachedQuests.length} quests...');
        final results = await _questEngine.evaluateQuests(_cachedQuests);
        if (results.isNotEmpty && mounted) {
          // Check for newly completed quests
          for (final r in results) {
            if (r.justCompleted) {
              _showCompletionNotification(r.quest.title);
              _showQuestCompletionDialog(r);
              // Update streak on quest completion
              final auth = Provider.of<AuthService>(context, listen: false);
              if (auth.user != null) {
                StreaksService().updateStreakOnQuestCompletion(auth.user!.uid);
              }
            }
          }
          setState(() {});
          debugPrint('[HomeScreen] Timer: ${results.length} quests evaluated, UI updated');
        }
      } catch (e) {
        debugPrint('[HomeScreen] Timer: evaluation error: $e');
      }
    });
  }

  @override
  void dispose() {
    _evaluationTimer?.cancel();
    super.dispose();
  }


  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final auth = Provider.of<AuthService>(context);
    final data = Provider.of<DataService>(context);

    if (!auth.isAuthenticated) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    if (data.isLoading || data.currentUserData == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryPurple)),
              const SizedBox(height: 16),
              Text(
                data.isLoading
                    ? 'Loading your adventure...'
                    : 'Setting up your adventure...',
                style: AppTextStyles.bodyDark,
              ),
            ],
          ),
        ),
      );
    }

    final userData = data.currentUserData!;

    return RewardNotificationOverlay(
      child: Scaffold(
        backgroundColor: bg,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(userData),
                const SizedBox(height: 20),
                XPProgressBar(
                  level: userData.level ?? 1,
                  currentXP: userData.currentXP ?? 0,
                  xpForNextLevel: userData.xpForNextLevel ?? 100,
                ),
                const SizedBox(height: 24),
                _buildHealthConnectSection(),
                const SizedBox(height: 24),
                _buildQuestsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(dynamic userData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryPurple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTextStyles.body.copyWith(
                        color:
                            AppColors.whiteBackground.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData.username ?? 'Adventurer',
                    style: AppTextStyles.screenHeading.copyWith(
                      color: AppColors.whiteBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _headerIconButton(Icons.view_in_ar, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ARCharacterScreen()));
                  }),
                  const SizedBox(width: 10),
                  _headerIconButton(Icons.leaderboard, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen()));
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(
                      'Level', '${userData.level ?? 1}', Icons.auto_graph)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildStatItem(
                      'Coins', '${userData.coins ?? 0}', Icons.monetization_on)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildStatItem('Quests',
                      '${userData.totalQuestsCompleted ?? 0}', Icons.emoji_events)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildStatItem('Streak',
                      '${userData.streak ?? 0}', Icons.local_fire_department)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.whiteBackground.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.whiteBackground.withOpacity(0.5)),
        ),
        child: Icon(icon, color: AppColors.whiteBackground, size: 22),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(label,
            style: AppTextStyles.body.copyWith(
                color: AppColors.whiteBackground.withOpacity(0.8),
                fontSize: 12)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.whiteBackground, size: 18),
            const SizedBox(width: 4),
            Text(value,
                style: AppTextStyles.screenHeading.copyWith(
                    color: AppColors.whiteBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      ],
    );
  }


  // ─── Quests Section ───────────────────────────────────────────────────────

  Widget _buildQuestsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textWhite : AppColors.textDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Active Quests',
                style: AppTextStyles.subheading
                    .copyWith(color: textPrimary, fontSize: 18)),
            // Smart Suggestions button only (Create moved to AI Suggestions screen)
            TextButton.icon(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SmartSuggestionsScreen())),
              icon: const Icon(Icons.lightbulb_outline,
                  color: AppColors.accentBlue, size: 18),
              label: const Text('AI Suggestions',
                  style: TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Quest>>(
          stream: _questStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !_hasLoadedQuests) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                      color: AppColors.primaryPurple),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading quests: ${snapshot.error}',
                    style:
                        AppTextStyles.caption.copyWith(color: Colors.red)),
              );
            }

            final quests = snapshot.data ?? _cachedQuests;
            final activeQuests =
                quests.where((q) => !q.isDeleted && !q.isCompleted).toList();

            if (snapshot.hasData) {
              _hasLoadedQuests = true;
              _cachedQuests = activeQuests;
            }

            if (activeQuests.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.emoji_events_outlined,
                        size: 64,
                        color: AppColors.primaryPurple.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text('No Active Quests',
                        style: AppTextStyles.subheading
                            .copyWith(color: textPrimary)),
                    const SizedBox(height: 8),
                    Text('Create a quest to start your adventure!',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeQuests.length,
              itemBuilder: (context, index) {
                final quest = activeQuests[index];
                return QuestCard(
                  quest: quest,
                  onTap: () => _showQuestDialog(quest),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ─── Health Connect Section ──────────────────────────────────────────────

  // State for all activity data
  Map<String, dynamic> _allActivityData = {};

  Future<void> _fetchHealthData() async {
    setState(() {
      _isLoadingHealth = true;
    });

    try {
      await _healthService.initialize();

      // Fetch all 7 activity types
      debugPrint('[HOME] Fetching all activity data...');
      final activityData = await _healthService.getAllActivityData();

      // Also fetch heart rate separately (not in quest data)
      final heartRate = await _healthService.getLatestHeartRate();

      // Fetch weekly data for chart
      final weekData = await _healthService.getWeeklyHealthData();

      // Get missing permissions
      final missing = _healthService.getMissingPermissions();

      if (mounted) {
        setState(() {
          _todaySteps = activityData.steps;
          _heartRate = heartRate;
          _allActivityData = activityData.toMap();
          _missingPermissions = missing;
          _weekData = weekData;
          _isLoadingHealth = false;
        });
      }
    } catch (e) {
      debugPrint('[HOME] Health Connect Error: $e');
      if (mounted) {
        setState(() {
          _isLoadingHealth = false;
        });
      }
    }
  }

  // Missing permissions to show to user
  List<String> _missingPermissions = [];

  Widget _buildHealthConnectSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textWhite : AppColors.textDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Weekly Report',
                style: AppTextStyles.subheading.copyWith(color: textPrimary, fontSize: 18)),
            if (_isLoadingHealth)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPurple),
              ),
            if (!_isLoadingHealth && _allActivityData.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.primaryPurple, size: 20),
                onPressed: _fetchHealthData,
                tooltip: 'Refresh',
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Missing permissions warning
        if (_missingPermissions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text('Missing Permissions',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Please grant read permissions for: ${_missingPermissions.join(', ')} in Health Connect settings.',
                  style: TextStyle(color: Colors.orange.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],

        // Weekly steps chart
        if (_weekData.isNotEmpty) ...[
          const SizedBox(height: 8),
          SimpleBarChart(
            data: _weekData,
            valueExtractor: (d) => d.steps.toDouble(),
            formatValue: (v) => v.toInt().toString(),
            barColor: AppColors.primaryPurple,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const WeeklyReportScreen())),
              icon: const Icon(Icons.bar_chart, size: 18),
              label: const Text('View Full Report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryPurple,
                side: const BorderSide(color: AppColors.primaryPurple),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHealthStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryPurple, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.screenHeading.copyWith(
                  color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.caption.copyWith(color: AppColors.primaryPurple.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildActivityChip(String label, String value, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.primaryPurple),
      label: Text('$label: $value', style: TextStyle(fontSize: 12)),
      backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
      side: BorderSide(color: AppColors.primaryPurple.withOpacity(0.3)),
    );
  }

  // ─── Quest Dialog ─────────────────────────────────────────────────────────

  void _showQuestDialog(Quest quest) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryPurple,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.cardShadowLarge,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(quest.icon,
                          color: Colors.white, size: 26),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(quest.title,
                    style: AppTextStyles.headingWhite
                        .copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(quest.description,
                      style: AppTextStyles.bodyWhite),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _questDetailChip(
                        '⚔️ ${quest.difficultyText}', Colors.white),
                    const SizedBox(width: 8),
                    _questDetailChip(
                        '⭐ +${quest.xpReward} XP', Colors.white),
                    const SizedBox(width: 8),
                    _questDetailChip(
                        '🪙 +${quest.goldReward}', Colors.white),
                  ],
                ),
                if ((quest.targetSteps ?? 0) > 0) ...[
                  const SizedBox(height: 16),
                  Text('Steps Progress',
                      style: AppTextStyles.subheadingWhite
                          .copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (quest.currentSteps / quest.targetSteps!)
                          .clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                      '${quest.currentSteps} / ${quest.targetSteps} steps',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white70)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.25),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _questDetailChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}