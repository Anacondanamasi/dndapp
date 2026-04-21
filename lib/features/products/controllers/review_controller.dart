import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/utils/loaders.dart';

class ReviewController extends GetxController{
  static ReviewController get instance => Get.find();

  final _supabase = sb.Supabase.instance.client;

  // Observables
  final RxBool isLoadingReviews = false.obs;
  String? productId;
  String? userId; // Current logged-in user ID
  
  /// Submit review
  Future<void> submitReview({ required String rating, required String comment}) async {
    if (userId == null) {
      Loaders.errorSnackBar(title: 'Login Required', message: "Please login to submit a review");
      return;
    }

    try {
      final existingReview = await _supabase
          .from('reviews')
          .select()
          .eq('user_id', userId!)
          .eq('product_id', productId!)
          .limit(1);

      if((existingReview as List).isNotEmpty){
        Loaders.errorSnackBar(title: 'Review Exists', message: "You have already submitted a review for this product");
        return;
      }

      isLoadingReviews(true);
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final userData = await _supabase.from('profiles').select().eq('id', userId!).single();

      // Add review to Supabase
      await _supabase.from('reviews').insert({
        'product_id': productId,
        'user_id': userId,
        'user_name': userData['name'], // Fetch from user profile
        'profile_picture': userData['profile_picture'], // Fetch from user profile
        'rating': double.parse(rating),
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update product rating and review count
      await updateProductRating(double.parse(rating));
      Get.back();
      Loaders.successSnackBar(title: 'Success', message: 'Review submitted successfully');

    } catch (e) {
      Get.back();
      Loaders.errorSnackBar(title: 'Oh Snap', message: "Failed to submit review: $e");

    } finally {
      isLoadingReviews(false);
    }
  }

  /// Update product rating (avg, total count)
  Future<void> updateProductRating(double newRating) async {
    try {
      final productData = await _supabase.from('products').select().eq('id', productId!).single();
      
      double currentRating = (productData['rating'] ?? 0.0).toDouble();
      int currentReviewCount = productData['review_count'] ?? 0;
      
      int newReviewCount = currentReviewCount + 1;
      double updatedRating = 
          ((currentRating * currentReviewCount) + newRating) / newReviewCount;
      
      await _supabase.from('products').update({
        'rating': double.parse(updatedRating.toStringAsFixed(1)),
        'review_count': newReviewCount,
      }).eq('id', productId!);
      
    } catch (e) {
      print('Error updating product rating: $e');
    }
  }


}
