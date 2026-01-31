// screens/auth/login_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Screens/Authentication/ForgotPassword.dart';
import 'package:real_life_rpg/Screens/Authentication/SignupScreen.dart';
import 'package:real_life_rpg/Screens/Home/MainContainer.dart';
import '../../Services/AuthenticationServices/AuthServices.dart';
import '../../Services/AuthenticationServices/auth_validation_service.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  Timer? _errorTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authService = context.read<AuthService>();
      authService.clearError(); // Clear previous errors

      final success = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!success && mounted) {
        // Check if error is email verification related
        final errorMsg = authService.errorMessage;
        if (errorMsg != null && errorMsg.contains('verify your email')) {
          _showEmailVerificationDialog(authService);
        } else {
          _clearErrorAfterDelay(); // Auto-clear error after 5 seconds
        }
      }

      if (success && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainContainerScreen()));
      }
    }
  }

  void _showEmailVerificationDialog(AuthService authService) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mark_email_unread, color: Colors.orange),
            SizedBox(width: 8),
            Text('Email Not Verified'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authService.errorMessage ?? 'Please verify your email before logging in.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 12),
            const Text(
              'Tips:\n• Check your spam/junk folder\n• Click the link in the email\n• Then return here to login',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkCard : AppColors.whiteBackground;
    final border = isDark ? Colors.white12 : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textWhite : AppColors.textDark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textPrimary),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.body.copyWith(color: textPrimary)),
          ],
        ),
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkCard : AppColors.whiteBackground;
    final border = isDark ? Colors.white12 : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.textWhite : AppColors.textDark;
    final textSecondary = isDark ? AppColors.textDarkMuted : AppColors.textGray;
    return
      Scaffold(
      backgroundColor: bg,
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
                    'Welcome Back!',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 32,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Login to continue your journey',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 16,
                      color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                Text(
                  'Email',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: AppTextStyles.body.copyWith(color: textSecondary),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.primaryPurple,
                    ),
                    filled: true,
                    fillColor: surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: border,
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
                    return AuthValidationService.validateEmail(value);
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                Text(
                  'Password',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: AppTextStyles.body.copyWith(color: textSecondary),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primaryPurple,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        color: textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      borderSide: BorderSide(
                        color: border,
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
                    return AuthValidationService.validatePasswordSimple(value);
                  },
                ),
                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,MaterialPageRoute(builder: (context)=>ForgotPasswordScreen())
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Error Message Display
                if (authService.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authService.errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: authService.status == AuthStatus.loading ? null : _handleLogin,
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
                      'Login',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: isDark ? Colors.white24 : null)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTextStyles.caption.copyWith(color: textSecondary),
                      ),
                    ),
                    Expanded(child: Divider(color: isDark ? Colors.white24 : null)),
                  ],
                ),
                const SizedBox(height: 30),

                // Social Login Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onTap: () async {
                          final authService = context.read<AuthService>();
                          final success = await authService.signInWithGoogle();

                          if (success && mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MainContainerScreen()),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: AppTextStyles.body.copyWith(color: textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,MaterialPageRoute(builder: (context)=>SignUpScreen())
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign Up',
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


