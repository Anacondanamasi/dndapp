import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/data/services/auth_service.dart';

class ForgotPasswordController extends GetxController{
  static ForgotPasswordController get instance => Get.find();

  final email = TextEditingController();

  void sendPasswordResetEmail(){
    AuthService.instance.passwordResetEmail(email.text.trim());
  }

  void resendPasswordResetEmail(){
    AuthService.instance.resendPasswordResetEmail(email.text.trim());
  }
}
