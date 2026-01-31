import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:real_life_rpg/Screens/Quests/EditQuest.dart';
import 'package:real_life_rpg/Services/QuestFirestore/questfirestore.dart';
import 'package:real_life_rpg/Services/DataServices/dataServices.dart';
import 'package:real_life_rpg/utils/constants.dart';
import 'package:provider/provider.dart';


class QuestDetailScreen extends StatefulWidget {
  final Quest quest;
  const QuestDetailScreen({Key? key, required this.quest}) : super(key: key);

  @override
  State<QuestDetailScreen> createState() => _QuestDetailScreenState();
}

class _QuestDetailScreenState extends State<QuestDetailScreen> {
  final QuestServiceFirestore _questService = QuestServiceFirestore();
  final DataService _dataService = DataService();
  late Quest _quest;
  bool _isTimerRunning = false;
  int _elapsedSeconds = 0;
  StreamSubscription<Quest>? _questProgressSub;
  int _currentSteps = 0;
  double _currentDistanceKm = 0.0;
  int _currentDurationMinutes = 0;
  String? _detectedActivity;

  @override
  void initState() {
    super.initState();
    _quest = widget.quest;
    _currentSteps = widget.quest.currentSteps;
    _currentDistanceKm = widget.quest.currentDistanceKm;
    _currentDurationMinutes = widget.quest.currentDurationMinutes;
    _detectedActivity = widget.quest.detectedActivity;
    
    print('QuestDetails: Initialized with quest: ${_quest.title}, id: ${_quest.id}');
    print('QuestDetails: Initial progress - Steps: $_currentSteps, Distance: $_currentDistanceKm km, Duration: $_currentDurationMinutes min');
    
    // Validate quest data
    if (_quest.id == null || _quest.id!.isEmpty) {
      print('QuestDetails: ERROR - Quest ID is null or empty');
    }
    if (_quest.title.isEmpty) {
      print('QuestDetails: WARNING - Quest title is empty');
    }
    
    // Start listening to real-time progress updates from Firestore
    _startProgressListener();
  }
  
  /// Listen to real-time quest progress updates from Firestore
  void _startProgressListener() {
    if (_quest.id == null || _quest.id!.isEmpty) return;
    
    _questProgressSub = _questService.userQuestsStream().map((quests) {
      return quests.firstWhere((q) => q.id == _quest.id, orElse: () => _quest);
    }).listen((updatedQuest) {
      if (mounted) {
        setState(() {
          _quest = updatedQuest;
          _currentSteps = updatedQuest.currentSteps;
          _currentDistanceKm = updatedQuest.currentDistanceKm;
          _currentDurationMinutes = updatedQuest.currentDurationMinutes;
          _detectedActivity = updatedQuest.detectedActivity;
        });
        print('QuestDetails: Real-time update - Steps: $_currentSteps, Distance: $_currentDistanceKm km, Activity: $_detectedActivity');
      }
    }, onError: (e) {
      print('QuestDetails: Error listening to progress updates: $e');
    });
  }

  @override
  void dispose() {
    _questProgressSub?.cancel();
    super.dispose();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quest'),
        content: Text('Are you sure you want to delete "${_quest.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              try {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Deleting quest...'),
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Delete from Firestore
                await _questService.permanentlyDeleteQuest(_quest.id!);
                
                // Show success message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quest deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Navigate back with result=true so parent refreshes
                  Navigator.pop(context, true);
                }
              } catch (e) {
                print('Error deleting quest: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete quest: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar with gradient background
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _quest.difficultyGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: _PatternPainter(_quest.difficultyGradient.first),
                        ),
                      ),
                    ),
                    // Gradient overlay for depth
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.whiteBackground.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.whiteBackground.withOpacity(0.3)),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.whiteBackground),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              // Edit Button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.whiteBackground.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.whiteBackground.withOpacity(0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.whiteBackground),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditQuestScreen(quest: _quest),
                      ),
                    );
                  },
                ),
              ),
              // Delete Button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteConfirmationDialog(),
                ),
              ),
            ],
            title: Text(
              'Quest Details',
              style: AppTextStyles.subheading.copyWith(
                color: AppColors.whiteBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Main Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Enhanced Quest Header Card
                _buildEnhancedQuestHeader(),
                const SizedBox(height: 24),

                // Enhanced Rewards Section
                _buildEnhancedRewardsSection(),
                const SizedBox(height: 24),

                // Enhanced Timer Section (if duration is set)
                if (_quest.duration != null) ...[
                  _buildEnhancedTimerSection(),
                  const SizedBox(height: 24),
                ],

                // Enhanced Quest Progress Section
                _buildEnhancedProgressSection(),
                const SizedBox(height: 24),

                // Enhanced Action Button
                if (!_quest.isCompleted)
                  _buildEnhancedActionButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Quest Header with animations and better visual design
  Widget _buildEnhancedQuestHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _quest.difficultyGradient.first.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: _quest.difficultyGradient.first.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Quest Title and Icon Section
            Row(
              children: [
                // Animated Quest Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _quest.difficultyGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _quest.difficultyGradient.first.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          _quest.icon,
                          color: AppColors.whiteBackground,
                          size: 45,
                        ),
                      ),
                      if (_quest.isCompleted)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.whiteBackground, width: 3),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: AppColors.whiteBackground,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _quest.title,
                        style: AppTextStyles.subheading.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _quest.description,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textGray,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Enhanced Meta Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildEnhancedChip(
                            _quest.type.toString().split('.').last,
                            Icons.category,
                            _quest.difficultyGradient.first,
                          ),
                          _buildEnhancedChip(
                            _quest.difficultyText,
                            Icons.signal_cellular_alt,
                            _getDifficultyColor(),
                          ),
                          if (_quest.duration != null)
                            _buildEnhancedChip(
                              '${_quest.duration} min',
                              Icons.schedule,
                              AppColors.accentBlue,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Rewards Section with better visual design
  Widget _buildEnhancedRewardsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.whiteBackground,
            _quest.difficultyGradient.first.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _quest.difficultyGradient.first.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _quest.difficultyGradient.first.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _quest.difficultyGradient),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppColors.whiteBackground,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quest Rewards',
                  style: AppTextStyles.subheading.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Enhanced Reward Cards
            Row(
              children: [
                Expanded(
                  child: _buildEnhancedRewardCard(
                    'XP',
                    '+${_quest.xpReward}',
                    Icons.star,
                    AppColors.accentBlue,
                    'Experience Points',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEnhancedRewardCard(
                    'Coins',
                    '+${_quest.goldReward}',
                    Icons.monetization_on,
                    AppColors.highlightGold,
                    'Gold Coins',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEnhancedRewardCard(
                    'Bonus',
                    '+${_quest.statBonus}',
                    Icons.add_circle,
                    AppColors.accentGreen,
                    'Stat Bonus',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Timer Section
  Widget _buildEnhancedTimerSection() {
    final progress = _quest.duration != null
        ? (_elapsedSeconds / (_quest.duration! * 60)).clamp(0.0, 1.0)
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryPurple.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timer,
                    color: AppColors.whiteBackground,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quest Timer',
                  style: AppTextStyles.subheading.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Timer Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.05),
                    AppColors.accentBlue.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Time Display
                  Text(
                    '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'of ${_quest.duration} minutes',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Progress Bar
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Progress Percentage
                  Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textGray,
                      fontWeight: FontWeight.w600,
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

  // Enhanced Progress Section with Real-Time Data
  Widget _buildEnhancedProgressSection() {
    // Calculate progress based on activity type
    double progressPercent = 0.0;
    String progressText = '';
    String currentValueText = '';
    String targetValueText = '';
    IconData progressIcon = Icons.trending_up;
    
    if (_quest.isCompleted) {
      progressPercent = 1.0;
      progressText = 'Completed';
    } else if (_quest.activityType == QuestActivityType.walking && _quest.targetSteps != null) {
      // Walking quest - show steps progress
      progressPercent = (_currentSteps / _quest.targetSteps!).clamp(0.0, 1.0);
      progressText = '$_currentSteps / ${_quest.targetSteps} steps';
      currentValueText = '$_currentSteps';
      targetValueText = '${_quest.targetSteps} steps';
      progressIcon = Icons.directions_walk;
    } else if ((_quest.activityType == QuestActivityType.driving || _quest.activityType == QuestActivityType.cycling) && _quest.targetDistanceKm != null) {
      // Distance-based quest
      progressPercent = (_currentDistanceKm / _quest.targetDistanceKm!).clamp(0.0, 1.0);
      progressText = '${_currentDistanceKm.toStringAsFixed(1)} / ${_quest.targetDistanceKm} km';
      currentValueText = '${_currentDistanceKm.toStringAsFixed(1)}';
      targetValueText = '${_quest.targetDistanceKm} km';
      progressIcon = _quest.activityType == QuestActivityType.driving ? Icons.directions_car : Icons.pedal_bike;
    } else if (_quest.targetDurationMinutes != null) {
      // Duration-based quest
      progressPercent = (_currentDurationMinutes / _quest.targetDurationMinutes!).clamp(0.0, 1.0);
      progressText = '$_currentDurationMinutes / ${_quest.targetDurationMinutes} min';
      currentValueText = '$_currentDurationMinutes';
      targetValueText = '${_quest.targetDurationMinutes} min';
      progressIcon = Icons.timer;
    } else {
      progressText = 'In Progress';
    }
    
    final percentText = '${(progressPercent * 100).toInt()}%';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.whiteBackground,
            _quest.difficultyGradient.last.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _quest.difficultyGradient.last.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _quest.difficultyGradient.last.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _quest.difficultyGradient),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    progressIcon,
                    color: AppColors.whiteBackground,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quest Progress',
                  style: AppTextStyles.subheading.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Progress Circle with Percentage
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: progressPercent,
                      strokeWidth: 12,
                      backgroundColor: AppColors.lightBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _quest.isCompleted ? AppColors.accentGreen : _quest.difficultyGradient.first,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        percentText,
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _quest.isCompleted ? AppColors.accentGreen : _quest.difficultyGradient.first,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Progress Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                      Text(
                        'Target',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentValueText.isNotEmpty ? currentValueText : '-',
                        style: AppTextStyles.subheading.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        targetValueText.isNotEmpty ? targetValueText : '-',
                        style: AppTextStyles.subheading.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _quest.difficultyGradient.first,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Show detected activity if available
            if (_detectedActivity != null && _detectedActivity!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.sensors,
                      color: AppColors.accentBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Detected: $_detectedActivity',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Progress Items
            _buildProgressItem(
              'Status',
              _quest.isCompleted ? 'Completed' : 'In Progress',
              _quest.isCompleted ? AppColors.accentGreen : AppColors.primaryPurple,
            ),
            const SizedBox(height: 12),
            _buildProgressItem(
              'Activity Type',
              _quest.activityType?.toString().split('.').last ?? 'General',
              _quest.difficultyGradient.first,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Auto-Completion Status Button
  Widget _buildEnhancedActionButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _quest.isCompleted 
            ? [Colors.grey, Colors.grey.shade600]
            : _quest.difficultyGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_quest.isCompleted ? Colors.grey : _quest.difficultyGradient.first).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: null, // Disabled - only auto-completion allowed
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _quest.isCompleted ? Icons.check_circle : Icons.autorenew,
                  color: AppColors.whiteBackground,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  _quest.isCompleted ? 'Quest Completed' : 'Auto-Tracking Active',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteBackground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Chip Widget
  Widget _buildEnhancedChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Reward Card
  Widget _buildEnhancedRewardCard(String label, String value, IconData icon, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.subheading.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Progress Item Widget
  Widget _buildProgressItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.whiteBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get difficulty color
  Color _getDifficultyColor() {
    switch (_quest.difficulty) {
      case QuestDifficulty.easy:
        return AppColors.accentGreen;
      case QuestDifficulty.medium:
        return AppColors.highlightGold;
      case QuestDifficulty.hard:
        return AppColors.errorRed;
    }
  }

  Widget _buildMetaChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryPurple),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.subheading.copyWith(
              color: color,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for decorative background pattern
class _PatternPainter extends CustomPainter {
  final Color color;
  
  _PatternPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Draw decorative circles pattern
    final circleRadius = 20.0;
    final spacing = 60.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Add some randomness to make it more organic
        final offsetX = (sin(x * 0.01) * 10).toDouble();
        final offsetY = (cos(y * 0.01) * 10).toDouble();
        
        canvas.drawCircle(
          Offset(x + offsetX, y + offsetY),
          circleRadius,
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(_PatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
