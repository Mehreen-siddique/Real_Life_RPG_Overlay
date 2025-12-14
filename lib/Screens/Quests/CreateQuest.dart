// import 'package:flutter/material.dart';
// import '../../models/quest.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../utils/constants.dart';
//
// class CreateQuestScreen extends StatefulWidget {
//   const CreateQuestScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CreateQuestScreen> createState() => _CreateQuestScreenState();
// }
//
// class _CreateQuestScreenState extends State<CreateQuestScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//
//   QuestType _selectedType = QuestType.health;
//   QuestDifficulty _selectedDifficulty = QuestDifficulty.easy;
//   TimeOfDay? _reminderTime;
//   int _xpReward = 10;
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Create New Quest',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: AppColors.primaryPurple,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Quest Title
//               _buildSectionTitle('Quest Title'),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _titleController,
//                 style: GoogleFonts.poppins(color: AppColors.textGray),
//                 decoration: InputDecoration(
//                   hintText: 'e.g., Morning Exercise',
//                   hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
//                   filled: true,
//                   fillColor: AppColors.lightBackground,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                   prefixIcon: Icon(Icons.edit, color: AppColors.lightPurple),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a quest title';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//
//               // Description
//               _buildSectionTitle('Description'),
//               const SizedBox(height: 12),
//               TextFormField(
//                 controller: _descriptionController,
//                 style: GoogleFonts.poppins(color: AppColors.textDark),
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   hintText: 'Describe your quest...',
//                   hintStyle: GoogleFonts.poppins(color: AppColors.textMuted),
//                   filled: true,
//                   fillColor: AppColors.lightBackground,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // Quest Type
//               _buildSectionTitle('Quest Type'),
//               const SizedBox(height: 12),
//               Wrap(
//                 spacing: 12,
//                 runSpacing: 12,
//                 children: QuestType.values.map((type) {
//                   final isSelected = type == _selectedType;
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() => _selectedType = type);
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       decoration: BoxDecoration(
//                         gradient: isSelected ? AppGradients.primaryPurple:null,
//                         color: isSelected ? null : AppColors.lightBackground,
//                         borderRadius: BorderRadius.circular(25),
//                         // boxShadow: isSelected ? [AppShadows.cardShadow] : [],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             _getQuestTypeIcon(type),
//                             size: 18,
//                             color: isSelected ? Colors.white : AppColors.textDark,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             type.toString().split('.').last.toUpperCase(),
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: isSelected ? Colors.white : AppColors.textMuted,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 24),
//
//               // Difficulty Level with Gradient Colors
//               _buildSectionTitle('Difficulty Level'),
//               const SizedBox(height: 12),
//               Column(
//                 children: QuestDifficulty.values.map((difficulty) {
//                   final isSelected = difficulty == _selectedDifficulty;
//                   final colors = _getDifficultyGradient(difficulty);
//
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedDifficulty = difficulty;
//                         // Update XP based on difficulty
//                         switch (difficulty) {
//                           case QuestDifficulty.easy:
//                             _xpReward = 10;
//                             break;
//                           case QuestDifficulty.medium:
//                             _xpReward = 25;
//                             break;
//                           case QuestDifficulty.hard:
//                             _xpReward = 50;
//                             break;
//                         }
//                       });
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: colors,
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                         border: isSelected
//                             ? Border.all(color: Colors.white, width: 3)
//                             : null,
//                         boxShadow: isSelected
//                             ? [
//                           BoxShadow(
//                             color: colors[0].withOpacity(0.5),
//                             blurRadius: 12,
//                             offset: const Offset(0, 4),
//                           )
//                         ]
//                             : [],
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             _getDifficultyIcon(difficulty),
//                             color: Colors.white,
//                             size: 24,
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   difficulty.toString().split('.').last.toUpperCase(),
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   _getDifficultyDescription(difficulty),
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.stars, color: AppColors.highlightGold, size: 16),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   '+${_getDifficultyXP(difficulty)} XP',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           if (isSelected) ...[
//                             const SizedBox(width: 12),
//                             Icon(Icons.check_circle, color: Colors.white, size: 28),
//                           ],
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 24),
//
//               // Reminder Time
//               _buildSectionTitle('Reminder (Optional)'),
//               const SizedBox(height: 12),
//               GestureDetector(
//                 onTap: () async {
//                   final time = await showTimePicker(
//                     context: context,
//                     initialTime: _reminderTime ?? TimeOfDay.now(),
//                   );
//                   if (time != null) {
//                     setState(() => _reminderTime = time);
//                   }
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppColors.lightBackground,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           gradient: AppGradients.primaryPurple,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(Icons.notifications, color: Colors.white, size: 22),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Text(
//                           _reminderTime != null
//                               ? 'Reminder set for ${_reminderTime!.format(context)}'
//                               : 'Set a reminder time',
//                           style: GoogleFonts.poppins(
//                             fontSize: 15,
//                             color: _reminderTime != null
//                                 ? AppColors.textDark
//                                 : AppColors.textMuted,
//                           ),
//                         ),
//                       ),
//                       Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textMuted),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//
//               // Create Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // Create the quest
//                       final newQuest = Quest(
//                         id: DateTime.now().toString(),
//                         title: _titleController.text,
//                         description: _descriptionController.text,
//                         type: _selectedType,
//                         difficulty: _selectedDifficulty,
//                         xpReward: _xpReward,
//                         isCompleted: false,
//                       );
//                       Navigator.pop(context, newQuest);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.zero,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Ink(
//                     decoration: BoxDecoration(
//                       gradient: AppGradients.primaryPurple,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Container(
//                       alignment: Alignment.center,
//                       child: Text(
//                         'Create Quest',
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: GoogleFonts.poppins(
//         fontSize: 14,
//         fontWeight: FontWeight.w600,
//         color: AppColors.textDark,
//         letterSpacing: 0.5,
//       ),
//     );
//   }
//
//   IconData _getQuestTypeIcon(QuestType type) {
//     switch (type) {
//       case QuestType.health:
//         return Icons.favorite;
//       case QuestType.social:
//         return Icons.group;
//       case QuestType.study:
//         return Icons.school;
//       case QuestType.exercise:
//         return Icons.sports_gymnastics;
//       case QuestType.sleep:
//         return Icons.sports_gymnastics;
//       case QuestType.custom:
//         return Icons.sports_gymnastics;
//     }
//   }
//
//   List<Color> _getDifficultyGradient(QuestDifficulty difficulty) {
//     switch (difficulty) {
//       case QuestDifficulty.easy:
//         return [Color(0xFF34D399), Color(0xFF10B981)]; // Green gradient
//       case QuestDifficulty.medium:
//         return [Color(0xFFFBBF24), Color(0xFFF59E0B)]; // Yellow/Orange gradient
//       case QuestDifficulty.hard:
//         return [Color(0xFFEF4444), Color(0xFFDC2626)]; // Red gradient
//     }
//   }
//
//   IconData _getDifficultyIcon(QuestDifficulty difficulty) {
//     switch (difficulty) {
//       case QuestDifficulty.easy:
//         return Icons.sentiment_satisfied_alt;
//       case QuestDifficulty.medium:
//         return Icons.sentiment_neutral;
//       case QuestDifficulty.hard:
//         return Icons.whatshot;
//     }
//   }
//
//   String _getDifficultyDescription(QuestDifficulty difficulty) {
//     switch (difficulty) {
//       case QuestDifficulty.easy:
//         return 'Quick and simple tasks';
//       case QuestDifficulty.medium:
//         return 'Moderate effort required';
//       case QuestDifficulty.hard:
//         return 'Challenging and rewarding';
//     }
//   }
//
//   int _getDifficultyXP(QuestDifficulty difficulty) {
//     switch (difficulty) {
//       case QuestDifficulty.easy:
//         return 10;
//       case QuestDifficulty.medium:
//         return 25;
//       case QuestDifficulty.hard:
//         return 50;
//     }
//   }
// }
