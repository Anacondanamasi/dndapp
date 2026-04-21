import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/features/authentication/controllers/signup_controller.dart';
import 'package:jewello/features/authentication/screens/login.dart';
import 'package:jewello/utils/theme/buttons_theme.dart';
import 'package:jewello/utils/theme/input_box_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';
import 'package:jewello/utils/validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final controller = Get.put(SignupController());
  final _formkey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: '', showLogo: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create an account',
                        style: DDSilverTextStyles.authHeading.copyWith(fontSize: 28),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),

                  JewelloAuthInput(
                    hintText: 'Full Name',
                    prefixIcon: Icons.person,
                    controller: controller.name,
                    validator: (value) => Validator.validateText(value, 'Full Name'),
                  ),
                  
                  SizedBox(height: 20),

                  JewelloAuthInput(
                    hintText: "Email",
                    prefixIcon: Icons.email_outlined,
                    controller: controller.email,
                    validator: (value) => Validator.validateEmail(value),
                  ),

                  SizedBox(height: 20),

                  JewelloAuthInput(
                    hintText: "Mobile Number",
                    prefixIcon: Icons.phone_android_outlined,
                    controller: controller.phone,
                    validator: (value) => Validator.validateText(value, 'Mobile Number'),
                  ),

                  SizedBox(height: 20),

                  JewelloAuthInput(
                    hintText: "Password",
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    controller: controller.password,
                    validator: (value) => Validator.validatePassword(value)
                  ),

                  SizedBox(height: 20),

                  JewelloAuthInput(
                    hintText: "Confirm Password",
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    controller: controller.confirmPassword,
                    validator: (value) => Validator.validateConfirmPassword(value, controller.password.text),
                  ),

                  SizedBox(height: 20),

                  Text(
                    'By clicking the Register button, you agree to the public offer.',
                    style: DDSilverTextStyles.authRegular,
                  ),

                  SizedBox(height: 40),

                  DDSilverAuthButton(
                    text: "Create Account",
                    onPressed: (){
                      if(_formkey.currentState!.validate()){
                        SignupController.instance.register();
                      }
                    },
                  ),

                  SizedBox(height: 160),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have An Account?',
                        style: DDSilverTextStyles.authRegular,
                      ),
                      JewelloTxtLink(
                        text: 'Login',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
