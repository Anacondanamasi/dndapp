import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/cart/order_placed.dart';
import 'package:jewello/features/cart/controllers/payment_controller.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final double orderAmount;
  final double shippingFee;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.orderItems,
    required this.orderAmount,
    required this.shippingFee,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: 'Payment'),
      body: Obx(
        () => controller.isProcessing.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Order",
                            style:
                                TextStyle(fontSize: 25, color: Colors.grey)),
                        Text(
                          "₹ ${widget.orderAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 25, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Shipping",
                            style:
                                TextStyle(fontSize: 25, color: Colors.grey)),
                        Text(
                          "₹ ${widget.shippingFee.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 25, color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    const Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w600)),
                        Text(
                          "₹ ${widget.totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Text("Payment Method",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        controller.selectPaymentMethod("RozerPay");
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                controller.selectedMethod.value == "RozerPay"
                                    ? Colors.red
                                    : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          color: Colors.grey.shade100,
                        ),
                        child: Text(
                          "RozerPay",
                          style: TextStyle(
                            fontSize: 16,
                            color: controller.selectedMethod.value ==
                                    "RozerPay"
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    GestureDetector(
                      onTap: () {
                        controller.selectPaymentMethod("Cash On Delivery");
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                controller.selectedMethod.value ==
                                        "Cash On Delivery"
                                    ? Colors.red
                                    : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          color: Colors.grey.shade200,
                        ),
                        child: Text(
                          "Cash On Delivery",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                controller.selectedMethod.value ==
                                        "Cash On Delivery"
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final orderId = await controller.placeOrder(
                            orderItems: widget.orderItems,
                            orderAmount: widget.orderAmount,
                            shippingFee: widget.shippingFee,
                            totalAmount: widget.totalAmount,
                            paymentMethod: controller.selectedMethod.value,
                          );

                          if (orderId != null &&
                              controller.selectedMethod.value != "RozerPay") {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderPlacedScreen(orderId: orderId),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style:
                              TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
