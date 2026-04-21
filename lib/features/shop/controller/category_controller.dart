import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/data/services/category_service.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/features/shop/models/category_model.dart';
import 'package:jewello/utils/loaders.dart';

class CategoryController extends GetxController{
  static CategoryController get instance => Get.find();

  final isLoading = false.obs;
  final categoryIsLoading = false.obs;

  final _categoryService = Get.put(CategoryService());
  RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> featuredCategories = <CategoryModel>[].obs;
  RxList<ProductModel> fromCategory = <ProductModel>[].obs;


  // bool _dialogOpen = false;

  /// Load category data
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCategories();
    });

  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;

      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final categories = await _categoryService.getAllCategories();
      allCategories.assignAll(categories);

      featuredCategories.assignAll(
        allCategories.where((category) => category.isFeatured && category.parentId.isEmpty).toList()
      );

      Get.back();

      isLoading.value = false;

    } catch (e) {
      Get.back();
      isLoading.value = false;

      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      // Close loading dialog
      Get.back();
      isLoading.value = false;

    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    try {
      categoryIsLoading.value = true;

      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final categories = await _categoryService.getByCategories(categoryId);
      fromCategory.assignAll(categories);

      Get.back();

      categoryIsLoading.value = false;

    } catch (e) {
      Get.back();
      categoryIsLoading.value = false;
      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
      categoryIsLoading.value = false;
    }
  }
}
