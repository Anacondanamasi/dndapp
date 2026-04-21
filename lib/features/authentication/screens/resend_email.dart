import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/features/authentication/controllers/forgot_password_controller.dart';
import 'package:jewello/utils/theme/buttons_theme.dart';
import 'package:jewello/utils/theme/color_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.email});
  // const ResetPasswordScreen({super.key,});


  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: '', showLogo: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  'Check Your Email',
                  style: DDSilverTextStyles.authHeading.copyWith(fontSize: 28),
                ),
      
                  SizedBox(height: 30),
      
                  // Decorative Icon with jewelry theme
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                      colors: [
                        Color(0xFFFDF2F2),
                        Color(0xFFFFE5E5),
                      ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 50,
                          color: DDSilverColors.primary,
                        ),
                      ],
                    ),
                  ),
      
                  SizedBox(height: 30),
      

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'We\'ve sent a password reset link to your email address. Please check your inbox and follow the instructions.',
                      textAlign: TextAlign.center,
                      style: DDSilverTextStyles.authRegular,
                    ),
                  ),
      
                  SizedBox(height: 40),
      
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DDSilverColors.primary.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: DDSilverColors.primary,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The link will expire in 15 minutes for your security',
                            style: DDSilverTextStyles.authRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  SizedBox(height: 35),
      
                  Text(
                    'Didn\'t receive the email?',
                    style: DDSilverTextStyles.authRegular
                  ),
      
                  SizedBox(height: 20),

                  DDSilverAuthButton(
                    text: 'Resend Reset Link',
                    onPressed: () => ForgotPasswordController.instance.resendPasswordResetEmail(),
                    inv: true,
                  ),
      
                  SizedBox(height: 25),

                  DDSilverAuthButton(
                    text: 'Done',
                    onPressed: () => Get.close(2),
                  ),
      
                  SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
