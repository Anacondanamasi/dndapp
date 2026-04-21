import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class OrderSummaryController extends GetxController {
  final List<Map<String, dynamic>>? cartItems;
  final Map<String, dynamic>? singleProduct;

  OrderSummaryController({
    this.cartItems,
    this.singleProduct,
  });

  final _supabase = sb.Supabase.instance.client;

  // Non-observable list used for rendering in the UI
  List<Map<String, dynamic>> orderItems = [];

  final RxDouble subtotal = 0.0.obs;
  final RxDouble deliveryFee = 30.0.obs;
  final RxDouble total = 0.0.obs;
  final RxBool isLoading = true.obs;
  final RxString userAddress = ''.obs;

  final TextEditingController addressController = TextEditingController();

  sb.RealtimeChannel? _cartSub;

  @override
  void onInit() {
    super.onInit();
    _initialize();
    _loadUserAddress();
  }

  @override
  void onClose() {
    if (_cartSub != null) _supabase.removeChannel(_cartSub!);
    addressController.dispose();
    super.onClose();
  }

  void _initialize() {
    isLoading.value = true;

    // If a single product was passed (Buy Now), show only that product.
    if (singleProduct != null) {
      orderItems = [Map<String, dynamic>.from(singleProduct!)];
      _calculateTotals();
      isLoading.value = false;
      return;
    }

    // If cartItems were explicitly passed (optional), use them as initial snapshot,
    // but still prefer a live listener to keep it in sync with Firestore.
    if (cartItems != null && cartItems!.isNotEmpty) {
      orderItems = List<Map<String, dynamic>>.from(cartItems!);
      _calculateTotals();
      // continue to attach a listener so it updates live
    }

    // Attach real-time listener to user's cart to keep orderItems up to date
    final user = _supabase.auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    _fetchCartItems();

    _cartSub = _supabase
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
          callback: (payload) => _fetchCartItems(),
        )
        .subscribe();
  }

  Future<void> _fetchCartItems() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final List<dynamic> response = await _supabase
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> items = [];

      for (var row in response) {
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

      orderItems = items;
      _calculateTotals();
    } catch (e) {
      print('Error fetching cart: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> _loadUserAddress() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      userAddress.value = 'Please login to see your address';
      addressController.text = userAddress.value;
      return;
    }

    try {
      final userData = await _supabase.from('profiles').select().eq('id', user.id).single();

      if (userData != null) {
        String address = '';

        if (userData['address'] != null &&
            userData['address'].toString().trim().isNotEmpty) {
          address = userData['address'].toString();
        } else {
          final List<String> parts = [];
          if (userData['city'] != null && userData['city'].toString().isNotEmpty) {
            parts.add(userData['city'].toString());
          }
          if (userData['state'] != null &&
              userData['state'].toString().isNotEmpty) {
            parts.add(userData['state'].toString());
          }
          if (userData['pincode'] != null &&
              userData['pincode'].toString().isNotEmpty) {
            parts.add(userData['pincode'].toString());
          }
          if (userData['country'] != null &&
              userData['country'].toString().isNotEmpty) {
            parts.add(userData['country'].toString());
          }
          address = parts.isNotEmpty ? parts.join(', ') : '123, Main Street, Ahmedabad';
        }

        userAddress.value = address;
        addressController.text = address;
      } else {
        userAddress.value = '123, Main Street, Ahmedabad';
        addressController.text = userAddress.value;
      }
    } catch (e) {
      print('Error loading address: $e');
      userAddress.value = '123, Main Street, Ahmedabad';
      addressController.text = userAddress.value;
    }
  }

  void _calculateTotals() {
    double sum = 0.0;

    for (var item in orderItems) {
      // Price normalization
      double priceDouble = 0.0;
      try {
        final priceVal = item['price'];
        if (priceVal is int) priceDouble = priceVal.toDouble();
        else if (priceVal is double) priceDouble = priceVal;
        else if (priceVal is String) priceDouble = double.tryParse(priceVal) ?? 0.0;
        else priceDouble = 0.0;
      } catch (_) {
        priceDouble = 0.0;
      }

      // Quantity normalization
      int qty = 1;
      try {
        final q = item['quantity'];
        if (q is int) qty = q;
        else if (q is String) qty = int.tryParse(q) ?? 1;
        else if (q is double) qty = q.toInt();
      } catch (_) {
        qty = 1;
      }

      sum += priceDouble * qty;
    }

    subtotal.value = sum;
    total.value = subtotal.value + deliveryFee.value;
  }

  // Optional: update address in Supabase
  Future<void> updateAddress(String newAddress) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('profiles').update({
        'address': newAddress,
      }).eq('id', user.id);
      userAddress.value = newAddress;
    } catch (e) {
      print('Error updating address: $e');
    }
  }
}
