import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class MyOrdersController extends GetxController {
  final _supabase = sb.Supabase.instance.client;

  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      print('DEBUG: Fetching Orders for User: ${user?.id}');

      if (user == null) {
        Get.snackbar('Error', 'Please login to view orders');
        return;
      }

      final List<dynamic> response = await _supabase
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      print('DEBUG: Orders found in DB: ${response.length}');

      orders.value = response.map((data) {
        return {
          'orderId': data['order_id'] ?? '',
          'items': data['items'] ?? [],
          'orderAmount': (data['order_amount'] ?? 0).toDouble(),
          'shippingFee': (data['shipping_fee'] ?? 0).toDouble(),
          'totalAmount': (data['total_amount'] ?? 0).toDouble(),
          'paymentMethod': data['payment_method'] ?? '',
          'orderStatus': data['order_status'] ?? 'Pending',
          'createdAt': data['created_at'],
          'deliveryAddress': data['delivery_address'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      Get.snackbar('Error', 'Failed to load orders');
    } finally {
      isLoading.value = false;
    }
  }

  // Show both Pending and Delivered orders (exclude only Cancelled)
  List<Map<String, dynamic>> get activeOrders {
    return orders
        .where(
          (order) =>
              order['orderStatus'] == 'Pending' ||
              order['orderStatus'] == 'Delivered',
        )
        .toList();
  }

  // Get only pending orders
  List<Map<String, dynamic>> get pendingOrders {
    return orders.where((order) => order['orderStatus'] == 'Pending').toList();
  }

  // Get only delivered orders
  List<Map<String, dynamic>> get deliveredOrders {
    return orders
        .where((order) => order['orderStatus'] == 'Delivered')
        .toList();
  }

  // Get all orders including cancelled
  List<Map<String, dynamic>> get allOrders {
    return orders;
  }

  String getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return '#FFA726'; // Orange
      case 'Delivered':
        return '#66BB6A'; // Green
      case 'Cancelled':
        return '#EF5350'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  String formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';

    try {
      final date = DateTime.parse(timestamp.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      print('Error formatting date: $e');
    }
    return 'N/A';
  }
}
