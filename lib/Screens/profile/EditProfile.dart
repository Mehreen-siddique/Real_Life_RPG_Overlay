
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Hero Knight');
  int _selectedAvatar = 0;

  final List<AvatarOption> _avatars = [
    AvatarOption(icon: Icons.person, color: AppColors.primaryPurple),
    AvatarOption(icon: Icons.face, color: AppColors.accentBlue),
    AvatarOption(icon: Icons.emoji_emotions, color: AppColors.accentGreen),
    AvatarOption(icon: Icons.sports_esports, color: AppColors.accentMagenta),
    AvatarOption(icon: Icons.star, color: AppColors.highlightGold),
    AvatarOption(icon: Icons.favorite, color: AppColors.lightPurple),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _avatars[_selectedAvatar].color.withOpacity(0.3),
                            _avatars[_selectedAvatar].color.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _avatars[_selectedAvatar].color,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _avatars[_selectedAvatar].color.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _avatars[_selectedAvatar].icon,
                        size: 60,
                        color: _avatars[_selectedAvatar].color,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Avatar Selection
              Text(
                'Choose Avatar',
                style: AppTextStyles.subheading,
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAvatar == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = index),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _avatars[index].color.withOpacity(0.2)
                              : AppColors.whiteBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? _avatars[index].color
                                : AppColors.borderLight,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected ? AppShadows.cardShadow : [],
                        ),
                        child: Icon(
                          _avatars[index].icon,
                          size: 40,
                          color: _avatars[index].color,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              Text(
                'Hero Name',
                style: AppTextStyles.subheading,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your hero name',
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.primaryPurple,
                  ),
                  filled: true,
                  fillColor: AppColors.whiteBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Bio Field
              Text(
                'Bio',
                style: AppTextStyles.subheading,
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tell us about yourself...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(
                      Icons.description_outlined,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  filled: true,
                  fillColor: AppColors.whiteBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    borderSide: BorderSide(color: AppColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: AppTextStyles.button.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AvatarOption {
  final IconData icon;
  final Color color;

  AvatarOption({required this.icon, required this.color});
}
