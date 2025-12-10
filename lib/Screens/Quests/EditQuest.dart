// // screens/quest/edit_quest_screen.dart
//
// import 'package:flutter/material.dart';
// import '../../utils/constants.dart';
// import '../../models/quest.dart';
//
// class EditQuestScreen extends StatefulWidget {
//   final Quest quest;
//
//   const EditQuestScreen({Key? key, required this.quest}) : super(key: key);
//
//   @override
//   State<EditQuestScreen> createState() => _EditQuestScreenState();
// }
//
// class _EditQuestScreenState extends State<EditQuestScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _titleController;
//   late TextEditingController _descriptionController;
//   late QuestType _selectedType;
//   late QuestDifficulty _selectedDifficulty;
//   late int _xpReward;
//   late int _duration;
//   late bool _isDaily;
//
//   // final Map<QuestType, QuestTypeData> _questTypes = {
//   //   QuestType.health: QuestTypeData(
//   //     icon: Icons.favorite,
//   //     label: 'Health',
//   //     color: const Color(0xFF34D399),
//   //   ),
//   //   QuestType.study: QuestTypeData(
//   //     icon: Icons.school,
//   //     label: 'Study',
//   //     color: const Color(0xFF6C82F8),
//   //   ),
//   //   QuestType.exercise: QuestTypeData(
//   //     icon: Icons.fitness_center,
//   //     label: 'Exercise',
//   //     color: const Color(0xFFEF4444),
//   //   ),
//   //   QuestType.social: QuestTypeData(
//   //     icon: Icons.people,
//   //     label: 'Social',
//   //     color: const Color(0xFFC459E1),
//   //   ),
//   //   QuestType.sleep: QuestTypeData(
//   //     icon: Icons.bedtime,
//   //     label: 'Sleep',
//   //     color: const Color(0xFF8A52E5),
//   //   ),
//   //   QuestType.custom: QuestTypeData(
//   //     icon: Icons.star,
//   //     label: 'Custom',
//   //     color: const Color(0xFFFFA500),
//   //   ),
//   // };
//
//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.quest.title);
//     _descriptionController = TextEditingController(text: widget.quest.description);
//     _selectedType = widget.quest.type;
//     _selectedDifficulty = widget.quest.difficulty;
//     _xpReward = widget.quest.xpReward;
//     _duration = widget.quest.duration ?? 30;
//     _isDaily = widget.quest.isDaily;
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   void _updateQuest() {
//     if (_formKey.currentState!.validate()) {
//       final updatedQuest = widget.quest.copyWith(
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
//       );
//
//       Navigator.pop(context, updatedQuest);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Quest updated successfully!'),
//           backgroundColor: AppColors.accentGreen,
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: AppColors.textDark),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Edit Quest',
//           style: AppTextStyles.heading.copyWith(fontSize: 20),
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Same fields as CreateQuestScreen...
//               // (Copy all the form fields from CreateQuestScreen)
//
//               const SizedBox(height: 40),
//
//               // Update Button
//               SizedBox(
//                 width: double.infinity,
//                 height: AppSizes.buttonHeight,
//                 child: ElevatedButton(
//                   onPressed: _updateQuest,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryPurple,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//                     ),
//                     elevation: 4,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.check_circle, size: 24),
//                       const SizedBox(width: 12),
//                       Text(
//                         'Update Quest',
//                         style: AppTextStyles.button.copyWith(fontSize: 18),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
