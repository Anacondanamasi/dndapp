import 'package:get/get.dart';
import 'package:jewello/data/services/review_service.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/features/products/models/review_model.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class ProductDetailsController extends GetxController {
  static ProductDetailsController get instance => Get.find();

  final _supabase = sb.Supabase.instance.client;
  final reviewService = Get.put(ReviewService());

  ProductDetailsController({required this.productId});
  String? productId;

  final Rx<ProductModel?> product = Rx<ProductModel?>(null);
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedSize = ''.obs;
  final RxString quantity = '1'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      isLoading.value = true;
      final review = await reviewService.getReviews(productId!);
      reviews.assignAll(review);
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Error',
        message: 'Failed fetching reviews: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addToCart() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      Loaders.errorSnackBar(
        title: 'Login Required',
        message: 'Please login to add items to cart',
      );
      return;
    }

    try {
      final profile = await _supabase
          .from('profiles')
          .select('serial_id')
          .eq('id', user.id)
          .maybeSingle();

      final int? userSerialId = profile != null ? profile['serial_id'] : null;
      final String finalSize =
          selectedSize.value.isEmpty ? 'Default' : selectedSize.value;
      final int requestedQuantity = int.tryParse(quantity.value) ?? 1;

      final existing = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', user.id)
          .eq('product_id', productId.toString())
          .eq('size', finalSize)
          .maybeSingle();

      if (existing != null) {
        final currentQty = int.tryParse(existing['quantity'].toString()) ?? 0;
        final updatedQuantity = currentQty + requestedQuantity;

        if (updatedQuantity <= 5) {
          await _supabase
              .from('cart_items')
              .update({'quantity': updatedQuantity}).eq('id', existing['id']);
          Loaders.successSnackBar(
            title: 'Updated',
            message: 'Cart quantity updated!',
          );
        } else {
          Loaders.warningSnackBar(
            title: 'Limit Reached',
            message: 'Maximum 5 quantities allowed.',
          );
        }
      } else {
        await _supabase.from('cart_items').insert({
          'user_id': user.id,
          'user_serial_id': userSerialId,
          'product_id': productId.toString(),
          'size': finalSize,
          'quantity': requestedQuantity,
        });
        Loaders.successSnackBar(
          title: 'Added',
          message: 'Product added to cart!',
        );
      }
    } catch (e) {
      print('Add to Cart Error: $e');
      Loaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to add product: $e',
      );
    }
  }

  void selectSize(String size) => selectedSize.value = size;
}
