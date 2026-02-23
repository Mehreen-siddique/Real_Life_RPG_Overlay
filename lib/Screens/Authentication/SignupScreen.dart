// screens/auth/SignUp_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Screens/Authentication/LoginScreen.dart';
import 'package:real_life_rpg/Screens/Home/MainContainer.dart';
import '../../Services/AuthenticationServices/AuthServices.dart';
import '../../utils/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmPasswordController = TextEditingController();

  final _nameController = TextEditingController();

  bool _obscurePassword = true;

  Timer? _errorTimer;
  bool _isLoading = false;



  @override

  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    _confirmPasswordController.dispose();

    _nameController.dispose();

    _errorTimer?.cancel();

    super.dispose();

  }

  void _handleSignup() async {

    if (_formKey.currentState!.validate()) {

      final authService = context.read<AuthService>();

      authService.clearError(); // Clear previous errors



      final success = await authService.signUp(

        email: _emailController.text.trim(),

        password: _passwordController.text,

        name: _nameController.text.trim(),

      );



      if (!success && mounted) {

        _clearErrorAfterDelay(); // Auto-clear error after 5 seconds

      }



      if (success && mounted) {

        // Navigate to home screen

        Navigator.pushReplacement(context,

            MaterialPageRoute(builder: (context) => MainContainerScreen()));

      }

    }

  }



  void _clearErrorAfterDelay() {

    _errorTimer?.cancel();

    _errorTimer = Timer(const Duration(seconds: 5), () {

      if (mounted) {

        context.read<AuthService>().clearError();

      }

    });

  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    return
      Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Welcome Back Text
                Center(
                  child: Text(
                    'Create Account',
                    style: AppTextStyles.heading.copyWith(fontSize: 32),
                  ),
                ),

                const SizedBox(height: 60),
                Text(

                  'userName',

                  style: AppTextStyles.bodyDark.copyWith(

                    fontWeight: FontWeight.w600,

                    fontSize: 15,

                  ),

                ),

                const SizedBox(height: 8),

                TextFormField(

                  controller: _nameController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(

                    hintText: 'Enter your username',

                    hintStyle: AppTextStyles.body,

                    prefixIcon: const Icon(

                      Icons.email_outlined,

                      color: AppColors.primaryPurple,

                    ),

                    filled: true,

                    fillColor: AppColors.whiteBackground,

                    border: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),

                      borderSide: BorderSide(

                        color: AppColors.borderLight,

                      ),

                    ),

                    enabledBorder: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),

                      borderSide: BorderSide(

                        color: AppColors.borderLight,

                      ),

                    ),

                    focusedBorder: OutlineInputBorder(

                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),

                      borderSide: BorderSide(

                        color: AppColors.primaryPurple,

                        width: 1.5,

                      ),

                    ),

                  ),

                  validator: (value) {

                    if (value == null || value.isEmpty) {

                      return 'Please enter your username';

                    }

                    // if (!value.contains('@')) {

                    //   return 'Please enter a valid email';

                    // }

                    return null;

                  },

                ),
                const SizedBox(height: 8),
                Text(
                  'Email',
                  style: AppTextStyles.bodyDark.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: AppTextStyles.body,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primaryPurple,
                    ),
                    filled: true,
                    fillColor: AppColors.whiteBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                Text(
                  'Password',
                  style: AppTextStyles.bodyDark.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: AppTextStyles.body,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primaryPurple,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.whiteBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Confirm Password',
                  style: AppTextStyles.bodyDark.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: AppTextStyles.body,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primaryPurple,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.whiteBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: AppColors.primaryPurple,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: authService.status == AuthStatus.loading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.shadowPurple,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textWhite,
                        ),
                      ),
                    )
                        : Text(
                      'SignUp',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
                const SizedBox(height: 30),


                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.body,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'LogIn',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



