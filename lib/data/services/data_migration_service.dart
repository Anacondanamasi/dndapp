import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:get/get.dart';

class DataMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _supabase = sb.Supabase.instance.client;

  Future<void> migrateData() async {
    print('DEBUG: Migration Button Clicked!');
    try {
      Get.snackbar('Migration', 'Starting data transfer...', 
        duration: const Duration(seconds: 2));
      print('DEBUG: Snackbar shown, starting Categories...');

      // 1. Migrate Categories
      await _migrateCategories();
      print('DEBUG: Categories Migration Finished');

      // 2. Migrate Products
      print('DEBUG: Starting Products...');
      await _migrateProducts();
      print('DEBUG: Products Migration Finished');

      // 3. Migrate Reviews
      print('DEBUG: Starting Reviews...');
      await _migrateReviews();
      print('DEBUG: Reviews Migration Finished');

      // 4. Migrate Orders
      print('DEBUG: Starting Orders...');
      await _migrateOrders();
      print('DEBUG: Orders Migration Finished');

      print('DEBUG: ALL MIGRATION COMPLETED SUCCESSFULLY!');
      Get.snackbar('Success', 'Data migration completed successfully!');
    } catch (e) {
      print('DEBUG: Migration Error Occurred: $e');
      Get.snackbar('Error', 'Migration failed: $e');
    }
  }

  Future<void> _migrateCategories() async {
    final snapshot = await _firestore.collection('Categories').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      await _supabase.from('categories').upsert({
        'id': doc.id,
        'name': data['Name'] ?? 'Unnamed Category',
        'image_url': data['Image'] ?? '',
        'is_featured': data['IsFeatured'] ?? false,
      });
    }
  }

  Future<void> _migrateProducts() async {
    final snapshot = await _firestore.collection('Products').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final categoryId = data['CategoryId'] ?? '';

      // Skip if categoryId is empty to avoid foreign key violation
      if (categoryId.isEmpty) {
         print('DEBUG: Skipping product ${doc.id} because CategoryId is empty');
         continue;
      }

      await _supabase.from('products').upsert({
        'id': doc.id,
        'name': data['Name'] ?? 'Unnamed Product',
        'description': data['Description'] ?? '',
        'price': (data['Price'] ?? 0).toDouble(),
        'original_price': (data['OriginalPrice'] ?? 0).toDouble(),
        'stock_quantity': data['Stock'] ?? 0,
        'category_id': categoryId, 
        'image_urls': data['Images'] ?? [],
        'is_featured': data['IsFeatured'] ?? false,
        'rating': (data['Rating'] ?? 0.0).toDouble(),
        'review_count': data['ReviewCount'] ?? 0,
        'sold_count': data['SoldCount'] ?? 0,
        'available_sizes': data['Sizes'] ?? [],
      });
    }
  }

  Future<void> _migrateReviews() async {
    final snapshot = await _firestore.collection('Reviews').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final productId = data['ProductId'] ?? '';
      
      // Skip if product_id is empty to avoid foreign key violation
      if (productId.isEmpty) {
        print('DEBUG: Skipping review ${doc.id} because ProductId is empty');
        continue;
      }

      await _supabase.from('reviews').upsert({
        'id': doc.id,
        'product_id': productId,
        'user_id': data['UserId'] ?? '',
        'rating': (data['Rating'] ?? 0).toInt(),
        'comment': data['Comment'] ?? '',
        'user_name': data['UserName'] ?? 'Anonymous',
        'user_image': data['UserImage'] ?? '',
        'created_at': (data['CreatedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _migrateOrders() async {
    final snapshot = await _firestore.collection('Orders').get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      await _supabase.from('orders').upsert({
        'order_id': doc.id,
        'user_id': data['UserId'] ?? '',
        'order_status': data['Status'] ?? 'Pending',
        'total_amount': (data['TotalAmount'] ?? 0).toDouble(),
        'order_amount': (data['OrderAmount'] ?? 0).toDouble(),
        'shipping_fee': (data['ShippingFee'] ?? 0).toDouble(),
        'payment_method': data['PaymentMethod'] ?? 'Unknown',
        'delivery_address': data['Address'] ?? 'N/A',
        'items': data['Items'] ?? [],
        'created_at': (data['CreatedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
      });
    }
  }
}
