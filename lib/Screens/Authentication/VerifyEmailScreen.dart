import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Services/AuthenticationServices/AuthServices.dart';
import '../../utils/constants.dart';
import 'LoginScreen.dart';

/// Screen shown after signup to prompt user to verify their email
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isChecking = false;
  Timer? _autoCheckTimer;
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 5 seconds
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkVerification();
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  /// Checks if email has been verified
  Future<void> _checkVerification() async {
    if (_isChecking) return;
    
    setState(() => _isChecking = true);
    
    final authService = context.read<AuthService>();
    final isVerified = await authService.reloadAndCheckVerification();
    
    if (isVerified && mounted) {
      // Stop auto-check
      _autoCheckTimer?.cancel();
      
      // Show success and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! Redirecting to login...'),
          backgroundColor: Colors.green,
        ),
      );
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  /// Resends verification email with cooldown
  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;
    
    final authService = context.read<AuthService>();
    final success = await authService.resendVerificationEmail();
    
    if (success && mounted) {
      // Start cooldown
      setState(() => _resendCooldown = 60);
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _resendCooldown--;
            if (_resendCooldown <= 0) {
              _resendTimer?.cancel();
            }
          });
        }
      });
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.textWhite : AppColors.textDark;
    final textSecondary = isDark ? AppColors.textDarkMuted : AppColors.textGray;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // Email Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread,
                  size: 50,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 30),
              
              // Title
              Text(
                'Verify Your Email',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 28,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'We\'ve sent a verification email to your inbox. Please check your email and click the verification link to complete your registration.',
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  color: textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Success Message
              if (authService.successMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authService.successMessage!,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Error Message
              if (authService.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authService.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Loading Indicator
              if (authService.status == AuthStatus.loading || _isChecking)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              
              const SizedBox(height: 20),
              
              // I Have Verified Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: (authService.status == AuthStatus.loading || _isChecking)
                      ? null
                      : _checkVerification,
                  icon: const Icon(Icons.check),
                  label: const Text('I Have Verified'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Resend Email Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: (_resendCooldown > 0 || authService.status == AuthStatus.loading)
                      ? null
                      : _resendEmail,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    _resendCooldown > 0
                        ? 'Resend in ${_resendCooldown}s'
                        : 'Resend Email',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    side: const BorderSide(color: AppColors.primaryPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Go to Login Button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: TextButton.icon(
                  onPressed: _goToLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Go to Login'),
                  style: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTip('Check your spam/junk folder'),
                    _buildTip('Click the link in the email'),
                    _buildTip('Then click "I Have Verified" button'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
