
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Services/AuthenticationServices/AuthServices.dart';
import '../../utils/constants.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authService = context.read<AuthService>();
      final success = await authService.resetPassword(
        email: _emailController.text.trim(),
      );

      if (success && mounted) {
        setState(() => _emailSent = true);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.paddingMD),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizes.paddingXL),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_reset, color: AppColors.textWhite, size: 40),
                ),
                SizedBox(height: AppSizes.paddingLG),

                // Title
                Text('Forgot Password?', style: AppTextStyles.screenHeading.copyWith(fontSize: 28)),
                SizedBox(height: 8),
                Text(
                  'Enter your email and we\'ll send you reset instructions.',
                  style: AppTextStyles.body,
                ),
                SizedBox(height: AppSizes.paddingXL),

                if (!_emailSent) ...[
                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyDark,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: AppColors.primaryPurple),
                      filled: true,
                      fillColor: AppColors.whiteBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email required';
                      // Basic email validation regex
                      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(v)) return 'Invalid email address';
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.paddingMD),

                  // Error
                  if (authService.errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(AppSizes.paddingSM),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: AppColors.errorRed, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authService.errorMessage!,
                              style: AppTextStyles.caption.copyWith(color: AppColors.errorRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: AppSizes.padding),

                  // Send Reset Button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight + 6,
                    child: ElevatedButton(
                      onPressed: authService.status == AuthStatus.loading ? null : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                        elevation: 0,
                      ),
                      child: authService.status == AuthStatus.loading
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
                          : Text('Send Reset Email', style: AppTextStyles.button),
                    ),
                  ),
                ] else ...[
                  // Success Message
                  Container(
                    padding: EdgeInsets.all(AppSizes.paddingLG),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      border: Border.all(color: AppColors.accentGreen),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.accentGreen, size: 60),
                        SizedBox(height: AppSizes.padding),
                        Text(
                          'Reset Email Sent!',
                          style: AppTextStyles.subheading.copyWith(color: AppColors.accentGreen),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Check your email (${_emailController.text}) for password reset instructions.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingLG),

                  // Back to Login
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight + 6,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryPurple, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius),
                        ),
                      ),
                      child: Text(
                        'Back to Login',
                        style: AppTextStyles.button.copyWith(color: AppColors.primaryPurple),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


}
