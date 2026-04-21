import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/data/services/auth_service.dart';
import 'package:flutter/widgets.dart';
import 'package:jewello/utils/loaders.dart';


class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();

  void loginUser() async {
    try{
      // Firebase login
      await AuthService.instance.login(email.text.trim(), password.text.trim());

    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap', message: "An unexpected error occurred. $e");
    }
  }
}
