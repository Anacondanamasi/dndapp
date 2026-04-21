import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/data/services/auth_service.dart';
import 'package:jewello/data/services/user_services.dart';
import 'package:jewello/features/authentication/models/user_model.dart';
import 'package:jewello/utils/loaders.dart';

class SignupController extends GetxController {

  static SignupController get instance => Get.find();

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void register() async {
    try{

      await AuthService.instance.register(
        email.text.trim(), 
        password.text.trim(),
        name: name.text.trim(),
        phoneNumber: phone.text.trim(),
      );

    }catch (e){
      // Get.back(); // Close loading if still open
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}

