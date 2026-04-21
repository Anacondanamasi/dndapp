import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AllOrdersController extends GetxController {
  final _supabase = sb.Supabase.instance.client;

  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;

      // Fetch all orders from Supabase with user profile details
      final List<dynamic> response = await _supabase
          .from('orders')
          .select('*, profiles(name, email, phone_number)')
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> fetchedOrders = [];

      for (var data in response) {
        final profile = data['profiles'];
        
        fetchedOrders.add({
          'orderId': data['order_id'] ?? '',
          'userId': data['user_id'] ?? '',
          'userName': profile?['name'] ?? 'Unknown User',
          'userEmail': profile?['email'] ?? 'N/A',
          'userPhone': profile?['phone_number'] ?? 'N/A',
          'items': data['items'] ?? [],
          'orderAmount': (data['order_amount'] ?? 0).toDouble(),
          'shippingFee': (data['shipping_fee'] ?? 0).toDouble(),
          'totalAmount': (data['total_amount'] ?? 0).toDouble(),
          'paymentMethod': data['payment_method'] ?? '',
          'orderStatus': data['order_status'] ?? 'Pending',
          'createdAt': data['created_at'],
          'deliveryAddress': data['delivery_address'] ?? '',
        });
      }

      orders.value = fetchedOrders;
    } catch (e) {
      print('Error fetching orders: $e');
      Get.snackbar('Error', 'Failed to load orders');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedFilter.value == 'All') {
      return orders;
    }
    return orders
        .where((order) => order['orderStatus'] == selectedFilter.value)
        .toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> updateOrderStatus(
    String orderId,
    String userId,
    String newStatus,
  ) async {
    try {
      // Update in orders table
      await _supabase
          .from('orders')
          .update({'order_status': newStatus})
          .eq('order_id', orderId);

      // Update local list
      final index = orders.indexWhere((order) => order['orderId'] == orderId);
      if (index != -1) {
        orders[index]['orderStatus'] = newStatus;
        orders.refresh();
      }

      Get.snackbar('Success', 'Order status updated to $newStatus');
    } catch (e) {
      print('Error updating order status: $e');
      Get.snackbar('Error', 'Failed to update order status');
    }
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
