import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:get/get.dart';
import 'package:jewello/features/products/models/product_model.dart';

class ProductService extends GetxController {
  static ProductService get instance => Get.find();

  /// Variables
  final _supabase = sb.Supabase.instance.client;

  /// Fetch featured products
  Future<List<ProductModel>> getFeaturedProducts({int limit = 4}) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('product_tag', 'featured')
          .limit(limit);

      return (response as List)
          .map((data) => ProductModel.fromMap(data))
          .toList();
    } catch (e) {
      throw 'Error fetching featured products: $e';
    }
  }

  /// Fetch trending products
  Future<List<ProductModel>> getTrendingProducts({int limit = 4}) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('product_tag', 'trending')
          .limit(limit);

      return (response as List)
          .map((data) => ProductModel.fromMap(data))
          .toList();
    } catch (e) {
      throw 'Error fetching trending products: $e';
    }
  }

  /// Fetch new arrivals
  Future<List<ProductModel>> getNewArrivals({int limit = 4}) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('product_tag', 'new_arrival')
          .limit(limit);

      return (response as List)
          .map((data) => ProductModel.fromMap(data))
          .toList();
    } catch (e) {
      throw 'Error fetching new arrivals: $e';
    }
  }

  /// Fetch products by tag (general)
  Future<List<ProductModel>> getProductsByTag(String tag, {int limit = 15}) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('product_tag', tag)
          .limit(limit);

      return (response as List)
          .map((data) => ProductModel.fromMap(data))
          .toList();
    } catch (e) {
      throw 'Error fetching products by tag: $e';
    }
  }

}
