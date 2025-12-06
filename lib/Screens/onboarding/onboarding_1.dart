import 'package:flutter/material.dart';
import 'package:real_life_rpg/utils/constants.dart';

class onboarding1 extends StatefulWidget {
  const onboarding1({super.key});

  @override
  State<onboarding1> createState() => _onboarding1State();
}

class _onboarding1State extends State<onboarding1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // skip button
                  TextButton(
                    onPressed:(){},
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
              )
            ],

      )),
    );
  }
}
