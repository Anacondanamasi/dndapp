import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jewello/admin/dashboard.dart';
import 'package:jewello/features/authentication/screens/login.dart';
import 'package:jewello/features/authentication/screens/onboard.dart';
import 'package:jewello/features/authentication/screens/resend_email.dart';
import 'package:jewello/features/personalization/controller/update_user_controller.dart';
import 'package:jewello/features/personalization/controller/user_controller.dart';
import 'package:jewello/navigation_menu.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:jewello/utils/theme/color_theme.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find();

  final _auth = sb.Supabase.instance.client.auth;
  sb.User? get sbUser => _auth.currentUser;
  
  Rxn<sb.User> loggedinUser = Rxn<sb.User>();

  final deviceStorage = GetStorage();

  late Rx<sb.User?> currentUser;

  @override
  void onInit(){
    loggedinUser.value = _auth.currentUser;
    _auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      loggedinUser.value = user;
      _setInitialScreen(user);
    });
    super.onInit();
  }

  bool get isLoggedIn => loggedinUser.value != null;

  @override
  void onReady() {
    currentUser = Rx<sb.User?>(_auth.currentUser);
  }

  _setInitialScreen(sb.User? user) async {
    // Small delay to ensure GetMaterialApp is ready
    await Future.delayed(const Duration(seconds: 1));
    
    if (user == null) {
      Get.offAll(() => const Onboard());
      return;
    }

    try {
      final response = await sb.Supabase.instance.client
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .single();

      final isAdmin = response['is_admin'] == true;

      if (isAdmin) {
        Get.offAll(() => AdminDashboardScreen());
      } else {
        Get.offAll(() => MainBottomNavBar());
      }
    } catch (e) {
      print("Error checking admin status: $e");
      Get.offAll(() => MainBottomNavBar());
    }
  }

  Future<void> passwordResetEmail(String email) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _auth.resetPasswordForEmail(email);

      Get.back();

      Loaders.successSnackBar(
        title: 'Email Sent',
        message: "Instructions to reset your password have been sent to your email.",
      );

      Get.to(() => ResetPasswordScreen(email: email));
    } on sb.AuthException catch (e) {
      Get.back();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.message);
    } catch (e) {
      Get.back();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> resendPasswordResetEmail(String email) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _auth.resetPasswordForEmail(email);

      Get.back();

      Loaders.successSnackBar(
        title: 'Email Sent',
        message: "Instructions to reset your password have been sent to your email.",
      );
    } on sb.AuthException catch (e) {
      Get.back();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.message);
    } catch (e) {
      Get.back();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _auth.signInWithPassword(email: email, password: password);

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.user != null) {
        AuthService.instance.deviceStorage.write('isLoggedIn', true);
        Loaders.successSnackBar(
          title: 'Login Successful',
          message: "You have successfully logged in!",
        );
      }
    } on sb.AuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Loaders.errorSnackBar(title: 'Oh Snap', message: e.message);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Loaders.errorSnackBar(
        title: 'Oh Snap',
        message: "An unexpected error occurred. $e",
      );
    }
  }

  Future<void> register(String email, String password, {String? name, String? phoneNumber}) async {
    try {
      Get.dialog(
        Center(child: CircularProgressIndicator(color: DDSilverColors.primary)),
        barrierDismissible: false,
      );

      final response = await _auth.signUp(email: email, password: password);

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.user != null) {
        await sb.Supabase.instance.client.from('profiles').insert({
          'id': response.user!.id,
          'email': email,
          'name': name ?? '',
          'phone_number': phoneNumber ?? '',
        });

        AuthService.instance.deviceStorage.write('isLoggedIn', true);
        Loaders.successSnackBar(
          title: "Account Created!",
          message: "A verification link has been sent to your email. Please verify your account to unlock professional features and complete your profile.",
          duration: 8,
        );

        // Navigate to Login after a short delay so they can read the snackbar
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAll(() => LoginScreen());
        });
      }
    } on sb.AuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      
      String message = e.message;
      if (e.message.contains('429') || e.message.toLowerCase().contains('too many requests')) {
        message = "Too many registration attempts. Please wait a few minutes and try again.";
      }
      
      Loaders.errorSnackBar(title: "Registration Failed", message: message);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Loaders.errorSnackBar(
        title: 'Oh Snap',
        message: "An unexpected error occurred. $e",
      );
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      deviceStorage.remove('isLoggedIn');
      
      Get.delete<UserController>();
      Get.delete<UpdateUserController>();

      Loaders.successSnackBar(
        title: 'Logged Out',
        message: "You have successfully logged out.",
      );
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Oh Snap',
        message: "Error in logged out. Please try again",
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Note: In Supabase, users usually delete their own data via RLS
      // but deleting the Auth user record itself often requires service_role or a custom RPC.
      // For client side, we'll just sign out and remove their profile.
      final userId = _auth.currentUser?.id;
      if (userId != null) {
        await sb.Supabase.instance.client.from('profiles').delete().eq('id', userId);
        await _auth.signOut();
      }
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Oh Snap',
        message: "Error in deleting account. Please try again",
      );
    }
  }
}
