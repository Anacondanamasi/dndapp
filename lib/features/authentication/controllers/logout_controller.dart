import 'package:get/get.dart';
import 'package:jewello/data/services/auth_service.dart';

class LogoutController extends GetxController{
  static LogoutController get instance => Get.find();

  void logout(){
    AuthService.instance.logout();
  }
}
