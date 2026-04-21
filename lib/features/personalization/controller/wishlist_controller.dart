import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class WishlistController extends GetxController {
  final _supabase = sb.Supabase.instance.client;

  RxList<Map<String, dynamic>> wishlistItems = <Map<String, dynamic>>[].obs;
  RxSet<String> wishlistProductIds = <String>{}.obs;

  /// Load wishlist for current user
  Future<void> loadWishlist() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      wishlistItems.clear();
      wishlistProductIds.clear();
      return;
    }

    final List<dynamic> response = await _supabase
        .from('wishlist_items')
        .select('*, products(*)')
        .eq('user_id', user.id);

    final List<Map<String, dynamic>> items = [];
    final Set<String> ids = {};

    for (var row in response) {
      final product = row['products'];
      if (product != null) {
        items.add({
          'id': row['product_id'],
          'name': product['name'] ?? '',
          'price': (product['price'] as num).toDouble(),
          'imageUrl': (product['image_urls'] != null && (product['image_urls'] as List).isNotEmpty) 
              ? product['image_urls'][0] 
              : '',
        });
        ids.add(row['product_id'].toString());
      }
    }

    wishlistItems.assignAll(items);
    wishlistProductIds.value = ids;
  }

  /// Check if product is already in wishlist
  bool isInWishlist(String productId) => wishlistProductIds.contains(productId);

  /// Toggle wishlist item
  Future<void> toggleWishlistItem(Map<String, dynamic> productData) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      Get.snackbar('Login Required', 'Please login to add items to your wishlist');
      return;
    }

    // Ensure productId is always a String for consistent comparison
    final String productId = productData['id'].toString();

    try {
      if (isInWishlist(productId)) {
        await _supabase
            .from('wishlist_items')
            .delete()
            .eq('user_id', user.id)
            .eq('product_id', productId);
        wishlistProductIds.remove(productId);
      } else {
        // Use upsert to prevent duplicate key errors
        await _supabase.from('wishlist_items').upsert({
          'user_id': user.id,
          'product_id': productId,
        }, onConflict: 'user_id, product_id');
        wishlistProductIds.add(productId);
      }
      wishlistProductIds.refresh();
      await loadWishlist(); 
    } catch (e) {
      print('Wishlist Toggle Error: $e');
    }
  }

  /// Clear wishlist when user logs out
  void clearWishlist() {
    wishlistProductIds.clear();
  }

  /// Watch for auth changes (auto reset on logout)
  @override
  void onInit() {
    super.onInit();
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session?.user == null) {
        clearWishlist();
      } else {
        loadWishlist();
      }
    });
  }
}
