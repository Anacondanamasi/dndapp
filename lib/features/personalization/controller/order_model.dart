class OrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String deliveryAddress;
  final List<OrderItem> items;
  final double orderAmount;
  final double shippingFee;
  final double totalAmount;
  final String paymentMethod;
  final String orderStatus;
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.deliveryAddress,
    required this.items,
    required this.orderAmount,
    required this.shippingFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'user_phone': userPhone,
      'delivery_address': deliveryAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'order_amount': orderAmount,
      'shipping_fee': shippingFee,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'order_status': orderStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['id']?.toString() ?? map['order_id']?.toString() ?? '',
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? '',
      userEmail: map['user_email'] ?? '',
      userPhone: map['user_phone'] ?? '',
      deliveryAddress: map['delivery_address'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      orderAmount: (map['order_amount'] ?? 0).toDouble(),
      shippingFee: (map['shipping_fee'] ?? 0).toDouble(),
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      paymentMethod: map['payment_method'] ?? '',
      orderStatus: map['status'] ?? map['order_status'] ?? 'Pending',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String size;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.size,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'ProductId': productId,
      'ProductName': productName,
      'Price': price,
      'Quantity': quantity,
      'Size': size,
      'ImageUrl': imageUrl,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['ProductId'] ?? '',
      productName: map['ProductName'] ?? '',
      price: (map['Price'] ?? 0).toDouble(),
      quantity: map['Quantity'] ?? 1,
      size: map['Size'] ?? '',
      imageUrl: map['ImageUrl'] ?? '',
    );
  }
}
