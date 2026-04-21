import 'package:flutter/material.dart';
import 'package:jewello/features/authentication/controllers/login_controller.dart';
import 'package:jewello/features/authentication/screens/forgot_password.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/features/authentication/screens/sign_up.dart';
import 'package:jewello/utils/theme/buttons_theme.dart';
import 'package:jewello/utils/theme/input_box_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
// rushisorathiya88@gmail.com
// Rushi@895

// trushali@gmail.com
// Trush@2004

// adodiya@rku.ac.in
// Aditya@123

class _LoginScreenState extends State<LoginScreen> {
  final controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  
  @override
  void dispose(){
    controller.email.clear();
    controller.password.clear();
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
                    children: [
                      Text(
                        'Welcome Back!',
                        style: DDSilverTextStyles.authHeading.copyWith(fontSize: 32),
                      ),
                    ],
                  ),
              
                  SizedBox(height: 35),
              
                  JewelloAuthInput(
                    hintText: "Username or Email",
                    prefixIcon: Icons.person,
                    controller: controller.email,
                  ),
              
                  SizedBox(height: 30),
              
                  JewelloAuthInput(
                    hintText: "Password",
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    controller: controller.password,
                  ),

                  SizedBox(height: 15),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      JewelloTxtLink(
                        text: 'Forgot Password?',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
              
                  SizedBox(height: 40),
              
                  DDSilverAuthButton(
                    text: "Login",
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        LoginController.instance.loginUser();
                      }
                    }
                  ),
              
                  SizedBox(height: 60),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: DDSilverTextStyles.authRegular,
                      ),
              
                      JewelloTxtLink(
                        text: 'Sign Up',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
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
