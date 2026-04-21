import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:jewello/data/services/product_service.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/features/products/models/review_model.dart';
import 'package:jewello/utils/loaders.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();
  final productService = Get.put(ProductService());


  final _supabase = sb.Supabase.instance.client;
  
  // Observables
  final Rx<ProductModel?> product = Rx<ProductModel?>(null);
  RxList<ProductModel> featuredProduct = <ProductModel>[].obs;
  RxList<ProductModel> trendingProducts = <ProductModel>[].obs;
  RxList<ProductModel> newArrivals = <ProductModel>[].obs;
  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingReviews = false.obs;
  final RxBool isFavorite = false.obs;
  final RxString selectedSize = ''.obs;
  final RxInt quantity = 1.obs;
  final RxInt currentImageIndex = 0.obs;
  
  String? productId;
  String? userId; // Current logged-in user ID

  @override
  void onInit() {
    super.onInit();
    fetchFeaturedProducts();
    fetchTrendingProducts();
    fetchNewArrivals();
    // Get product ID from arguments
    if (Get.arguments != null) {
      productId = Get.arguments['ProductId'];
      userId = Get.arguments['UserId'];
    }
    if (productId != null) {
      fetchProductDetails();
      checkIfFavorite();
    }
  }

  /// Fetch Featured product details
  Future<void> fetchFeaturedProducts() async {
    try {
      isLoading.value = true;
      final products = await productService.getFeaturedProducts();
      featuredProduct.assignAll(products);
    } catch (e) {
      print('Error fetching featured product: $e');
      Loaders.errorSnackBar(title: 'Oh Snap', message: "Failed to load product: $e");
    } finally {
      isLoading.value = false;  
    }
  }

  /// Fetch trending product details
  Future<void> fetchTrendingProducts() async {
    try {
      isLoading.value = true;
      final products = await productService.getTrendingProducts();
      trendingProducts.assignAll(products);
    } catch (e) {
      print('Error fetching trending product: $e');
      Loaders.errorSnackBar(title: 'Oh Snap', message: "Failed to load product: $e");
    } finally {
      isLoading.value = false;  
    }
  }

   /// Fetch new arrivals details
  Future<void> fetchNewArrivals() async {
    try {
      isLoading.value = true;
      final products = await productService.getNewArrivals();
      newArrivals.assignAll(products);
    } catch (e) {
      print('Error fetching new arrivals: $e');
      Loaders.errorSnackBar(title: 'Oh Snap', message: "Failed to load product: $e");
    } finally {
      isLoading.value = false;  
    }
  }

  // Fetch product details from Supabase
  Future<void> fetchProductDetails() async {
    try {
      isLoading.value = true;
      
      final data = await _supabase.from('products').select().eq('id', productId!).single();
      
      if (data != null) {
        product.value = ProductModel.fromMap(data);
        
        // Set default selected size
        if (product.value!.availableSizes.isNotEmpty) {
          selectedSize.value = product.value!.availableSizes.first;
        }
        
        // Fetch reviews after product is loaded
        fetchReviews();
      } else {
        Loaders.errorSnackBar(title: 'Oh Snap', message: "Product not found");
      }
    } catch (e) {
      print('Error fetching product detail: $e');
      Loaders.errorSnackBar(title: 'Oh Snap', message: "Failed to load product: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch product reviews from Supabase with joins
  Future<void> fetchReviews() async {
    try {
      isLoadingReviews.value = true;
      
      final List<dynamic> response = await _supabase
        .from('reviews')
        .select('*, profiles(name, profile_picture)')
        .eq('product_id', productId!)
        .order('created_at', ascending: false)
        .limit(10);
      
      reviews.value = response
          .map((data) {
            final profile = data['profiles'];
            return ReviewModel.fromMap({
              ...data,
              'user_name': profile?['name'],
              'profile_picture': profile?['profile_picture'],
            });
          })
          .toList();
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap', message: "Failed fetching reviews: $e");
      print('Error fetching reviews: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  // Check if product is in favorites
  Future<void> checkIfFavorite() async {
    if (userId == null || productId == null) return;
    
    try {
      final response = await _supabase
          .from('wishlist_items')
          .select()
          .eq('user_id', userId!)
          .eq('product_id', productId!)
          .maybeSingle();
      
      isFavorite.value = response != null;
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap', message: "Error checking favorite: $e");
      print('Error checking favorite: $e');
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite() async {
    if (userId == null || productId == null) {
      Loaders.errorSnackBar(title: 'Login required', message: 'Please login to add favorites');
      return;
    }
    
    try {
      if (isFavorite.value) {
        await _supabase
            .from('wishlist_items')
            .delete()
            .eq('user_id', userId!)
            .eq('product_id', productId!);
        isFavorite.value = false;
        Loaders.successSnackBar(title: 'Removed', message: "Product removed from favorites");

      } else {
        await _supabase.from('wishlist_items').insert({
          'user_id': userId,
          'product_id': productId,
        });
        isFavorite.value = true;
        Loaders.successSnackBar(title: 'Added', message: "Product added to favorites.");
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap', message: "Failed to update favorites: $e");
      print("Failed to update favorites: $e");
    }
  }

  // Add to cart
  Future<void> addToCart() async {
    if (userId == null) {
      Loaders.errorSnackBar(title: 'Login required', message: 'Please login to add items to cart');
      return;
    }

    if (selectedSize.value.isEmpty) {
      Loaders.errorSnackBar(title: 'Size Required', message: "Please select a size");
      return;
    }

    try {
      await _supabase.from('cart_items').upsert({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity.value,
        'size': selectedSize.value,
      }, onConflict: 'user_id, product_id, size');
      
      Loaders.successSnackBar(title: 'Added', message: "Added to cart");

    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap!', message: "Failed to add to cart: $e");
      print("Failed to add to cart: $e");
    }
  }

  // Buy now - Add to cart and navigate to checkout
  Future<void> buyNow() async {
    await addToCart();
    // Navigate to cart/checkout page
    Get.toNamed('/cart'); // Adjust route name as needed
  }

  // Update quantity
  void updateQuantity(int value) {
    if (value >= 1 && value <= (product.value?.stockQuantity ?? 0)) {
      quantity.value = value;
    }
  }

  void incrementQuantity() {
    if (quantity.value < (product.value?.stockQuantity ?? 0)) {
      quantity.value++;
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  // Select size
  void selectSize(String size) {
    selectedSize.value = size;
  }

  // Update image index for carousel
  void updateImageIndex(int index) {
    currentImageIndex.value = index;
  }

 

  // Refresh all data
  Future<void> refreshData() async {
    await fetchProductDetails();
  }
}
