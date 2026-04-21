import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/authentication/screens/forgot_password.dart';
import 'package:jewello/features/personalization/controller/update_user_controller.dart';
import 'package:jewello/features/personalization/controller/user_controller.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/buttons_theme.dart';
import 'package:jewello/utils/theme/input_box_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';
import 'package:jewello/utils/validator.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final userController = UserController.instance;
  final controller = Get.put(UpdateUserController());

  // final updateController
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBarThemeStyle(
        title: 'Edit Profile'
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              // Profile Image
              Obx((){
                final networkImage = userController.user.value.profilePicture;
                final image = networkImage.isNotEmpty ? NetworkImage(networkImage) : const AssetImage('assets/images/customer.png') as ImageProvider;

                return CircleAvatar(
                  radius: 50,
                  backgroundImage: image, // Add your image asset
                  backgroundColor: Colors.grey[300],
                );
              }),
              SizedBox(height: 20),

               TextButton(
                onPressed: () => userController.uploadProfilePicture(),
                child : Text(
                  'Change Profile Picture',
                  style: DDSilverTextStyles.linkText,
                )
              ),

              SizedBox(height: 40),

              // Personal Details Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              EditProfileTextField(
                label: 'Name',
                controller: controller.fullName,
                validator: (value) => Validator.validateText(value, 'Full Name'),
              ),
              SizedBox(height: 20),

              // Email Field
              EditProfileTextField(
                controller: controller.email,
                label: 'Email Address',
                validator: (value) => Validator.validateEmail(value),

              ),
              SizedBox(height: 10),

              // Password Field
              JewelloTxtLink(
                text: 'Change Password?',
                onPressed: () {
                 PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ForgotPasswordScreen(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),

              SizedBox(height: 40),

               Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contact Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Phone Number Field
              EditProfileTextField(
                controller: controller.phoneNumber,
                label: 'Phone Number',
                validator: (value) => Validator.validatePhoneNumber(value),
              ),

              SizedBox(height: 40),
              // Business Address Details Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Address Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),


              // Address Field
              EditProfileTextField(
                controller: controller.address,
                label: 'Address',
                validator: (value) => Validator.validateText(value, 'Address'),
              ),
              SizedBox(height: 20),

              // City Field
              EditProfileTextField(
                controller: controller.city,
                label: 'City',
                validator: (value) => Validator.validateText(value, 'City'),
              ),
              SizedBox(height: 20),

              // Pincode Field
              EditProfileTextField(
                controller: controller.pincode,
                label: 'Pincode',
                validator: (value) => Validator.validateText(value, 'Pincode'),
              ),
              SizedBox(height: 20),

              // State Field
              EditProfileTextField(
                controller: controller.state,
                label: 'State',
                validator: (value) => Validator.validateText(value, 'State'),
              ),
              SizedBox(height: 20),

              // Country Field
              EditProfileTextField(
                controller: controller.country,
                label: 'Country',
                validator: (value) => Validator.validateText(value, 'Country'),
              ),
              SizedBox(height: 40),

              // Save Button
              DDSilverAuthButton(
                text: "Save",
                onPressed: () => {
                  if(_formKey.currentState!.validate()){
                    controller.updateUserDetails()
                  }
                }
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
