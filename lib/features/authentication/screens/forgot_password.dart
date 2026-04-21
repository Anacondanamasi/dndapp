import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/features/authentication/controllers/forgot_password_controller.dart';
import 'package:jewello/utils/theme/buttons_theme.dart';
import 'package:jewello/utils/theme/input_box_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';
import 'package:jewello/utils/validator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final controller = Get.put(ForgotPasswordController());
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();

  @override
  void dispose(){
    controller.email.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: '', showLogo: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children : [
                      Text(
                        'Forgot password?',
                        style: DDSilverTextStyles.authHeading.copyWith(fontSize: 28),
                      ),
                    ]
                  ),

                  SizedBox(height: 35),
                  JewelloAuthInput(
                    hintText: 'Enter your Email Address',
                    prefixIcon: Icons.email_outlined,
                    controller: controller.email,
                    validator: Validator.validateEmail,
                  ),
              
                  SizedBox(height: 30),
              
                  Text(
                    'We will send you an email with a link to reset your password.',
                    style: DDSilverTextStyles.authRegular,
                  ),
              
                  SizedBox(height: 30),
              
                  DDSilverAuthButton(
                    text: 'Send Link',
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        ForgotPasswordController.instance.sendPasswordResetEmail();                      
                      }
                    },
                  ),                  
                  SizedBox(height: 250),            
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}
