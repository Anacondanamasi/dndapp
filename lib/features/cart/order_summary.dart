import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/cart/controllers/order_summary_controller.dart';
import 'package:jewello/features/cart/payment.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/color_theme.dart';

class OrderSummaryScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? cartItems;
  final Map<String, dynamic>? singleProduct;

  const OrderSummaryScreen({super.key, this.cartItems, this.singleProduct});

  @override
  Widget build(BuildContext context) {
    final controllerTag = DateTime.now().millisecondsSinceEpoch.toString();

    final controller = Get.put(
      OrderSummaryController(
        cartItems: cartItems,
        singleProduct: singleProduct,
      ),
      tag: controllerTag,
    );

    return Scaffold(
      appBar: AppBarThemeStyle(title: 'Order Summary'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orderItems.isEmpty) {
          return const Center(child: Text('No items to show'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.orderItems.length,
                itemBuilder: (context, index) {
                  final item = controller.orderItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            item['imageUrl'] ?? '',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade100,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text("Size ${item['size']}"),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text("Qty ${item['quantity']}"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Text(
                            "₹${item['price']}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              const Divider(),

              const Text(
                "Order Payment Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              _paymentRow(
                "Order Amount",
                "₹ ${controller.subtotal.value.toStringAsFixed(2)}",
              ),

              _paymentRow(
                "Delivery Fee",
                "₹ ${controller.deliveryFee.value.toStringAsFixed(2)}",
              ),

              _paymentRow(
                "Order Total",
                "₹ ${controller.total.value.toStringAsFixed(2)}",
                bold: true,
              ),
            ],
          ),
        );
      }),

      bottomNavigationBar: Obx(
        () => Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹ ${controller.total.value.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: DDSilverColors.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        orderItems: controller.orderItems,
                        orderAmount: controller.subtotal.value,
                        shippingFee: controller.deliveryFee.value,
                        totalAmount: controller.total.value,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
