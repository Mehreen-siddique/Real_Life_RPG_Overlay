// screens/auth/SignUp_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_life_rpg/Screens/Authentication/LoginScreen.dart';
import 'package:real_life_rpg/Screens/Authentication/VerifyEmailScreen.dart';
import '../../Services/AuthenticationServices/AuthServices.dart';
import '../../Services/AuthenticationServices/auth_validation_service.dart';
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
  bool _obscureConfirmPassword = true;

  Timer? _errorTimer;
  bool _isLoading = false;
  
  // Password strength tracking
  PasswordStrengthResult _passwordStrength = PasswordStrengthResult(
    isValid: false,
    score: 0,
    message: '',
    requirements: [],
  );
  
  @override
  void initState() {
    super.initState();
    // Listen to password changes to update strength indicator
    _passwordController.addListener(_onPasswordChanged);
  }
  
  void _onPasswordChanged() {
    if (!mounted) return;
    setState(() {
      _passwordStrength = AuthValidationService.validatePassword(_passwordController.text);
    });
  }
  
  /// Returns color based on password strength score
  Color _getPasswordStrengthColor() {
    switch (_passwordStrength.score) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  /// Builds the password strength indicator widget
  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strength bar
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index < _passwordStrength.score 
                        ? _getPasswordStrengthColor() 
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          // Strength text
          Text(
            _passwordStrength.message,
            style: TextStyle(
              fontSize: 12,
              color: _getPasswordStrengthColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          // Requirements list (if not all met)
          if (_passwordStrength.requirements.isNotEmpty) ...[
            const SizedBox(height: 4),
            ..._passwordStrength.requirements.map((req) => Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    req,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }



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
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    authService.clearError();

    setState(() => _isLoading = true);

    final success = await authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      confirmPassword: _confirmPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!success && mounted) {
      _clearErrorAfterDelay();
    }

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );
    }
  }
  
  void _showVerificationPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mark_email_read, color: Colors.green),
            SizedBox(width: 8),
            Text('Verify Your Email'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A verification email has been sent to:',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 8),
            Text(
              _emailController.text.trim(),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please check your inbox and click the verification link before logging in.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 8),
            const Text(
              'Can\'t find the email? Check your spam folder.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            child: const Text('Go to Login'),
          ),
        ],
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
                    'Create Account',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 32,
                      color: textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 60),
                Text(

                  'userName',

                  style: AppTextStyles.body.copyWith(

                    fontWeight: FontWeight.w600,

                    fontSize: 15,
                    color: textPrimary,

                  ),

                ),

                const SizedBox(height: 8),

                TextFormField(

                  controller: _nameController,

                  keyboardType: TextInputType.emailAddress,

                  decoration: InputDecoration(

                    hintText: 'Enter your username',

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
                    return AuthValidationService.validateName(value);
                  },
                ),
                const SizedBox(height: 8),
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
                    final result = AuthValidationService.validatePassword(value ?? '');
                    if (!result.isValid) {
                      return 'Password must have:\n${result.requirements.join(', ')}';
                    }
                    final commonWarning = AuthValidationService.getCommonPasswordWarning(value ?? '');
                    if (commonWarning != null) {
                      return commonWarning;
                    }
                    return null;
                  },
                ),
                // Password Strength Indicator
                _buildPasswordStrengthIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Confirm Password',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: AppTextStyles.body.copyWith(color: textSecondary),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primaryPurple,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
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
                    return AuthValidationService.validateConfirmPassword(
                      _passwordController.text,
                      value,
                    );
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
                        style: AppTextStyles.body.copyWith(color: textSecondary),
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



