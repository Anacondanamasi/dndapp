import 'package:get/get.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class MyCartController extends GetxController {
  final _supabase = sb.Supabase.instance.client;
  sb.RealtimeChannel? _cartChannel;

  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToCartChanges();
  }

  @override
  void onClose() {
    if (_cartChannel != null) {
      _supabase.removeChannel(_cartChannel!);
    }
    super.onClose();
  }

  void _listenToCartChanges() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    fetchCart();

    _cartChannel = _supabase
        .channel('public:cart_items')
        .onPostgresChanges(
          event: sb.PostgresChangeEvent.all,
          schema: 'public',
          table: 'cart_items',
          filter: sb.PostgresChangeFilter(
            type: sb.PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => fetchCart(),
        )
        .subscribe();
  }

  Future<void> fetchCart() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final List<dynamic> response = await _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> items = [];

      for (final row in response) {
        final product = row['products'];
        if (product != null) {
          items.add({
            'cartId': row['id'],
            'productId': row['product_id'],
            'name': product['name'] ?? '',
            'price': product['price'] ?? 0,
            'imageUrl': (product['image_urls'] != null &&
                    (product['image_urls'] as List).isNotEmpty)
                ? product['image_urls'][0]
                : '',
            'size': row['size'] ?? '',
            'quantity': int.tryParse(row['quantity'].toString()) ?? 1,
          });
        }
      }

      cartItems.assignAll(items);
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .maybeSingle();

      if (response == null) {
        Loaders.warningSnackBar(
          title: 'Product unavailable',
          message: 'This product could not be opened right now.',
        );
        return null;
      }

      return ProductModel.fromMap(Map<String, dynamic>.from(response));
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to open this product: $e',
      );
      return null;
    }
  }

  Future<void> removeFromCart(dynamic cartId) async {
    await _supabase.from('cart_items').delete().eq('id', cartId);
    await fetchCart();
  }

  Future<void> updateQuantity(dynamic cartId, int newQuantity) async {
    if (newQuantity >= 1 && newQuantity <= 5) {
      await _supabase
          .from('cart_items')
          .update({'quantity': newQuantity}).eq('id', cartId);
      await fetchCart();
    }
  }
}
