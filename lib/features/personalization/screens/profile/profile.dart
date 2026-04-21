import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/authentication/controllers/logout_controller.dart';
import 'package:jewello/features/personalization/controller/user_controller.dart';
import 'package:jewello/features/personalization/screens/profile/edit_profile.dart';
import 'package:jewello/features/personalization/screens/profile/my_orders.dart';
import 'package:jewello/features/personalization/screens/profile/wishlist.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:jewello/utils/theme/color_theme.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
  final controller = Get.put(UserController());
    final logoutController = Get.put(LogoutController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/profile_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Text(
                          'My Profile',
                          style: TextStyle(
                            fontFamily: 'Antic Didone',
                            fontSize: 35,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 25),

                        Obx(() {
                          final networkImage = controller.user.value.profilePicture;
                          final image = networkImage.isNotEmpty ? NetworkImage(networkImage) : const AssetImage('assets/images/customer.png') as ImageProvider;

                          // Profile Picture and Name
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Container(
                                width: 50,
                                height: 65,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              SizedBox(width: 20),
                              
                              Text(
                                controller.user.value.name,
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 24,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],

                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Overview',
                    style: TextStyle(fontFamily: 'Montserrat', fontSize: 25),
                  ),

                  // profile options
                  const SizedBox(height: 30),
                  ListTile(
                    leading: Image.asset(
                      'assets/icons/my_profile.png',
                      width: 55,
                      height: 55,
                    ),
                    title: const Text(
                      'My Profile',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: EditProfileScreen(),
                        withNavBar: false, // 👈 hides the bottom nav
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: Image.asset(
                      'assets/icons/my_orders.png',
                      width: 55,
                      height: 55,
                    ),
                    title: const Text(
                      'My Orders',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: MyOrdersScreen(),
                        withNavBar: false, // 👈 hides the bottom nav
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: Image.asset(
                      'assets/icons/wishlist.png',
                      width: 55,
                      height: 55,
                    ),
                    title: const Text(
                      'Wishlist',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: WishlistScreen(),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: Image.asset(
                      'assets/icons/logout.png',
                      width: 55,
                      height: 55,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    // onTap: (){
                    //   Get.defaultDialog(
                    //     title: "Logout",
                    //     middleText: "Are you sure you want to logout?",
                    //     textCancel: "Cancel",
                    //     textConfirm: "Logout",
                    //     onConfirm: (){
                    //       Get.back();
                    //       logoutController.logout();
                    //     }
                    //   );
                    // },

                    onTap: () {
                      Get.defaultDialog(
                        title: "Logout",
                        titleStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        middleText: "Are you sure you want to logout?",
                        middleTextStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Colors.white,
                        radius: 12,
                        textCancel: "Cancel",
                        cancelTextColor: Colors.grey[700],
                        textConfirm: "Logout",
                        confirmTextColor: Colors.white,
                        buttonColor: DDSilverColors.primary,
                        barrierDismissible: true,
                        onConfirm: () {
                          Get.back();
                          logoutController.logout();
                          Loaders.successSnackBar(
                            title: "Logged Out",
                            message: "You have successfully logged out.",
                          );
                        },
                      );
                    },

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
