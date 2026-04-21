import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:get/get.dart';
import 'package:jewello/data/services/product_service.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/utils/loaders.dart';

class HomescreenController extends GetxController {
  final _supabase = sb.Supabase.instance.client;

  final _productService = Get.put(ProductService());

  RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  RxList<ProductModel> trendingProducts = <ProductModel>[].obs;
  RxList<ProductModel> newArrivals = <ProductModel>[].obs;

  final isFeaturedProductsLoading = false.obs;
  final isTrendingLoading = false.obs;
  final isNewArrivalLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedProducts();
    fetchTrendingProducts();
    fetchNewArrivals();
  }

  /// Fetch Featured Products
  Future<void> fetchFeaturedProducts({int limit = 4}) async {
    try {
      isFeaturedProductsLoading.value = true;
      final products = await _productService.getFeaturedProducts(limit: limit);
      featuredProducts.assignAll(products);
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isFeaturedProductsLoading.value = false;
    }
  }

  /// Fetch Trending Products
  Future<void> fetchTrendingProducts({int limit = 4}) async {
    try {
      isTrendingLoading.value = true;
      final products = await _productService.getTrendingProducts(limit: limit);
      trendingProducts.assignAll(products);
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isTrendingLoading.value = false;
    }
  }

  /// Fetch New Arrivals
  Future<void> fetchNewArrivals({int limit = 4}) async {
    try {
      isNewArrivalLoading.value = true;
      final products = await _productService.getNewArrivals(limit: limit);
      newArrivals.assignAll(products);
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isNewArrivalLoading.value = false;
    }
  }
}
