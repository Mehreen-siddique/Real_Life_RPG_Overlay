

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
        height: 420,
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

            ],
          ),
        ),
      ),
    );
  }

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



  //  Camera/Gallery

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









