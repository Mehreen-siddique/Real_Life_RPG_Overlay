import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Models/quest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Services/QuestFirestore/questfirestore.dart';
import '../../Services/DataServices/dataServices.dart';
import '../../models/challenge_match.dart' show ChallengeTargetType;
import '../../Services/Challenge/challenge_service.dart';
import '../../Services/Notifications/notification_service.dart';
import '../../Services/ARTrigger/ar_trigger_service.dart';
import '../../ArView/AR_Screen.dart';
import '../../utils/constants.dart';

class CreateQuestScreen extends StatefulWidget {
  final String? prefilledTitle;
  final int? prefilledSteps;
  final QuestDifficulty? prefilledDifficulty;
  final String? prefilledDescription;

  const CreateQuestScreen({
    Key? key,
    this.prefilledTitle,
    this.prefilledSteps,
    this.prefilledDifficulty,
    this.prefilledDescription,
  }) : super(key: key);

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _stepsController = TextEditingController();
  final _minutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Apply pre-filled values from SmartSuggestions
    if (widget.prefilledTitle != null) {
      _titleController.text = widget.prefilledTitle!;
    }
    if (widget.prefilledSteps != null) {
      _stepsController.text = widget.prefilledSteps.toString();
    }
    if (widget.prefilledDifficulty != null) {
      _selectedDifficulty = widget.prefilledDifficulty!;
    }
    // Select first activity option as default (must match a DropdownMenuItem value)
    _selectedActivityOption = _sensorActivityTemplates.isNotEmpty
        ? _sensorActivityTemplates.first['label'] as String
        : null;
  }

  // Simplified: only step-based quest type
  QuestDifficulty _selectedDifficulty = QuestDifficulty.easy;
  bool _isDaily = false;
  bool _enableNotifications = true;
  String? _selectedActivityOption;
  
  bool get _isStepBasedActivity {
    final activity = (_selectedActivityOption ?? '').toLowerCase();
    return activity == 'walking' ||
           activity == 'running' ||
           activity == 'sit-stands' ||
           activity.contains('walking') ||
           activity.contains('running') ||
           activity.contains('sit-stand');
  }

  bool get _isSitStandActivity {
    final activity = (_selectedActivityOption ?? '').toLowerCase();
    return activity == 'sit-stands' || activity.contains('sit-stand');
  }

  // Preset quest templates for better UX
  final List<Map<String, dynamic>> _questTemplates = [
    {
      'title': 'Morning Walk',
      'steps': 1000,
      'icon': Icons.directions_walk,
      'description': 'Start your day with a refreshing walk',
    },
    {
      'title': 'Quick Steps',
      'steps': 500,
      'icon': Icons.flash_on,
      'description': 'Short burst of activity',
    },
    {
      'title': 'Evening Stroll',
      'steps': 2000,
      'icon': Icons.nights_stay,
      'description': 'Relaxing walk to end your day',
    },
    {
      'title': 'Fitness Challenge',
      'steps': 3000,
      'icon': Icons.fitness_center,
      'description': 'Push your limits with this challenge',
    },
  ];

  final List<Map<String, dynamic>> _sensorActivityTemplates = const [
    {
      'label': 'Walking (Steps)',
      'icon': Icons.directions_walk,
      'placeholder': 'e.g., Morning walk challenge',
      'suggestedSteps': 3000,
      'suggestedMinutes': 0,
      'activityType': 'walking',
      'description': 'Track steps while walking',
    },
    {
      'label': 'Running (Steps)',
      'icon': Icons.directions_run,
      'placeholder': 'e.g., Running session',
      'suggestedSteps': 2500,
      'suggestedMinutes': 0,
      'activityType': 'running',
      'description': 'Track steps while running',
    },
    {
      'label': 'Cycling (Minutes)',
      'icon': Icons.pedal_bike,
      'placeholder': 'e.g., Bike ride',
      'suggestedSteps': 0,
      'suggestedMinutes': 20,
      'activityType': 'cycling',
      'description': 'Track cycling duration',
    },
    {
      'label': 'Driving Distance (Minutes)',
      'icon': Icons.commute,
      'placeholder': 'e.g., Commute to work',
      'suggestedSteps': 0,
      'suggestedMinutes': 30,
      'activityType': 'driving',
      'description': 'Track driving time for distance quests',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _stepsController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // Simplified: Only exercise-related methods
  IconData _getQuestTypeIcon(QuestType type) {
    return Icons.fitness_center; // Always exercise now
  }

  // Get XP reward based on difficulty
  int _getXPReward(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 15;
      case QuestDifficulty.medium:
        return 25;
      case QuestDifficulty.hard:
        return 40;
    }
  }

  // Get stat bonus based on difficulty
  int _getStatBonus(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 8;
      case QuestDifficulty.medium:
        return 10;
      case QuestDifficulty.hard:
        return 15;
    }
  }

  // Get gold reward based on difficulty
  int _getGoldReward(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 10;
      case QuestDifficulty.medium:
        return 15;
      case QuestDifficulty.hard:
        return 20;
    }
  }

  // Get gradient colors based on difficulty
  List<Color> _getDifficultyGradient(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return AppColors.gradientEasy;
      case QuestDifficulty.medium:
        return AppColors.gradientMedium;
      case QuestDifficulty.hard:
        return AppColors.gradientHard;
    }
  }

  // Apply template for quick quest creation
  void _applyTemplate(Map<String, dynamic> template) {
    setState(() {
      _titleController.text = template['title'];
      _stepsController.text = template['steps'].toString();
    });
  }

  // Get difficulty icon
  IconData _getDifficultyIcon(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return Icons.sentiment_satisfied_alt;
      case QuestDifficulty.medium:
        return Icons.sentiment_neutral;
      case QuestDifficulty.hard:
        return Icons.whatshot;
    }
  }

  // Get difficulty description
  String _getDifficultyDescription(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 'Quick and simple tasks';
      case QuestDifficulty.medium:
        return 'Moderate effort required';
      case QuestDifficulty.hard:
        return 'Challenging and rewarding';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Templates Section
              _buildQuickTemplatesSection(),
              SizedBox(height: AppSizes.paddingXL),
              
              // Live Preview Card
              _buildLivePreviewCard(),
              SizedBox(height: AppSizes.paddingXL),
              
              // Section 1: Activity Selection
              _buildSectionTitle('1. Choose Activity', Icons.category),
              SizedBox(height: AppSizes.paddingSM),
              _buildActivityOptionSelector(),
              
              // Section 2: Goal Input
              _buildSectionTitle('2. Set Your Goal', Icons.track_changes),
              SizedBox(height: AppSizes.paddingSM),
              _buildTitleField(),
              SizedBox(height: AppSizes.paddingMD),
              _buildGoalInputField(),
              SizedBox(height: AppSizes.paddingLG),
              
              // Section 3: Difficulty
              _buildSectionTitle('3. Select Difficulty', Icons.speed),
              SizedBox(height: AppSizes.paddingSM),
              _buildDifficultySection(),
              SizedBox(height: AppSizes.paddingLG),
              
              // Section 4: Notifications
              _buildSectionTitle('4. Notifications', Icons.notifications_active),
              SizedBox(height: AppSizes.paddingSM),
              _buildNotificationToggle(),
              SizedBox(height: AppSizes.paddingXL),
              
              _buildCreateButton(),
              SizedBox(height: AppSizes.paddingMD),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Create Activity Quest',
        style: AppTextStyles.heading.copyWith(fontSize: 20),
      ),
      centerTitle: true,
    );
  }

  // Enhanced Quick Templates Section
  Widget _buildQuickTemplatesSection() {
    final templates = [
      {
        'icon': Icons.directions_walk,
        'title': 'Walking',
        'subtitle': '3000 steps',
        'color': Colors.blue,
        'activity': 'Walking (Steps)',
        'target': '3000',
        'titleText': 'Morning Walk',
      },
      {
        'icon': Icons.directions_run,
        'title': 'Running',
        'subtitle': '2.5 km',
        'color': Colors.orange,
        'activity': 'Running (Steps)',
        'target': '2500',
        'titleText': 'Quick Run',
      },
      {
        'icon': Icons.pedal_bike,
        'title': 'Cycling',
        'subtitle': '20 min',
        'color': Colors.green,
        'activity': 'Cycling (Minutes)',
        'target': '20',
        'titleText': 'Bike Ride',
      },
      {
        'icon': Icons.commute,
        'title': 'Distance',
        'subtitle': '5 km drive',
        'color': Colors.purple,
        'activity': 'Driving Distance (Minutes)',
        'target': '30',
        'titleText': 'Drive Distance',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, color: AppColors.primaryPurple, size: 18),
            SizedBox(width: 8),
            Text(
              'Quick Templates',
              style: AppTextStyles.captionBold.copyWith(
                color: AppColors.textDark,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.paddingSM),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return GestureDetector(
                onTap: () => _applyQuickTemplate(context, template),
                child: Container(
                  width: 110,
                  margin: EdgeInsets.only(right: AppSizes.paddingSM),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (template['color'] as Color).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (template['color'] as Color).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (template['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          template['icon'] as IconData,
                          color: template['color'] as Color,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        template['title'] as String,
                        style: AppTextStyles.bodyDark.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        template['subtitle'] as String,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Apply quick template
  void _applyQuickTemplate(BuildContext context, Map<String, dynamic> template) {
    setState(() {
      _titleController.text = template['titleText'] as String;
      _selectedActivityOption = template['activity'] as String;
      final target = template['target'] as String;
      final activity = (template['activity'] as String);
      
      // Check if it's a minutes-based activity by looking at the label
      if (activity.contains('Minutes')) {
        _minutesController.text = target;
        _stepsController.clear();
      } else {
        _stepsController.text = target;
        _minutesController.clear();
      }
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${template['title']} template applied!'),
          duration: Duration(seconds: 1),
          backgroundColor: AppColors.primaryPurple,
        ),
      );
    }
  }

  // Section Title Builder
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryPurple, size: 18),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.bodyDark.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // Live Preview Card
  Widget _buildLivePreviewCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final xpReward = _getXPReward(_selectedDifficulty);
    final coinReward = _getGoldReward(_selectedDifficulty);
    
    String targetText = '';
    if (_isStepBasedActivity && _stepsController.text.isNotEmpty) {
      targetText = '${_stepsController.text} steps';
    } else if (!_isStepBasedActivity && _minutesController.text.isNotEmpty) {
      targetText = '${_minutesController.text} minutes';
    } else {
      targetText = 'Set your target';
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple.withOpacity(0.8),
            AppColors.primaryPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview, color: AppColors.textWhite, size: 18),
              SizedBox(width: 8),
              Text(
                'Live Preview',
                style: AppTextStyles.subheadingWhite.copyWith(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.textWhite.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleController.text.isEmpty ? 'Your Quest Title' : _titleController.text,
                  style: AppTextStyles.subheadingWhite.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _getSelectedActivityIcon(),
                      color: AppColors.textWhite.withOpacity(0.8),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      _selectedActivityOption ?? 'Select Activity',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textWhite.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _isStepBasedActivity ? Icons.directions_walk : Icons.access_time,
                      color: AppColors.textWhite.withOpacity(0.8),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      targetText,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textWhite.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRewardBadge(Icons.stars, '+$xpReward XP', AppColors.highlightGold),
              _buildRewardBadge(Icons.monetization_on, '+$coinReward', AppColors.highlightGold),
              _buildRewardBadge(
                _getDifficultyIcon(_selectedDifficulty),
                _selectedDifficulty.toString().split('.').last.toUpperCase(),
                AppColors.textWhite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.captionBold.copyWith(color: color),
        ),
      ],
    );
  }

  IconData _getSelectedActivityIcon() {
    final activity = (_selectedActivityOption ?? '').toLowerCase();
    if (activity.contains('walk')) return Icons.directions_walk;
    if (activity.contains('run')) return Icons.directions_run;
    if (activity.contains('cycle')) return Icons.pedal_bike;
    if (activity.contains('sit')) return Icons.airline_seat_recline_normal;
    return Icons.fitness_center;
  }

  // Unified Goal Input Field
  Widget _buildGoalInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.whiteBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryPurple.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isStepBasedActivity ? Icons.directions_walk : Icons.access_time,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _isStepBasedActivity ? _stepsController : _minutesController,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyDark.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: _isStepBasedActivity ? '3000' : '30',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textGray,
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixText: _isStepBasedActivity ? 'steps' : 'minutes',
                    suffixStyle: AppTextStyles.body.copyWith(
                      color: AppColors.textGray,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return _isStepBasedActivity ? 'Enter target steps' : 'Enter target minutes';
                    }
                    final num = int.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          _isStepBasedActivity
              ? '💡 Tip: 3000 steps ≈ 2 km ≈ 120 calories'
              : '💡 Tip: Time-based tracking uses motion sensors',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textGray,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Notification Toggle
  Widget _buildNotificationToggle() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _enableNotifications
              ? AppColors.primaryPurple.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: _enableNotifications ? AppGradients.primaryPurple : null,
              color: _enableNotifications ? null : AppColors.textGray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _enableNotifications ? Icons.notifications_active : Icons.notifications_off,
              color: _enableNotifications ? AppColors.textWhite : AppColors.textGray,
              size: 22,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable Notifications',
                  style: AppTextStyles.bodyDark.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Get reminded to complete your quest',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Switch(
            value: _enableNotifications,
            onChanged: (value) {
              setState(() => _enableNotifications = value);
            },
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorTemplateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensor Activity Templates', style: AppTextStyles.captionBold.copyWith(color: AppColors.textGray, letterSpacing: 0.5)),
        SizedBox(height: AppSizes.paddingSM),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _sensorActivityTemplates.map((template) {
            return ActionChip(
              avatar: Icon(template['icon'] as IconData, size: 18, color: AppColors.primaryPurple),
              label: Text(template['label'] as String),
              onPressed: () {
                _titleController.text = template['placeholder'] as String;
                final activityType = (template['activityType'] as String).toLowerCase();
                _selectedActivityOption = activityType;
                
                if (activityType == 'walking' || activityType == 'running') {
                  _stepsController.text = (template['suggestedSteps'] as int).toString();
                  _minutesController.clear();
                } else {
                  _minutesController.text = (template['suggestedMinutes'] as int).toString();
                  _stepsController.clear();
                }
              },
              backgroundColor: AppColors.whiteBackground,
              side: BorderSide(color: AppColors.primaryPurple.withOpacity(0.25)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivityOptionSelector() {
    final options = _sensorActivityTemplates.map((e) => e['label'] as String).toList();
    // Safety: ensure selected value exists in items list
    String? safeValue = _selectedActivityOption;
    if (safeValue == null || !options.contains(safeValue)) {
      safeValue = options.isNotEmpty ? options.first : null;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity Type', style: AppTextStyles.captionBold.copyWith(color: AppColors.textGray, letterSpacing: 0.5)),
        SizedBox(height: AppSizes.paddingSM),
        DropdownButtonFormField<String>(
          value: safeValue,
          items: options.map((label) {
            final template = _sensorActivityTemplates.firstWhere((e) => e['label'] == label);
            return DropdownMenuItem<String>(
              value: label,
              child: Row(
                children: [
                  Icon(template['icon'] as IconData, color: AppColors.primaryPurple, size: 20),
                  SizedBox(width: 8),
                  Text(label),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() {
            _selectedActivityOption = value;
            if (!_isStepBasedActivity) {
              _stepsController.clear();
            }
          }),
          decoration: InputDecoration(
            labelText: 'Select activity this quest tracks',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.whiteBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSensorHintCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radius),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.primaryPurple, size: 24),
          const SizedBox(width: AppSizes.paddingSM),
          Expanded(
            child: Text(
              'Note: For best accuracy, keep phone in pocket for walking, running, cycling, and sit-stands. For lying down or sitting, keep phone still.',
              style: AppTextStyles.caption.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quest Title', style: AppTextStyles.captionBold.copyWith(
          color: AppColors.textGray,
          letterSpacing: 0.5,
        )),
        SizedBox(height: AppSizes.paddingSM),
        TextFormField(
          controller: _titleController,
          style: AppTextStyles.bodyDark,
          decoration: InputDecoration(
            hintText: 'e.g., Morning Walk',
            labelText: 'Quest Title *',
            labelStyle: AppTextStyles.caption,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryPurple.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
            ),
            filled: true,
            fillColor: AppColors.whiteBackground,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a quest title';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Steps/Minutes Field based on activity type
  Widget _buildStepsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_isStepBasedActivity ? 'Target Steps / Reps' : 'Target Minutes', style: AppTextStyles.captionBold.copyWith(
          color: AppColors.textGray,
          letterSpacing: 0.5,
        )),
        SizedBox(height: AppSizes.paddingSM),
        TextFormField(
          controller: _isStepBasedActivity ? _stepsController : _minutesController,
          enabled: true,
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodyDark,
          decoration: InputDecoration(
            hintText: _isStepBasedActivity ? 'e.g., 1000' : 'e.g., 30',
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textGray),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.whiteBackground,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: Icon(_isStepBasedActivity ? Icons.directions_walk : Icons.access_time, color: AppColors.primaryPurple),
            suffixText: _isStepBasedActivity ? 'steps' : 'minutes',
            suffixStyle: AppTextStyles.body,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return _isStepBasedActivity ? 'Please enter target steps' : 'Please enter target minutes';
            }
            if (_isStepBasedActivity) {
              final steps = int.tryParse(value);
              if (steps == null || steps <= 0) {
                return 'Please enter a valid number of steps';
              }
              if (steps > 50000) {
                return 'Maximum 50,000 steps allowed';
              }
            } else {
              final minutes = int.tryParse(value);
              if (minutes == null || minutes <= 0) {
                return 'Please enter a valid number of minutes';
              }
              if (minutes > 1440) {
                return 'Maximum 24 hours (1440 minutes) allowed';
              }
            }
            return null;
          },
        ),
        SizedBox(height: AppSizes.paddingXS),
        Text(
          _isStepBasedActivity
              ? 'Tip: Start with 500-2000 steps for best results'
              : 'Tip: Time-based tracking for this activity',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textGray,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty Level', style: AppTextStyles.captionBold.copyWith(
          color: AppColors.textGray,
          letterSpacing: 0.5,
        )),
        SizedBox(height: AppSizes.paddingSM),
        Column(
          children: QuestDifficulty.values.map((difficulty) {
            final isSelected = difficulty == _selectedDifficulty;
            final colors = _getDifficultyGradient(difficulty);

            return GestureDetector(
              onTap: () => setState(() => _selectedDifficulty = difficulty),
              child: Container(
                margin: EdgeInsets.only(bottom: AppSizes.paddingSM),
                padding: EdgeInsets.all(AppSizes.padding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radius),
                  border: isSelected
                      ? Border.all(color: AppColors.borderWhite, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: colors[0].withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      _getDifficultyIcon(difficulty),
                      color: AppColors.textWhite,
                      size: AppSizes.icon,
                    ),
                    SizedBox(width: AppSizes.padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            difficulty.toString().split('.').last.toUpperCase(),
                            style: AppTextStyles.subheadingWhite,
                          ),
                          SizedBox(height: 2),
                          Text(
                            _getDifficultyDescription(difficulty),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textWhite.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSM + 4,
                        vertical: AppSizes.paddingXS + 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: AppColors.highlightGold, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '+${_getXPReward(difficulty)} XP',
                            style: AppTextStyles.captionBold.copyWith(
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: AppSizes.paddingSM),
                      Icon(Icons.check_circle, color: AppColors.textWhite, size: 28),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDailyQuestToggle() {
    return Container(
      padding: EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryPurple,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Icon(Icons.repeat, color: AppColors.textWhite, size: 22),
          ),
          SizedBox(width: AppSizes.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Step Quest',
                  style: AppTextStyles.bodyDark.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Repeat this step quest every day',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Switch(
            value: _isDaily,
            onChanged: (value) {
              setState(() => _isDaily = value);
            },
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight + 6,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final targetSteps = _isStepBasedActivity
                ? int.parse(_stepsController.text)
                : 0;
            
            // Simplified: Auto-generate description based on activity type
            final activity = _selectedActivityOption ?? 'General Activity';
            final String autoDescription;
            if (_isSitStandActivity) {
              autoDescription = '[$activity] Complete $targetSteps repetitions to finish this quest';
            } else if (_isStepBasedActivity) {
              autoDescription = '[$activity] Complete $targetSteps steps to finish this quest';
            } else {
              autoDescription = '[$activity] Complete this activity when detected by sensors';
            }
            
            // Calculate target values based on activity type
            final targetMinutes = _isStepBasedActivity ? null : (int.tryParse(_minutesController.text) ?? 30);
            final effectiveTargetSteps = _isStepBasedActivity && targetSteps > 0 ? targetSteps : null;
            
            // Convert activity string to QuestActivityType enum
            QuestActivityType? questActivityType;
            final activityLower = _selectedActivityOption?.toLowerCase() ?? '';
            // Also check the original selected template activity type if available
            final templateActivity = _selectedActivityOption?.toLowerCase() ?? '';
            
            debugPrint('CreateQuest: Mapping activity "$activityLower" / template "$templateActivity"');

            switch (activityLower) {
              case 'walking (steps)':
              case 'walking':
                questActivityType = QuestActivityType.walking;
                break;
              case 'running (steps)':
              case 'running':
                questActivityType = QuestActivityType.running;
                break;
              case 'cycling (minutes)':
              case 'cycling':
                questActivityType = QuestActivityType.cycling;
                break;
              case 'sit-stands (reps)':
              case 'sit-stands':
              case 'sitstands':
                questActivityType = QuestActivityType.exercise; // Mapped as exercise
                break;
              case 'sitting (minutes)':
              case 'sitting':
                questActivityType = QuestActivityType.stationary;
                break;
              case 'standing (minutes)':
              case 'standing':
                questActivityType = QuestActivityType.stationary;
                break;
              case 'lying down (minutes)':
              case 'lying down':
              case 'lyingdown':
                questActivityType = QuestActivityType.stationary;
                break;
              default:
                // If it's step-based, default to walking, otherwise stationary
                questActivityType = _isStepBasedActivity ? QuestActivityType.walking : QuestActivityType.stationary;
                debugPrint('CreateQuest: Unknown activity type "$activityLower", defaulting to $questActivityType, isStepBased=$_isStepBasedActivity');
            }
            
            debugPrint('CreateQuest: Final activityType = $questActivityType');
            
            final newQuest = Quest(
              id: '', // Firestore auto generate
              title: _titleController.text.trim(),
              description: autoDescription,
              type: QuestType.exercise, // Always exercise now
              difficulty: _selectedDifficulty,
              xpReward: _getXPReward(_selectedDifficulty),
              statBonus: _getStatBonus(_selectedDifficulty),
              goldReward: _getGoldReward(_selectedDifficulty),
              isCompleted: false,
              icon: _getQuestTypeIcon(QuestType.exercise),
              gradientColors: _getDifficultyGradient(_selectedDifficulty),
              isDaily: _isDaily,
              isCustom: true,
              // CRITICAL: Activity tracking fields - must be saved for resume to work!
              activityType: questActivityType,
              targetSteps: effectiveTargetSteps,
              targetDurationMinutes: targetMinutes,
            );

            try {
              final dataService = Provider.of<DataService>(context, listen: false);
              final questService = QuestServiceFirestore(dataService: dataService);
              final questId = await questService.addQuest(newQuest);
              
              // ALSO CREATE AS A CHALLENGE so it appears in Challenges tab
              final challengeService = ChallengeService();
              
              // Determine challenge target type based on quest type
              final challengeTargetType = _isStepBasedActivity 
                  ? ChallengeTargetType.steps 
                  : ChallengeTargetType.stationaryMinutes;
              final challengeTargetValue = _isStepBasedActivity 
                  ? targetSteps.toDouble() 
                  : (targetMinutes ?? 30).toDouble();
              
              await challengeService.createChallenge(
                title: _titleController.text.trim(),
                description: autoDescription,
                targetType: challengeTargetType,
                targetValue: challengeTargetValue,
                startAt: DateTime.now(),
                endAt: DateTime.now().add(const Duration(days: 7)),
              );
              
              await dataService.incrementTotalQuestsCreated();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quest created!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              // Navigate back to home screen
              Navigator.of(context).pop();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create quest: $e')),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.primaryPurple,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text('Create Quest', style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }

  // Helper methods for quest data conversion
  QuestType _stringToQuestType(String type) {
    switch (type.toLowerCase()) {
      case 'exercise':
        return QuestType.exercise;
      case 'study':
        return QuestType.study;
      case 'health':
        return QuestType.health;
      case 'social':
        return QuestType.social;
      case 'sleep':
        return QuestType.sleep;
      default:
        return QuestType.custom;
    }
  }

  QuestDifficulty _stringToDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return QuestDifficulty.easy;
      case 'medium':
        return QuestDifficulty.medium;
      case 'hard':
        return QuestDifficulty.hard;
      default:
        return QuestDifficulty.medium;
    }
  }

  // Helper to get icon for quest completion based on activity type
  IconData _getActivityIcon(QuestActivityType? activityType) {
    switch (activityType) {
      case QuestActivityType.walking:
        return Icons.directions_walk;
      case QuestActivityType.running:
        return Icons.run_circle;
      case QuestActivityType.stationary:
        return Icons.bedtime;
      case QuestActivityType.driving:
        return Icons.directions_car;
      case QuestActivityType.cycling:
        return Icons.pedal_bike;
      default:
        return Icons.fitness_center;
    }
  }

  // Helper to get gradient for quest completion based on activity type
  List<Color> _getActivityGradient(QuestActivityType? activityType) {
    // Return the primary purple gradient for all quests
    return [AppColors.primaryPurple, AppColors.accentBlue];
  }

  IconData _stringToIcon(String iconString) {
    switch (iconString) {
      case 'Icons.star':
        return Icons.star;
      case 'Icons.directions_walk':
        return Icons.directions_walk;
      case 'Icons.fitness_center':
        return Icons.fitness_center;
      case 'Icons.school':
        return Icons.school;
      case 'Icons.favorite':
        return Icons.favorite;
      case 'Icons.bedtime':
        return Icons.bedtime;
      case 'Icons.people':
        return Icons.people;
      default:
        return Icons.star;
    }
  }
}
