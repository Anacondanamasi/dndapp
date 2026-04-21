import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/data/services/user_services.dart';
import 'package:jewello/features/personalization/controller/user_controller.dart';
import 'package:jewello/utils/loaders.dart';

class UpdateUserController extends GetxController{
  static UpdateUserController get instance => Get.find();
  final userController = UserController.instance; 
  final userServices = Get.put(UserServices());

  final fullName = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  
  final address = TextEditingController();
  final pincode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();

  @override
  void onInit(){
    initializeDetails();
    super.onInit();
  }

  Future<void> initializeDetails() async {
    fullName.text = userController.user.value.name;
    email.text = userController.user.value.email;
    phoneNumber.text = userController.user.value.phone;

    address.text = userController.user.value.address;
    pincode.text = userController.user.value.pincode;
    city.text = userController.user.value.city;
    state.text = userController.user.value.state;
    country.text = userController.user.value.country;
  }

  Future<void> updateUserDetails() async{
    try{
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      Map<String, dynamic> updateUser = {
        'Name': fullName.text.trim(),
        'Email': email.text.trim(),
        'PhoneNumber': phoneNumber.text.trim(),
        'Pincode': pincode.text.trim(),
        'Address': address.text.trim(),
        'City': city.text.trim(),
        'State': state.text.trim(),
        'Country': country.text.trim(),
      };

      await userServices.updateUserDetails(updateUser);

      userController.user.value.name = fullName.text.trim();
      userController.user.value.email= email.text.trim();
      userController.user.value.phone= phoneNumber.text.trim();

      userController.user.value.address = address.text.trim();
      userController.user.value.pincode = pincode.text.trim();
      userController.user.value.city = city.text.trim();
      userController.user.value.state = state.text.trim();
      userController.user.value.country = country.text.trim();

      Get.back();


      Loaders.successSnackBar(title: 'Congratulations', message: 'Your profile has been updated successfully');
    }catch (e){
      Get.back();

      Loaders.errorSnackBar(title: 'Ohh Snap!', message: e.toString());
    }
  }

}
