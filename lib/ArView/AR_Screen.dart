// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:model_viewer_plus/model_viewer_plus.dart';
// import '../../utils/constants.dart';
//
// // Character Model Class
// class ARCharacter {
//   final String id;
//   final String name;
//   final String description;
//   final String modelPath;
//   final List<String> animations;
//   final Color themeColor;
//   final IconData icon;
//   final String thumbnail;
//
//   ARCharacter({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.modelPath,
//     required this.animations,
//     required this.themeColor,
//     required this.icon,
//     required this.thumbnail,
//   });
// }
//
// class ARViewScreen extends StatefulWidget {
//   const ARViewScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ARViewScreen> createState() => _ARViewScreenState();
// }
//
// class _ARViewScreenState extends State<ARViewScreen> {
//   // Available characters
//   final List<ARCharacter> characters = [
//     ARCharacter(
//       id: '1',
//       name: 'Dragon',
//       description: 'Fierce guardian with fire breath',
//       modelPath: 'assets/models/Dancing.glb',
//       animations: ['Idle', 'Fly', 'Attack', 'Roar'],
//       themeColor: AppColors.lightBackgroundBox,
//       icon: Icons.catching_pokemon,
//       thumbnail: '🐉',
//     ),
//     ARCharacter(
//       id: '2',
//       name: 'Knight',
//       description: 'Brave warrior with sword',
//       modelPath: 'assets/models/fightingpose.glb',
//       animations: ['fightingpose', 'Walk', 'Attack', 'Victory'],
//       themeColor: AppColors.lightBackgroundBox,
//       icon: Icons.shield,
//       thumbnail: '⚔️',
//     ),
//     ARCharacter(
//       id: '3',
//       name: 'Wizard',
//       description: 'Master of arcane magic',
//       modelPath: 'assets/models/animation.glb',
//       animations: ['Idle', 'Cast Spell', 'Teleport', 'Meditate'],
//       themeColor: AppColors.primaryPurple,
//       icon: Icons.auto_fix_high,
//       thumbnail: '🧙',
//     ),
//     ARCharacter(
//       id: '4',
//       name: 'Phoenix',
//       description: 'Mythical fire bird',
//       modelPath: 'assets/models/Dancing.glb',
//       animations: ['Idle', 'Fly', 'Rebirth', 'Fire Dance'],
//       themeColor: AppColors.highlightGold,
//       icon: Icons.local_fire_department,
//       thumbnail: '🔥',
//     ),
//     ARCharacter(
//       id: '5',
//       name: 'Archer',
//       description: 'Swift ranger with bow',
//       modelPath: 'assets/models/walking.glb',
//       animations: ['Idle', 'Aim', 'Shoot', 'Roll'],
//       themeColor: AppColors.accentBlue,
//       icon: Icons.sports_cricket,
//       thumbnail: '🏹',
//     ),
//   ];
//
//   // Selected character and animation
//   late ARCharacter selectedCharacter;
//   String selectedAnimation = 'fightingpose';
//   bool showAnimationPanel = false;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedCharacter = characters[2]; // Default first character
//     selectedAnimation = selectedCharacter.animations[2];
//   }
//
//
// // App Bar
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: AppGradients.secondaryPurple,
//         ),
//       ),
//       elevation: 0,
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back_ios, color: AppColors.textWhite),
//         onPressed: () => Navigator.pop(context),
//       ),
//       title: Text(
//         'AR Character Viewer',
//         style: AppTextStyles.headingWhite.copyWith(fontSize: 20),
//       ),
//       centerTitle: true,
//       actions: [
//         IconButton(
//           icon: Icon(Icons.info_outline, color: AppColors.textWhite),
//           onPressed: _showInfoDialog,
//         ),
//       ],
//     );
//   }
//
//
//   void _showInfoDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppSizes.radiusMD),
//         ),
//         title: Row(
//           children: [
//             Icon(Icons.view_in_ar, color: AppColors.primaryPurple),
//             SizedBox(width: 8),
//             Text('AR Viewer Guide', style: AppTextStyles.subheading),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildInfoItem('🔄', 'Rotate', 'Drag on the character'),
//               _buildInfoItem('🔍', 'Zoom', 'Pinch to zoom in/out'),
//               _buildInfoItem('🎬', 'Animations', 'Tap animation buttons'),
//               _buildInfoItem('👤', 'Characters', 'Scroll and select below'),
//               _buildInfoItem('📱', 'AR Mode', 'Tap AR button for immersive view'),
//               _buildInfoItem('📸', 'Screenshot', 'Capture your character'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Got it!',
//               style: AppTextStyles.button.copyWith(
//                 color: AppColors.primaryPurple,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildInfoItem(String emoji, String title, String description) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: AppSizes.paddingSM),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(emoji, style: TextStyle(fontSize: 20)),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   description,
//                   style: AppTextStyles.caption,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//   Widget _build3DModelContainer() {
//     return Container(
//       margin: EdgeInsets.all(AppSizes.paddingMD),
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground,
//         borderRadius: BorderRadius.circular(AppSizes.radiusLG),
//         boxShadow: AppShadows.cardShadowLarge,
//         border: Border.all(
//           color: selectedCharacter.themeColor.withOpacity(0.3),
//           width: 3,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(AppSizes.radiusLG),
//         child: Stack(
//           children: [
//             // Background gradient
//             Container(
//               decoration: BoxDecoration(
//                 gradient: RadialGradient(
//                   center: Alignment.center,
//                   radius: 1.0,
//                   colors: [
//                     selectedCharacter.themeColor.withOpacity(0.1),
//                     AppColors.whiteBackground,
//                   ],
//                 ),
//               ),
//             ),
//
//             // 3D Model Viewer
//             ModelViewer(
//               src: selectedCharacter.modelPath,
//               alt: selectedCharacter.name,
//               ar: true,
//               arModes: ['scene-viewer', 'webxr', 'quick-look'],
//               autoRotate: true,
//               cameraControls: true,
//               backgroundColor: Colors.transparent,
//
//               // Camera settings
//               cameraOrbit: "0deg 75deg 3m",
//               minCameraOrbit: "auto auto 1.5m",
//               maxCameraOrbit: "auto auto 5m",
//
//               // Lighting
//               shadowIntensity: 0.8,
//               shadowSoftness: 0.5,
//               exposure: 1.0,
//
//               // Interaction
//               interactionPrompt: InteractionPrompt.auto,
//               interactionPromptThreshold: 500,
//               loading: Loading.eager,
//             ),
//
//             // Character Info Overlay (Top)
//             Positioned(
//               top: 20,
//               left: 20,
//               right: 20,
//               child: _buildCharacterInfo(),
//             ),
//
//             // Animation Selector (Right Side)
//             Positioned(
//               right: 20,
//               top: 100,
//               child: _buildAnimationSelector(),
//             ),
//
//             // // AR Mode Button (Bottom Right)
//             // Positioned(
//             //   bottom: 20,
//             //   right: 20,
//             //   child: FloatingActionButton(
//             //     heroTag: 'ar_mode',
//             //     onPressed: () {
//             //       ScaffoldMessenger.of(context).showSnackBar(
//             //         SnackBar(
//             //           content: Row(
//             //             children: [
//             //               Icon(Icons.view_in_ar, color: Colors.white),
//             //               SizedBox(width: 8),
//             //               Expanded(
//             //                 child: Text(
//             //                     'Tap the AR icon in viewer to enter AR mode'),
//             //               ),
//             //             ],
//             //           ),
//             //           backgroundColor: selectedCharacter.themeColor,
//             //           behavior: SnackBarBehavior.floating,
//             //         ),
//             //       );
//             //     },
//             //     backgroundColor: selectedCharacter.themeColor,
//             //     child: Icon(Icons.view_in_ar, color: AppColors.textWhite),
//             //   ),
//             // ),
//
//             // Screenshot Button (Bottom Left)
//
//
//             Positioned(
//               bottom: 20,
//               left: 20,
//               child: FloatingActionButton(
//                 heroTag: 'screenshot',
//                 mini: true,
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Screenshot saved! 📸'),
//                       backgroundColor: AppColors.accentGreen,
//                     ),
//                   );
//                 },
//                 backgroundColor: AppColors.whiteBackground,
//                 child: Icon(
//                     Icons.camera_alt, color: selectedCharacter.themeColor),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAnimationSelector() {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.paddingSM),
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(AppSizes.radius),
//         boxShadow: AppShadows.cardShadow,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Animations',
//             style: GoogleFonts.poppins(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textGray,
//             ),
//           ),
//           SizedBox(height: AppSizes.paddingSM),
//           ...selectedCharacter.animations.map((animation) {
//             final isSelected = animation == selectedAnimation;
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedAnimation = animation;
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Playing: $animation'),
//                     duration: Duration(seconds: 1),
//                     backgroundColor: selectedCharacter.themeColor,
//                   ),
//                 );
//               },
//               child: Container(
//                 margin: EdgeInsets.only(bottom: AppSizes.paddingXS),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: AppSizes.paddingSM,
//                   vertical: AppSizes.paddingXS,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: isSelected
//                       ? LinearGradient(
//                     colors: [
//                       selectedCharacter.themeColor,
//                       selectedCharacter.themeColor.withOpacity(0.7),
//                     ],
//                   )
//                       : null,
//                   color: isSelected ? null : AppColors.statsBackground,
//                   borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//                 ),
//                 child: Text(
//                   animation,
//                   style: GoogleFonts.poppins(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: isSelected ? AppColors.textWhite : AppColors.textDark,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
//
//
//
//   // Widget _buildCharacterInfo() {
//   //   return Container(
//   //     padding: EdgeInsets.all(AppSizes.padding),
//   //     decoration: BoxDecoration(
//   //       color: AppColors.whiteBackground.withOpacity(0.95),
//   //       borderRadius: BorderRadius.circular(AppSizes.radius),
//   //       boxShadow: [
//   //         BoxShadow(
//   //           color: selectedCharacter.themeColor.withOpacity(0.3),
//   //           blurRadius: 10,
//   //           offset: Offset(0, 4),
//   //         ),
//   //       ],
//   //     ),
//   //     child: Row(
//   //       children: [
//   //         // Character Icon
//   //         Container(
//   //           width: 50,
//   //           height: 50,
//   //           decoration: BoxDecoration(
//   //             gradient: LinearGradient(
//   //               colors: [
//   //                 selectedCharacter.themeColor,
//   //                 selectedCharacter.themeColor.withOpacity(0.7),
//   //               ],
//   //             ),
//   //             borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//   //           ),
//   //           child: Center(
//   //             child: Text(
//   //               selectedCharacter.thumbnail,
//   //               style: TextStyle(fontSize: 28),
//   //             ),
//   //           ),
//   //         ),
//   //         SizedBox(width: AppSizes.padding),
//   //
//   //         // Character Details
//   //         Expanded(
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 selectedCharacter.name,
//   //                 style: AppTextStyles.subheading.copyWith(
//   //                   color: selectedCharacter.themeColor,
//   //                 ),
//   //               ),
//   //               SizedBox(height: 2),
//   //               Text(
//   //                 selectedCharacter.description,
//   //                 style: AppTextStyles.caption,
//   //                 maxLines: 1,
//   //                 overflow: TextOverflow.ellipsis,
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //
//   //         // Current Animation Badge
//   //         Container(
//   //           padding: EdgeInsets.symmetric(
//   //             horizontal: AppSizes.paddingSM,
//   //             vertical: AppSizes.paddingXS,
//   //           ),
//   //           decoration: BoxDecoration(
//   //             color: selectedCharacter.themeColor.withOpacity(0.2),
//   //             borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//   //           ),
//   //           child: Text(
//   //             selectedAnimation,
//   //             style: GoogleFonts.poppins(
//   //               fontSize: 11,
//   //               fontWeight: FontWeight.bold,
//   //               color: selectedCharacter.themeColor,
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//
//   Widget _buildCharacterInfo() {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: AppSizes.paddingSM,
//         vertical: AppSizes.paddingXS,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//         boxShadow: [
//           BoxShadow(
//             color: selectedCharacter.themeColor.withOpacity(0.2),
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: selectedCharacter.themeColor.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Text(
//                 selectedCharacter.thumbnail,
//                 style: TextStyle(fontSize: 20),
//               ),
//             ),
//           ),
//           SizedBox(width: 8),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   selectedCharacter.name,
//                   style: AppTextStyles.body.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: selectedCharacter.themeColor,
//                   ),
//                 ),
//                 Text(
//                   selectedCharacter.description,
//                   style: AppTextStyles.caption,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildCharacterList() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground,
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(AppSizes.radiusLG),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.fromLTRB(
//               AppSizes.paddingMD,
//               AppSizes.padding,
//               AppSizes.paddingMD,
//               AppSizes.paddingSM,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Choose Your Character',
//                   style: AppTextStyles.subheading.copyWith(fontSize: 16),
//                 ),
//                 Text(
//                   '${characters.indexOf(selectedCharacter) + 1}/${characters.length}',
//                   style: AppTextStyles.caption.copyWith(
//                     color: AppColors.primaryPurple,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
//               itemCount: characters.length,
//               itemBuilder: (context, index) {
//                 final character = characters[index];
//                 final isSelected = character.id == selectedCharacter.id;
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedCharacter = character;
//                       selectedAnimation = character.animations[0];
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     width: 100,
//                     margin: EdgeInsets.only(
//                       right: AppSizes.paddingSM,
//                       bottom: AppSizes.paddingSM,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: isSelected
//                           ? LinearGradient(
//                         colors: [
//                           character.themeColor,
//                           character.themeColor.withOpacity(0.7),
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                           : null,
//                       color: isSelected ? null : AppColors.lightBackground,
//                       borderRadius: BorderRadius.circular(AppSizes.radius),
//                       border: Border.all(
//                         color: isSelected
//                             ? character.themeColor
//                             : Colors.transparent,
//                         width: 3,
//                       ),
//                       boxShadow: isSelected
//                           ? [
//                         BoxShadow(
//                           color: character.themeColor.withOpacity(0.4),
//                           blurRadius: 12,
//                           offset: Offset(0, 4),
//                         ),
//                       ]
//                           : [],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Character Thumbnail/Emoji
//                         Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? AppColors.whiteBackground.withOpacity(0.2)
//                                 : character.themeColor.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(
//                             child: Text(
//                               character.thumbnail,
//                               style: TextStyle(fontSize: 30),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: AppSizes.paddingSM),
//
//                         // Character Name
//                         Text(
//                           character.name,
//                           style: GoogleFonts.poppins(
//                             fontSize: 13,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected
//                                 ? AppColors.textWhite
//                                 : AppColors.textDark,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//
//                         // Selected Indicator
//                         if (isSelected)
//                           Padding(
//                             padding: EdgeInsets.only(top: 4),
//                             child: Icon(
//                               Icons.check_circle,
//                               color: AppColors.textWhite,
//                               size: 16,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//        appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           // Large 3D Model Viewer Container
//           Expanded(
//             flex: 7,
//             child: _build3DModelContainer(),
//           ),
//           //
//           // Character Selection List
//           Container(
//             height: 180,
//             child: _buildCharacterList(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../utils/constants.dart';


class ARCharacterItem {
  final String id;
  final String name;
  final String characterClass;
  final String thumbnail;

  /// to store icon of showing character
  final IconData Icon;
  /// GLB model for idle animation.
  final String idleModel;

  /// GLB model for action animation.
  final String actionModel;

  /// Label for action button
  final String actionLabel;

  /// Theme gradient for UI accent
  final List<Color> gradient;

  const ARCharacterItem({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.idleModel,
    required this.actionModel,
    required this.actionLabel,
    required this.gradient,
    required this.Icon,
    required this.thumbnail,
  });
}

enum CharacterAnimMode { idle, action }

class ARCharacterScreen extends StatefulWidget {
  const ARCharacterScreen({Key? key}) : super(key: key);

  @override
  State<ARCharacterScreen> createState() => _ARCharacterScreenState();
}

class _ARCharacterScreenState extends State<ARCharacterScreen> {
  final _picker = ImagePicker();

  File? _pickedImage;

  /// Dummy data
  final List<ARCharacterItem> _characters = const [
    ARCharacterItem(
      id: 'warrior',
      name: 'Warrior Khan',
      characterClass: 'Warrior',
      Icon: Icons.catching_pokemon,
      idleModel: 'assets/images/2idle.glb',
      actionModel: 'assets/models/1Dancing.glb',
      actionLabel: 'fightingpose',
      thumbnail: '🧙',
      gradient: AppColors.gradientHard,
    ),
    ARCharacterItem(
      id: 'scholar',
      name: 'Scholar Ali',
      characterClass: 'Scholar',
      Icon: Icons.shield,
      idleModel: 'assets/images/4idle.glb',
      actionModel: 'assets/models/3HipHop.glb',
      actionLabel: 'Dancing',
      thumbnail: '🔥',
      gradient: AppColors.gradientMedium,
    ),
    ARCharacterItem(
      id: 'explorer',
      name: 'Explorer Fatima',
      characterClass: 'Explorer',
      Icon: Icons.auto_fix_high,
      idleModel: 'assets/images/3idle.glb',
      actionModel: 'assets/models/3Excited.glb',
      actionLabel: 'Excited',
      thumbnail: '🏹',
      gradient: AppColors.gradientEasy,
    ),
  ];

  late ARCharacterItem _selected;
  CharacterAnimMode _animMode = CharacterAnimMode.idle;

  @override
  void initState() {
    super.initState();
    _selected = _characters.first;
  }

  String get _currentModel =>
      _animMode == CharacterAnimMode.idle ? _selected.idleModel : _selected.actionModel;

  String get _currentAnimLabel =>
      _animMode == CharacterAnimMode.idle ? 'Idle' : _selected.actionLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: AppSizes.paddingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              SizedBox(height: AppSizes.paddingSM),

              _viewerCard(context),
              SizedBox(height: AppSizes.paddingMD),

              _animationToggle(),
              SizedBox(height: AppSizes.paddingMD),

              _sectionHeader(),
              SizedBox(height: AppSizes.paddingSM),

              _characterListGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMD,
        vertical: AppSizes.paddingSM,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'AR Character',
              textAlign: TextAlign.center,
              style: AppTextStyles.screenHeading.copyWith(fontSize: 20),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.primaryPurple,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
              boxShadow: AppShadows.glowPurple,
            ),
            child: IconButton(
              tooltip: 'Camera/Gallery',
              icon: Icon(Icons.camera_alt, color: AppColors.textWhite),
              onPressed: _showImageSourceDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewerCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Container(
        height: 420, // fixed height so scroll works nicely
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          boxShadow: AppShadows.cardShadowLarge,
          border: Border.all(
            color: _selected.gradient.first.withOpacity(0.30),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
          child: Stack(
            children: [
              // Soft themed background (no picked image here as per your requirement)
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      _selected.gradient.first.withOpacity(0.10),
                      _selected.gradient.last.withOpacity(0.05),
                      AppColors.whiteBackground,
                    ],
                  ),
                ),
              ),



              // Top info chip
              // Positioned(
              //   top: 16,
              //   left: 16,
              //   right: 16,
              //   child: _characterInfoChip(),
              // ),

              // Bottom left current animation badge


              ModelViewer(
                key: ValueKey('${_selected.id}_${_animMode.name}'),
                src: _currentModel,
                alt: _selected.name,

                // ANIMATION
                autoPlay: true,
                animationName: _currentAnimLabel,

                // AR
                ar: true,
                arModes: const ['scene-viewer', 'webxr', 'quick-look'],
                arScale: ArScale.fixed,

                // Viewer
                cameraControls: true,
                autoRotate: true,
                backgroundColor: Colors.transparent,

                // Remove overlays
                interactionPrompt: InteractionPrompt.none,
                loading: Loading.eager,

                // Camera
                cameraOrbit: "0deg 75deg 3m",
                minCameraOrbit: "auto auto 1.8m",
                maxCameraOrbit: "auto auto 6m",

                shadowIntensity: 1.0,
                shadowSoftness: 0.8,
                exposure: 1.15,
              ),

              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSM + 4,
                    vertical: AppSizes.paddingXS + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(color: _selected.gradient.first, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill, size: 16, color: _selected.gradient.first),
                      SizedBox(width: 6),
                      Text(
                        _currentAnimLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _selected.gradient.first,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // // Bottom right AR button (just hint; actual AR triggered in model-viewer)
              // Positioned(
              //   right: 16,
              //   bottom: 16,
              //   child: _arHintButton(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _characterInfoChip() {
  //   return Container(
  //     padding: EdgeInsets.all(AppSizes.padding),
  //     decoration: BoxDecoration(
  //       color: AppColors.whiteBackground.withOpacity(0.95),
  //       borderRadius: BorderRadius.circular(AppSizes.radius),
  //       boxShadow: AppShadows.cardShadow,
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 48,
  //           height: 48,
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(colors: _selected.gradient),
  //             borderRadius: BorderRadius.circular(AppSizes.radiusSM),
  //           ),
  //           child: Center(
  //             child: Icon(Icons.person, color: AppColors.textWhite, size: 26),
  //           ),
  //         ),
  //         SizedBox(width: AppSizes.padding),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(_selected.name, style: AppTextStyles.subheading.copyWith(fontSize: 16)),
  //               SizedBox(height: 2),
  //               Container(
  //                 padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSM, vertical: 2),
  //                 decoration: BoxDecoration(
  //                   color: _selected.gradient.first.withOpacity(0.18),
  //                   borderRadius: BorderRadius.circular(AppSizes.radiusSM),
  //                 ),
  //                 child: Text(
  //                   _selected.characterClass,
  //                   style: TextStyle(
  //                     fontSize: 11,
  //                     fontWeight: FontWeight.w700,
  //                     color: _selected.gradient.first,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _arHintButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(colors: _selected.gradient),
  //       borderRadius: BorderRadius.circular(AppSizes.radiusXL),
  //       boxShadow: [
  //         BoxShadow(
  //           color: _selected.gradient.first.withOpacity(0.35),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(AppSizes.radiusXL),
  //         onTap: () {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: const Text('AR start karne ke liye viewer ke andar AR icon tap karein.'),
  //               backgroundColor: _selected.gradient.first,
  //               behavior: SnackBarBehavior.floating,
  //             ),
  //           );
  //         },
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(
  //             horizontal: AppSizes.padding,
  //             vertical: AppSizes.paddingSM,
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Icon(Icons.view_in_ar, color: AppColors.textWhite, size: 20),
  //               SizedBox(width: 8),
  //               Text(
  //                 'AR View',
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w700,
  //                   color: AppColors.textWhite,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }


  Widget _animationToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingXS),
        decoration: BoxDecoration(
          color: AppColors.whiteBackground,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: _animButton(
                label: 'Idle',
                icon: Icons.accessibility_new,
                selected: _animMode == CharacterAnimMode.idle,
                onTap: () {
                  setState(() => _animMode = CharacterAnimMode.idle);
                },
              ),
            ),
            Expanded(
              child: _animButton(
                label: _selected.actionLabel,
                icon: Icons.celebration,
                selected: _animMode == CharacterAnimMode.action,
                onTap: () {
                  setState(() => _animMode = CharacterAnimMode.action);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 2),
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: _selected.gradient) : null,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: selected
              ? [
            BoxShadow(
              color: _selected.gradient.first.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: selected ? AppColors.textWhite : AppColors.textGray),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.textWhite : AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Choose Character', style: AppTextStyles.subheading.copyWith(fontSize: 16)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingSM, vertical: AppSizes.paddingXS),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryPurple,
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Text(
              '${_characters.indexOf(_selected) + 1}/${_characters.length}',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _characterListGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // page scroll handles it
        itemCount: _characters.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) {
          final c = _characters[index];
          final isSelected = c.id == _selected.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selected = c;
                _animMode = CharacterAnimMode.idle; // reset to Idle on character change
              });
            },
            child: AnimatedContainer(
              duration: AppDurations.normal,
              decoration: BoxDecoration(
                gradient: isSelected ? LinearGradient(colors: c.gradient) : null,
                color: isSelected ? null : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSizes.radius),
                border: Border.all(
                  color: isSelected ? c.gradient.first : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: c.gradient.first.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // character picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Image.asset(
                      c.thumbnail,
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        // fallback if image missing
                        return Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.statsBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(c.Icon, color: AppColors.primaryPurple),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.characterClass,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.textWhite : AppColors.textDark,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Icon(Icons.check_circle, size: 16, color: AppColors.textWhite),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===== Camera/Gallery =====

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLG)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(AppSizes.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Choose Image', style: AppTextStyles.subheading),
            const SizedBox(height: 18),

            ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppSizes.paddingSM),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryPurple,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Icon(Icons.camera_alt, color: AppColors.textWhite),
              ),
              title: Text('Take Photo', style: AppTextStyles.bodyDark),
              subtitle: Text('Camera se new image', style: AppTextStyles.caption),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),

            ListTile(
              leading: Container(
                padding: EdgeInsets.all(AppSizes.paddingSM),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _selected.gradient),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Icon(Icons.photo_library, color: AppColors.textWhite),
              ),
              title: Text('Choose from Gallery', style: AppTextStyles.bodyDark),
              subtitle: Text('Gallery se select karein', style: AppTextStyles.caption),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),

            if (_pickedImage != null)
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(AppSizes.paddingSM),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  ),
                  child: Icon(Icons.delete, color: AppColors.errorRed),
                ),
                title: Text('Remove Selected Image',
                    style: AppTextStyles.bodyDark.copyWith(color: AppColors.errorRed)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _pickedImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _pickedImage = File(image.path));

        // Backend ready: later you can upload this file to Firebase Storage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image selected (backend upload ready).'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image pick error: $e'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}








// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:model_viewer_plus/model_viewer_plus.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../utils/constants.dart';
//
// // Character Class
// class ARCharacterModel {
//   final String id;
//   final String name;
//   final String characterClass;
//   final String idleAnimation;
//   final String actionAnimation;
//   final String actionName;
//   final List<Color> gradientColors;
//   final String emoji;
//
//   ARCharacterModel({
//     required this.id,
//     required this.name,
//     required this.characterClass,
//     required this.idleAnimation,
//     required this.actionAnimation,
//     required this.actionName,
//     required this.gradientColors,
//     required this.emoji,
//   });
// }
//
// class ARViewScreen extends StatefulWidget {
//   const ARViewScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ARViewScreen> createState() => _ARViewScreenState();
// }
//
// class _ARViewScreenState extends State<ARViewScreen> {
//
//   late final file;
//   File? _selectedImage;
//   late final ImagePicker picker = ImagePicker();
//
//
//   // Available characters
//   final List<ARCharacterModel> characters = [
//     ARCharacterModel(
//       id: '1',
//       name: 'Warrior Khan',
//       characterClass: 'Warrior',
//       idleAnimation: 'assets/models/silly.glb',
//       actionAnimation: 'assets/models/Dancing.glb',
//       actionName: 'Attack',
//       gradientColors: AppColors.gradientHard,
//       emoji: '⚔️',
//     ),
//
//     ARCharacterModel(
//       id: '2',
//       name: 'Scholar Ali',
//       characterClass: 'Scholar',
//       idleAnimation: 'assets/models/animation.glb',
//       actionAnimation: 'assets/models/fightingpose.glb',
//       actionName: 'Read',
//       gradientColors: AppColors.gradientMedium,
//       emoji: '📚',
//     ),
//     ARCharacterModel(
//       id: '3',
//       name: 'Explorer Fatima',
//       characterClass: 'Explorer',
//       idleAnimation: 'assets/models/walking.glb',
//       actionAnimation: 'assets/models/Dancing.glb',
//       actionName: 'Discover',
//       gradientColors: AppColors.gradientEasy,
//       emoji: '🗺️',
//     ),
//     ARCharacterModel(
//       id: '4',
//       name: 'Leader Hassan',
//       characterClass: 'Social Leader',
//       idleAnimation: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
//       actionAnimation: 'https://modelviewer.dev/shared-assets/models/Horse.glb',
//       actionName: 'Inspire',
//       gradientColors: AppColors.gradientPrimaryPurple,
//       emoji: '👥',
//     ),
//   ];
//
//   // Selected character and animation state
//   late ARCharacterModel selectedCharacter;
//   bool isIdleAnimation = true;
//   String currentAnimationName = 'Idle';
//
//   @override
//   void initState() {
//     super.initState();
//     selectedCharacter = characters[0];
//     currentAnimationName = 'Idle';
//   }
//
//   String get currentModelPath {
//     return isIdleAnimation
//         ? selectedCharacter.idleAnimation
//         : selectedCharacter.actionAnimation;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightBackground,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top Bar with Camera Button
//             _buildTopBar(),
//
//             // Main AR Viewer Container
//             // Expanded(
//             //   flex: 6,
//             //   child: _buildARViewerContainer(),
//             // ),
//
//             // Animation Toggle Section
//             // _buildAnimationToggle(),
//             //
//             // // Character Selection Grid
//             // Container(
//             //   height: 200,
//             //   child: _buildCharacterGrid(),
//             // ),iya
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTopBar() {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: AppSizes.paddingMD,
//         vertical: AppSizes.paddingSM,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Back Button
//           IconButton(
//             icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
//             onPressed: () => Navigator.pop(context),
//           ),
//
//           // Title
//           Text(
//             'AR Character',
//             style: AppTextStyles.screenHeading.copyWith(fontSize: 20),
//           ),
//
//           // Camera Button
//           Container(
//             decoration: BoxDecoration(
//               gradient: AppGradients.primaryPurple,
//               borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//               boxShadow: AppShadows.glowPurple,
//             ),
//             child: IconButton(
//               icon: Icon(Icons.camera_alt, color: AppColors.textWhite),
//               onPressed: _showImageSourceDialog,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildARViewerContainer() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground,
//         borderRadius: BorderRadius.circular(AppSizes.radiusLG),
//         boxShadow: AppShadows.cardShadowLarge,
//         border: Border.all(
//           color: selectedCharacter.gradientColors[0].withOpacity(0.3),
//           width: 2,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(AppSizes.radiusLG),
//         child: Stack(
//           children: [
//             // Background Image (if selected)
//             if (_selectedImage != null)
//               Positioned.fill(
//                 child: Opacity(
//                   opacity: 0.3,
//                   child: Image.file(
//                     _selectedImage!,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//
//             // Gradient Background
//             Container(
//               decoration: BoxDecoration(
//                 gradient: RadialGradient(
//                   center: Alignment.center,
//                   radius: 1.2,
//                   colors: [
//                     selectedCharacter.gradientColors[0].withOpacity(0.1),
//                     selectedCharacter.gradientColors[1].withOpacity(0.05),
//                     AppColors.whiteBackground,
//                   ],
//                 ),
//               ),
//             ),
//
//             // 3D Model Viewer with AR
//             ModelViewer(
//               src: currentModelPath,
//               alt: selectedCharacter.name,
//               ar: true,
//               arModes: ['scene-viewer', 'webxr', 'quick-look'],
//               autoRotate: true,
//               cameraControls: true,
//               backgroundColor: Colors.transparent,
//
//               // Camera settings
//               cameraOrbit: "0deg 75deg 3m",
//               minCameraOrbit: "auto auto 2m",
//               maxCameraOrbit: "auto auto 6m",
//
//               // Lighting
//               shadowIntensity: 1.0,
//               shadowSoftness: 0.8,
//               exposure: 1.2,
//
//               // Interaction
//               interactionPrompt: InteractionPrompt.auto,
//               interactionPromptThreshold: 2000,
//               loading: Loading.eager,
//
//               // AR specific
//               arScale: ArScale.fixed,
//             ),
//
//             // Character Info Card (Top)
//             Positioned(
//               top: 20,
//               left: 20,
//               right: 20,
//               child: _buildCharacterInfoCard(),
//             ),
//
//             // // AR Mode Button (Bottom Right)
//             // Positioned(
//             //   bottom: 20,
//             //   right: 20,
//             //   child: Container(
//             //     decoration: BoxDecoration(
//             //       gradient: LinearGradient(
//             //         colors: selectedCharacter.gradientColors,
//             //       ),
//             //       borderRadius: BorderRadius.circular(AppSizes.radiusXL),
//             //       boxShadow: [
//             //         BoxShadow(
//             //           color: selectedCharacter.gradientColors[0].withOpacity(
//             //               0.4),
//             //           blurRadius: 12,
//             //           offset: Offset(0, 4),
//             //         ),
//             //       ],
//             //     ),
//             //     child: Material(
//             //       color: Colors.transparent,
//             //       child: InkWell(
//             //         onTap: () {
//             //           ScaffoldMessenger.of(context).showSnackBar(
//             //             SnackBar(
//             //               content: Row(
//             //                 children: [
//             //                   Icon(Icons.view_in_ar, color: Colors.white),
//             //                   SizedBox(width: 8),
//             //                   Expanded(
//             //                     child: Text(
//             //                         'Tap AR icon in viewer for full AR experience'),
//             //                   ),
//             //                 ],
//             //               ),
//             //               backgroundColor: selectedCharacter.gradientColors[0],
//             //               behavior: SnackBarBehavior.floating,
//             //               duration: Duration(seconds: 3),
//             //             ),
//             //           );
//             //         },
//             //         borderRadius: BorderRadius.circular(AppSizes.radiusXL),
//             //         child: Padding(
//             //           padding: EdgeInsets.symmetric(
//             //             horizontal: AppSizes.padding,
//             //             vertical: AppSizes.paddingSM,
//             //           ),
//             //           child: Row(
//             //             mainAxisSize: MainAxisSize.min,
//             //             children: [
//             //               Icon(Icons.view_in_ar, color: AppColors.textWhite,
//             //                   size: 20),
//             //               SizedBox(width: 8),
//             //               Text(
//             //                 'AR View',
//             //                 style: GoogleFonts.poppins(
//             //                   fontSize: 14,
//             //                   fontWeight: FontWeight.w600,
//             //                   color: AppColors.textWhite,
//             //                 ),
//             //               ),
//             //             ],
//             //           ),
//             //         ),
//             //       ),
//             //     ),
//             //   ),
//             // ),
//             //
//             // // Current Animation Badge (Bottom Left)
//             Positioned(
//               bottom: 20,
//               left: 20,
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: AppSizes.paddingSM + 4,
//                   vertical: AppSizes.paddingXS + 2,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.whiteBackground.withOpacity(0.95),
//                   borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//                   border: Border.all(
//                     color: selectedCharacter.gradientColors[0],
//                     width: 2,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.play_circle_filled,
//                       color: selectedCharacter.gradientColors[0],
//                       size: 16,
//                     ),
//                     SizedBox(width: 6),
//                     Text(
//                       currentAnimationName,
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: selectedCharacter.gradientColors[0],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCharacterInfoCard() {
//     return Container(
//       padding: EdgeInsets.all(AppSizes.padding),
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(AppSizes.radius),
//         boxShadow: AppShadows.cardShadow,
//       ),
//       child: Row(
//         children: [
//           // Character Emoji
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: selectedCharacter.gradientColors,
//               ),
//               borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//             ),
//             child: Center(
//               child: Text(
//                 selectedCharacter.emoji,
//                 style: TextStyle(fontSize: 28),
//               ),
//             ),
//           ),
//           SizedBox(width: AppSizes.padding),
//
//           // Character Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   selectedCharacter.name,
//                   style: AppTextStyles.subheading.copyWith(fontSize: 16),
//                 ),
//                 SizedBox(height: 2),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: AppSizes.paddingSM,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: selectedCharacter.gradientColors[0].withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//                   ),
//                   child: Text(
//                     selectedCharacter.characterClass,
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: selectedCharacter.gradientColors[0],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAnimationToggle() {
//     return Container(
//       margin: EdgeInsets.all(AppSizes.paddingMD),
//       padding: EdgeInsets.all(AppSizes.paddingXS),
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground,
//         borderRadius: BorderRadius.circular(AppSizes.radiusXL),
//         boxShadow: AppShadows.cardShadow,
//       ),
//       child: Row(
//         children: [
//           // Idle Animation Button
//           Expanded(
//             child: _buildAnimationButton(
//               label: 'Idle',
//               icon: Icons.accessibility_new,
//               isSelected: isIdleAnimation,
//               onTap: () {
//                 setState(() {
//                   isIdleAnimation = true;
//                   currentAnimationName = 'Idle';
//                 });
//               },
//             ),
//           ),
//
//           // Action Animation Button
//           Expanded(
//             child: _buildAnimationButton(
//               label: selectedCharacter.actionName,
//               icon: Icons.flash_on,
//               isSelected: !isIdleAnimation,
//               onTap: () {
//                 setState(() {
//                   isIdleAnimation = false;
//                   currentAnimationName = selectedCharacter.actionName;
//                 });
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildAnimationButton({
//     required String label,
//     required IconData icon,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: Duration(milliseconds: 300),
//         padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSM + 2),
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? LinearGradient(colors: selectedCharacter.gradientColors)
//               : null,
//           color: isSelected ? null : Colors.transparent,
//           borderRadius: BorderRadius.circular(AppSizes.radiusXL),
//           boxShadow: isSelected
//               ? [
//             BoxShadow(
//               color: selectedCharacter.gradientColors[0].withOpacity(0.3),
//               blurRadius: 8,
//               offset: Offset(0, 4),
//             ),
//           ]
//               : [],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? AppColors.textWhite : AppColors.textGray,
//               size: 20,
//             ),
//             SizedBox(width: 8),
//             Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: isSelected ? AppColors.textWhite : AppColors.textGray,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCharacterGrid() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.whiteBackground,
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(AppSizes.radiusLG),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header
//           Padding(
//             padding: EdgeInsets.fromLTRB(
//               AppSizes.paddingMD,
//               AppSizes.padding,
//               AppSizes.paddingMD,
//               AppSizes.paddingSM,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Choose Character',
//                   style: AppTextStyles.subheading.copyWith(fontSize: 16),
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: AppSizes.paddingSM,
//                     vertical: AppSizes.paddingXS,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: AppGradients.primaryPurple,
//                     borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//                   ),
//                   child: Text(
//                     '${characters.indexOf(selectedCharacter) + 1}/${characters
//                         .length}',
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textWhite,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Character Grid
//           Expanded(
//             child: GridView.builder(
//               padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 4,
//                 crossAxisSpacing: AppSizes.paddingSM,
//                 mainAxisSpacing: AppSizes.paddingSM,
//                 childAspectRatio: 0.85,
//               ),
//               itemCount: characters.length,
//               itemBuilder: (context, index) {
//                 final character = characters[index];
//                 final isSelected = character.id == selectedCharacter.id;
//
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedCharacter = character;
//                       isIdleAnimation = true;
//                       currentAnimationName = 'Idle';
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: Duration(milliseconds: 300),
//                     decoration: BoxDecoration(
//                       gradient: isSelected
//                           ? LinearGradient(colors: character.gradientColors)
//                           : null,
//                       color: isSelected ? null : AppColors.lightBackground,
//                       borderRadius: BorderRadius.circular(AppSizes.radius),
//                       border: Border.all(
//                         color: isSelected
//                             ? character.gradientColors[0]
//                             : Colors.transparent,
//                         width: 3,
//                       ),
//                       boxShadow: isSelected
//                           ? [
//                         BoxShadow(
//                           color: character.gradientColors[0].withOpacity(0.4),
//                           blurRadius: 12,
//                           offset: Offset(0, 4),
//                         ),
//                       ]
//                           : [],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // Character Emoji
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? AppColors.whiteBackground.withOpacity(0.3)
//                                 : character.gradientColors[0].withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Center(
//                             child: Text(
//                               character.emoji,
//                               style: TextStyle(fontSize: 24),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 6),
//
//                         // Character Class
//                         Text(
//                           character.characterClass,
//                           style: GoogleFonts.poppins(
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected
//                                 ? AppColors.textWhite
//                                 : AppColors.textDark,
//                           ),
//                           textAlign: TextAlign.center,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//
//                         // Selected Indicator
//                         if (isSelected)
//                           Padding(
//                             padding: EdgeInsets.only(top: 4),
//                             child: Icon(
//                               Icons.check_circle,
//                               color: AppColors.textWhite,
//                               size: 16,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           SizedBox(height: AppSizes.paddingSM),
//         ],
//       ),
//     );
//   }
//
//   void _showImageSourceDialog() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(AppSizes.radiusLG),
//         ),
//       ),
//       builder: (context) =>
//           Container(
//             padding: EdgeInsets.all(AppSizes.paddingLG),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Handle Bar
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: AppColors.textGray.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 SizedBox(height: AppSizes.paddingMD),
//
//                 // Title
//                 Text(
//                   'Add Background',
//                   style: AppTextStyles.subheading,
//                 ),
//                 SizedBox(height: AppSizes.paddingLG),
//
//                 // Camera Option
//                 ListTile(
//                   leading: Container(
//                     padding: EdgeInsets.all(AppSizes.paddingSM),
//                     decoration: BoxDecoration(
//                       gradient: AppGradients.primaryPurple,
//                       borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//                     ),
//                     child: Icon(Icons.camera_alt, color: AppColors.textWhite),
//                   ),
//                   title: Text('Take Photo', style: AppTextStyles.body),
//                   subtitle: Text(
//                       'Capture with camera', style: AppTextStyles.caption),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _pickImage(ImageSource.camera);
//                   },
//                 ),
//
//                 // Gallery Option
//                 ListTile(
//                   leading: Container(
//                     padding: EdgeInsets.all(AppSizes.paddingSM),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: selectedCharacter.gradientColors,
//                       ),
//                       borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//                     ),
//                     child: Icon(
//                         Icons.photo_library, color: AppColors.textWhite),
//                   ),
//                   title: Text('Choose from Gallery', style: AppTextStyles.body),
//                   subtitle: Text(
//                       'Select existing photo', style: AppTextStyles.caption),
//                   onTap: () async {
//                     Navigator.pop(context);
//                     await _pickImage(ImageSource.gallery);
//                   },
//                 ),
//
//                 // Remove Background Option (if image exists)
//                 if (_selectedImage != null)
//                   ListTile(
//                     leading: Container(
//                       padding: EdgeInsets.all(AppSizes.paddingSM),
//                       decoration: BoxDecoration(
//                         color: AppColors.errorRed.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(AppSizes.radiusSM),
//                       ),
//                       child: Icon(Icons.delete, color: AppColors.errorRed),
//                     ),
//                     title: Text(
//                       'Remove Background',
//                       style: AppTextStyles.body.copyWith(
//                           color: AppColors.errorRed),
//                     ),
//                     subtitle: Text(
//                         'Clear current image', style: AppTextStyles.caption),
//                     onTap: () {
//                       Navigator.pop(context);
//                       setState(() {
//                         _selectedImage = null;
//                       });
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text('Background removed'),
//                           backgroundColor: AppColors.accentGreen,
//                         ),
//                       );
//                     },
//                   ),
//
//                 SizedBox(height: AppSizes.paddingSM),
//               ],
//             ),
//           ),
//     );
//   }
//
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? image = await picker.pickImage(
//         source: source,
//         maxWidth: 1920,
//         maxHeight: 1080,
//         imageQuality: 85,
//       );
//
//       if (image != null) {
//         setState(() {
//           _selectedImage = File(image.path);
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.check_circle, color: Colors.white),
//                 SizedBox(width: 8),
//                 Text('Background added successfully!'),
//               ],
//             ),
//             backgroundColor: AppColors.accentGreen,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error picking image: $e'),
//           backgroundColor: AppColors.errorRed,
//         ),
//       );
//     }
//   }
// }
