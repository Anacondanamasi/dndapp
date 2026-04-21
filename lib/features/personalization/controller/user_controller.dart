import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewello/data/services/user_services.dart';
import 'package:jewello/features/authentication/models/user_model.dart';
import 'package:jewello/utils/loaders.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();
  
  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;

  final userService = Get.put(UserServices());

  
  @override
  void onInit(){
    super.onInit();
    fetchUserRecord();
  }

  /// fetch the data of the user
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await UserServices.instance.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally{
      profileLoading.value = false;
    }
  }


  /// upload the profile picture
  
  uploadProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 512, maxWidth: 512, imageQuality: 70);

      if(image != null){
        // upload image to Supabase storage bucket 'profiles'
        final imageUrl = await userService.uploadImage('profiles', image);
      
        if (imageUrl.isNotEmpty) {
          // update user image record (Note: using snake_case 'profile_picture' to match DB)
          Map<String, dynamic> json = {'profile_picture' : imageUrl};
          await userService.updateSingleField(json);

          user.value.profilePicture = imageUrl;
          user.refresh();
          
          Loaders.successSnackBar(title: "Congratulations", message: "Your profile Picture has been updated!");
        }
      }
    } catch (e) {
      Loaders.errorSnackBar(title: "Ohh Snap", message: "Something went wrong: $e");
    }

  }
}
