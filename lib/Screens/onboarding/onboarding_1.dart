import 'package:flutter/material.dart';
import 'package:real_life_rpg/Screens/Authentication/LoginScreen.dart';
import 'package:real_life_rpg/Screens/onboarding/OnboardingClass.dart';
import 'package:real_life_rpg/utils/constants.dart';

class onboarding1 extends StatefulWidget {
  const onboarding1({super.key});

  @override
  State<onboarding1> createState() => _onboarding1State();
}

class _onboarding1State extends State<onboarding1> {

  final PageController _pageController = PageController();
  int _currentPage = 0;


  Widget _buildOnboardingPage(OnboardingPage page) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textWhite : AppColors.textDark;
    final textSecondary = isDark ? AppColors.textDarkMuted : AppColors.textGray;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withOpacity(0.2),
                  page.color.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),
          const SizedBox(height: 60),

          // Title
          Text(
            page.title,
            style: AppTextStyles.heading.copyWith(
              fontSize: 28,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              height: 1.6,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.task_alt_rounded,
      title: 'Turn Tasks into Quests',
      description:
      'Transform your daily routine into exciting adventures. Complete quests and earn XP!',
      color: AppColors.primaryPurple,
    ),
    OnboardingPage(
      icon: Icons.emoji_events_rounded,
      title: 'Level Up & Earn Rewards',
      description:
      'Gain experience points, unlock achievements, and watch your character grow stronger!',
      color: AppColors.accentBlue,
    ),
    OnboardingPage(
      icon: Icons.people_rounded,
      title: 'Compete with Friends',
      description:
      'Challenge your friends and family. Climb the leaderboard and become the ultimate champion!',
      color: AppColors.accentGreen,
    ),
  ];


  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primaryPurple
            : AppColors.primaryPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }


  void _nextPage() {
    _pageController.nextPage(
      duration: AppDurations.normal,
      curve: Curves.easeInOut,
    );
  }

  void _skipToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context)=>LoginScreen()),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // skip button
                  TextButton(
                    onPressed:_skipToLogin,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                ],
              ),
              ),

              // Page View
              Expanded(
                  child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _pages.length,
                      itemBuilder:(context, index){
                        return _buildOnboardingPage(_pages[index]);
                      }

                  )),


              // Page Indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                        (index) => _buildIndicator(index),
                  ),
                ),
              ),

      // Bottom Button
      Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: _currentPage == _pages.length - 1
                  ? _navigateToLogin
                  : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                elevation: 4,
                shadowColor: AppColors.shadowPurple,
              ),
              child: Text(
                _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                style: AppTextStyles.button,
              ),
            ),
          )
      )

            ],

      )),
    );
  }
}
