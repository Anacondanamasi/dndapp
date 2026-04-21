import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentController extends GetxController {
  final _supabase = sb.Supabase.instance.client;

  final RxBool isProcessing = false.obs;
  final RxString selectedMethod = "RozerPay".obs;

  late Razorpay razorpay;

  @override
  void onInit() {
    super.onInit();
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handleSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handleError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  void selectPaymentMethod(String method) {
    selectedMethod.value = method;
  }

  void openRazorPay(double amount) {
    var options = {
      'key': 'rzp_test_Rk1guSJ8F3s74e', // Replace with your Razorpay Key ID
      'amount': (amount * 100).toInt(),
      'name': 'Jewello Store',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9409463081',
        'email': 'rushisorathiya3@gmail.com',
      },
    };

    razorpay.open(options);
  }

  String? _pendingOrderId;
  List<Map<String, dynamic>>? _pendingItems;
  double? _pendingOrderAmount;
  double? _pendingShipping;
  double? _pendingTotal;

  // Razorpay Success Handler
  void handleSuccess(PaymentSuccessResponse response) async {
    if (_pendingOrderId != null) {
      await _saveOrderAfterPayment();
    }
  }

  void handleError(PaymentFailureResponse response) {
    Get.snackbar("Payment Failed", "Try again");
  }

  void handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> _saveOrderAfterPayment() async {
    await _supabase.from("orders").update({
      "payment_method": "RozerPay",
      "order_status": "Paid",
    }).eq("order_id", _pendingOrderId!);

    Get.toNamed("/orderPlaced", arguments: _pendingOrderId);

    _pendingOrderId = null;
  }

  Future<String?> placeOrder({
    required List<Map<String, dynamic>> orderItems,
    required double orderAmount,
    required double shippingFee,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      isProcessing.value = true;
      final user = _supabase.auth.currentUser;

      if (user == null) {
        Get.snackbar('Error', 'Please login to place order');
        return null;
      }

      final userData = await _supabase.from('profiles').select().eq('id', user.id).single();

      if (userData == null) {
        Get.snackbar('Error', 'User data not found');
        return null;
      }

      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      String address = userData['address'] ?? '';
      if (address.isEmpty) {
        final List<String> parts = [];
        if (userData['city'] != null) parts.add(userData['city']);
        if (userData['state'] != null) parts.add(userData['state']);
        if (userData['pincode'] != null) parts.add(userData['pincode']);
        if (userData['country'] != null) parts.add(userData['country']);
        address = parts.isNotEmpty
            ? parts.join(', ')
            : '123, Main Street, Ahmedabad';
      }

      final orderData = {
        'order_id': orderId,
        'user_id': user.id,
        'delivery_address': address,
        'items': orderItems
            .map(
              (item) => {
                'ProductId': item['productId'] ?? '',
                'ProductName': item['name'] ?? '',
                'Price': item['price'] ?? 0,
                'Quantity': item['quantity'] ?? 1,
                'Size': item['size'] ?? '',
                'ImageUrl': item['imageUrl'] ?? '',
              },
            )
            .toList(),
        'order_amount': orderAmount,
        'shipping_fee': shippingFee,
        'total_amount': totalAmount,
        'payment_method': paymentMethod,
        'order_status': paymentMethod == "RozerPay"
            ? "Pending Payment"
            : "Pending",
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('orders').insert(orderData);

      // Clear cart if order was from cart (not Buy Now)
      if (orderItems.any((item) => item['cartId'] != null)) {
        await _clearCart(user.id);
      }
      Get.snackbar('Success', 'Order placed successfully!');

      // Razorpay Process
      if (paymentMethod == "RozerPay") {
        _pendingOrderId = orderId;
        _pendingItems = orderItems;
        _pendingOrderAmount = orderAmount;
        _pendingShipping = shippingFee;
        _pendingTotal = totalAmount;

        openRazorPay(totalAmount);
        return null;
      }

      return orderId;
    } catch (e) {
      print('Error placing order: $e');
      Get.snackbar('Error', 'Failed to place order: $e');
      return null;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _clearCart(String userId) async {
    try {
      await _supabase.from('cart_items').delete().eq('user_id', userId);
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }
}
