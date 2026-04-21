import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:get/get.dart';
import 'package:jewello/features/products/models/review_model.dart';

class ReviewService extends GetxController {
  static ReviewService get instance => Get.find();

  /// Variables
  final _supabase = sb.Supabase.instance.client;

  /// Fetch reviews of product from Supabase
  Future<List<ReviewModel>> getReviews(String productId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('reviews')
          .select()
          .eq('product_id', productId)
          .limit(4);

      return response.map((data) => ReviewModel.fromMap(data)).toList();
    } catch (e) {
      throw 'Error fetching reviews: $e';
    }
  }

}
