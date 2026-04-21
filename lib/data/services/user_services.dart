import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewello/data/services/auth_service.dart';
import 'package:jewello/features/authentication/models/user_model.dart';
import 'package:jewello/utils/loaders.dart';

class UserServices extends GetxController{
  static UserServices get instance => Get.find();

  final _supabase = sb.Supabase.instance.client;

  /// function to save user record in firestore
  Future<void> saveUserRecord(UserModel user) async {
    try{
      await _supabase.from("profiles").upsert(user.toMap());
    }catch (e){
        Loaders.errorSnackBar(title: "Ohh Snap", message: "Something went wrong: $e");
    }
  }

  /// function to fetch user record based on user id
  Future<UserModel> fetchUserDetails() async {
    try{
      final userId = AuthService.instance.sbUser?.id;
      if (userId == null) return UserModel.empty();

      final data = await _supabase.from("profiles").select().eq('id', userId).single();

      if(data != null){
        return UserModel.fromMap(data);
      }else{
        return UserModel.empty();
      }

    }catch (e){
        Loaders.errorSnackBar(title: "Ohh Snap", message: "Something went wrong: $e");
        return UserModel.empty();
    }
  }


  // /// function to update user record in firestore
  // Future<void> updateUserDetails(UserModel updateUser) async {
  //   try {
  //     await _db.collection("Users").doc(updateUser.id).update(updateUser.toJson());
  //   }catch (e) {
  //     rethrow;
  //   }
  // }

  /// function to update user record in firestore
  Future<void> updateUserDetails(Map<String, dynamic> updateUser) async {
    try {
      final userId = AuthService.instance.sbUser?.id;
      if (userId == null) return;
      
      await _supabase.from("profiles").update(updateUser).eq('id', userId);
    }catch (e) {
        Loaders.errorSnackBar(title: "Ohh Snap", message: "Something went wrong: $e");
    }
  }

  /// Update any single field
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      final userId = AuthService.instance.sbUser?.id;
      if (userId == null) return;

      await _supabase.from("profiles").update(json).eq('id', userId);

      print('update single field');
    }catch (e) {
      print('update single field problem $e');
      Loaders.errorSnackBar(title: "Ohh Snap", message: "Something went wrong: $e");
    }
  }

  /// fucnntion to delete user record
  Future<void> removeUserDetails(String userId) async {
    try {
      await _supabase.from("profiles").delete().eq('id', userId);
    }catch (e){
      Loaders.errorSnackBar(title: "Ohh Snap", message: "Something went wrong: $e");
    }
  }

  /// upload image in firestore
  Future<String> uploadImage(String bucket, XFile image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      final bytes = await image.readAsBytes();
      
      await _supabase.storage.from(bucket).uploadBinary(fileName, bytes);

      final url = _supabase.storage.from(bucket).getPublicUrl(fileName);

      return url;
    } catch (e) {
      Loaders.errorSnackBar(title: "Ohh Snap", message: "Something went wrong: $e");
      return '';
    }
  }
}
