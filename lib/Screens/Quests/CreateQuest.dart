import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quest.dart';
import '../../utils/constants.dart';

class CreateQuestScreen extends StatefulWidget {
  const CreateQuestScreen({Key? key}) : super(key: key);

  @override
  State<CreateQuestScreen> createState() => _CreateQuestScreenState();
}

class _CreateQuestScreenState extends State<CreateQuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  QuestType _selectedType = QuestType.health;
  QuestDifficulty _selectedDifficulty = QuestDifficulty.easy;
  TimeOfDay? _reminderTime;
  int? _duration;
  bool _isDaily = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Get icon based on quest type
  IconData _getQuestTypeIcon(QuestType type) {
    switch (type) {
      case QuestType.health:
        return Icons.favorite;
      case QuestType.study:
        return Icons.menu_book;
      case QuestType.exercise:
        return Icons.fitness_center;
      case QuestType.social:
        return Icons.people;
      case QuestType.sleep:
        return Icons.bedtime;
      case QuestType.custom:
        return Icons.star;
    }
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
              _buildTitleField(),
              SizedBox(height: AppSizes.paddingLG),
              _buildDescriptionField(),
              SizedBox(height: AppSizes.paddingLG),
              _buildQuestTypeSection(),
              SizedBox(height: AppSizes.paddingLG),
              _buildDifficultySection(),
              SizedBox(height: AppSizes.paddingLG),
              _buildDurationField(),
              SizedBox(height: AppSizes.paddingLG),
              _buildDailyQuestToggle(),
              SizedBox(height: AppSizes.paddingLG),
              _buildReminderSection(),
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
        'Create New Quest',
        style: AppTextStyles.heading.copyWith(fontSize: 20),
      ),
      centerTitle: true,
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
            hintText: 'e.g., Morning Exercise',
            hintStyle: AppTextStyles.body,
            filled: true,
            fillColor: AppColors.whiteBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.edit, color: AppColors.primaryPurple),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a quest title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppTextStyles.captionBold.copyWith(
          color: AppColors.textGray,
          letterSpacing: 0.5,
        )),
        SizedBox(height: AppSizes.paddingSM),
        TextFormField(
          controller: _descriptionController,
          style: AppTextStyles.bodyDark,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe your quest...',
            hintStyle: AppTextStyles.body,
            filled: true,
            fillColor: AppColors.whiteBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quest Type', style: AppTextStyles.captionBold.copyWith(
          color: AppColors.textGray,
          letterSpacing: 0.5,
        )),
        SizedBox(height: AppSizes.paddingSM),
        Wrap(
          spacing: AppSizes.paddingSM,
          runSpacing: AppSizes.paddingSM,
          children: QuestType.values.map((type) {
            final isSelected = type == _selectedType;

            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMD,
                  vertical: AppSizes.paddingSM + 4,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppGradients.primaryPurple : null,
                  color: isSelected ? null : AppColors.whiteBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  boxShadow: isSelected ? AppShadows.glowPurple : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getQuestTypeIcon(type),
                      size: AppSizes.iconSM,
                      color: isSelected ? AppColors.textWhite : AppColors.textDark,
                    ),
                    SizedBox(width: AppSizes.paddingSM),
                    Text(
                      type.toString().split('.').last.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.textWhite : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Duration (Optional)', style: AppTextStyles.captionBold.copyWith(
          color: AppColors.textGray,
          letterSpacing: 0.5,
        )),
        SizedBox(height: AppSizes.paddingSM),
        TextFormField(
          keyboardType: TextInputType.number,
          style: AppTextStyles.bodyDark,
          decoration: InputDecoration(
            hintText: 'Duration in minutes (e.g., 30)',
            hintStyle: AppTextStyles.body,
            filled: true,
            fillColor: AppColors.whiteBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radius),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.timer, color: AppColors.primaryPurple),
            suffixText: 'min',
            suffixStyle: AppTextStyles.body,
          ),
          onChanged: (value) {
            setState(() {
              _duration = int.tryParse(value);
            });
          },
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
                  'Daily Quest',
                  style: AppTextStyles.bodyDark.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Repeat this quest every day',
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

  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reminder (Optional)', style: AppTextStyles.captionBold.copyWith(
          color: AppColors.textGray,
          letterSpacing: 0.5,
        )),
        SizedBox(height: AppSizes.paddingSM),
        GestureDetector(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _reminderTime ?? TimeOfDay.now(),
            );
            if (time != null) {
              setState(() => _reminderTime = time);
            }
          },
          child: Container(
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
                  child: Icon(Icons.notifications, color: AppColors.textWhite, size: 22),
                ),
                SizedBox(width: AppSizes.padding),
                Expanded(
                  child: Text(
                    _reminderTime != null
                        ? 'Reminder set for ${_reminderTime!.format(context)}'
                        : 'Set a reminder time',
                    style: AppTextStyles.body.copyWith(
                      color: _reminderTime != null
                          ? AppColors.textDark
                          : AppColors.textGray,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textGray),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight + 6,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newQuest = Quest(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              description: _descriptionController.text,
              type: _selectedType,
              difficulty: _selectedDifficulty,
              xpReward: _getXPReward(_selectedDifficulty),
              statBonus: _getStatBonus(_selectedDifficulty),
              goldReward: _getGoldReward(_selectedDifficulty),
              isCompleted: false,
              duration: _duration,
              icon: _getQuestTypeIcon(_selectedType),
              gradientColors: _getDifficultyGradient(_selectedDifficulty),
              isDaily: _isDaily,
              isCustom: true,
            );
            Navigator.pop(context, newQuest);
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
}
