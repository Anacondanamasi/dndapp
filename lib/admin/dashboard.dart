import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/admin/all_banners.dart';
import 'package:jewello/admin/all_category.dart';
import 'package:jewello/admin/all_order.dart';
import 'package:jewello/admin/all_product.dart';
import 'package:jewello/features/authentication/controllers/logout_controller.dart';
import 'package:jewello/utils/loaders.dart';

import 'package:jewello/utils/theme/color_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Admin Profile',
                          style: TextStyle(
                            fontFamily: 'Antic Didone',
                            fontSize: 35,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Image.asset(
                      'assets/icons/wishlist.png',
                      width: 55,
                      height: 55,
                    ),
                    title: const Text(
                      'Products',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllProductScreen(),
                        ),
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
                      'Orders',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllOrdersScreen(),
                        ), // 🔹 your Orders screen
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library_outlined,
                      size: 42,
                      color: Color(0xFF003049),
                    ),
                    title: const Text(
                      'Home Banners',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllBannersScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(
                      Icons.category_outlined,
                      size: 42,
                      color: Color(0xFF003049),
                    ),
                    title: const Text(
                      'Categories',
                      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllCategoryScreen(),
                        ),
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
