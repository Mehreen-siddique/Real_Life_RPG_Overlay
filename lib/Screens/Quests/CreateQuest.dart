//
// import 'package:flutter/material.dart';
// import 'package:real_life_rpg/Models/quest.dart';
// import 'package:real_life_rpg/utils/constants.dart';
//
//
//
// class CreateQuest extends StatefulWidget {
//   final Quest quest;
//   const CreateQuest({Key? key, required this.quest}) : super(key: key);
//
//   @override
//   State<CreateQuest> createState() => _CreateQuestState();
// }
//
// class _CreateQuestState extends State<CreateQuest> {
//   // initialization:
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//
//   QuestType _selectedType = QuestType.custom;
//   QuestDifficulty _selectedDifficulty = QuestDifficulty.medium;
//   int _xpReward = 20;
//   int _duration = 30;
//   bool _isDaily = false;
//
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//
//   void _saveQuest() {
//     if (_formKey.currentState!.validate()) {
//       // Create new quest
//       final quest = Quest(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         title: _titleController.text,
//         description: _descriptionController.text,
//         type: _selectedType,
//         difficulty: _selectedDifficulty,
//         xpReward: _xpReward,
//         statBonus: (_xpReward * 0.4).round(),
//         goldReward: (_xpReward * 0.5).round(),
//         duration: _duration,
//         icon: _questTypes[_selectedType]!.icon,
//         gradientColors: _questTypes[_selectedType]!.gradientColors,
//         isDaily: _isDaily,
//         isCustom: true,
//       );
//
//       // Return to previous screen
//       Navigator.pop(context, true);
//
//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Quest created successfully!'),
//           backgroundColor: AppColors.accentGreen,
//         ),
//       );
//     }
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return
//       Scaffold(
//         backgroundColor: AppColors.lightBackground,
//
//
//
//
//
//       );
//   }
//
//
// }
