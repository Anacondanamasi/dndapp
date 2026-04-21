import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewello/data/services/category_service.dart';
import 'package:jewello/features/shop/models/category_model.dart';
import 'package:jewello/utils/loaders.dart';

class AdminCategoryController extends GetxController {
  static AdminCategoryController get instance => Get.find();

  final _categoryService = Get.put(CategoryService());
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isImageUploading = false.obs;
  
  // Create Category State
  final nameController = TextEditingController();
  final parentId = ''.obs;
  final isFeatured = false.obs;
  final isActive = true.obs;
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  /// Pick Image
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      Loaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  /// Save Category
  Future<void> createCategory() async {
    try {
      // Start Loading
      isLoading.value = true;

      // Check validation
      if (nameController.text.trim().isEmpty) {
        Loaders.errorSnackBar(
            title: 'Error', message: 'Please enter category name');
        return;
      }

      if (selectedImage.value == null) {
        Loaders.errorSnackBar(
            title: 'Error', message: 'Please select an image');
        return;
      }

      // Generate ID
      final String id = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload Image
      isImageUploading.value = true;
      final String imageUrl = await _categoryService.uploadCategoryImage(
          categoryId: id, image: selectedImage.value!);
      isImageUploading.value = false;

      // Map Data
      final newCategory = CategoryModel(
        id: id,
        name: nameController.text.trim(),
        image: imageUrl,
        isFeatured: isFeatured.value,
        parentId: parentId.value,
        isActive: isActive.value,
      );

      // Save to Supabase
      await _categoryService.createCategory(newCategory);

      // UI Details
      Loaders.successSnackBar(
          title: 'Success', message: 'Category created successfully!');

      // Reset
      _resetFields();

      // Close Page
      Get.back();
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    } finally {
      isLoading.value = false;
      isImageUploading.value = false;
    }
  }

  /// Update Category
  Future<void> updateCategory(CategoryModel oldCategory) async {
    try {
      isLoading.value = true;

      if (nameController.text.trim().isEmpty) {
        Loaders.errorSnackBar(
            title: 'Error', message: 'Please enter category name');
        return;
      }

      String imageUrl = oldCategory.image;

      // If new image selected, upload and delete old one
      if (selectedImage.value != null) {
        isImageUploading.value = true;
        
        // Delete old image
        await _categoryService.deleteCategoryImage(oldCategory.image);
        
        // Upload new image
        imageUrl = await _categoryService.uploadCategoryImage(
            categoryId: oldCategory.id, image: selectedImage.value!);
        
        isImageUploading.value = false;
      }

      final updatedCategory = CategoryModel(
        id: oldCategory.id,
        name: nameController.text.trim(),
        image: imageUrl,
        isFeatured: isFeatured.value,
        parentId: parentId.value,
        isActive: isActive.value,
      );

      await _categoryService.updateCategory(oldCategory.id, updatedCategory);

      Loaders.successSnackBar(
          title: 'Success', message: 'Category updated successfully!');
      
      _resetFields();
      Get.back(result: true);
    } catch (e) {
      Loaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoading.value = false;
      isImageUploading.value = false;
    }
  }

  /// Delete Category
  Future<void> deleteCategory(CategoryModel category) async {
    try {
      // Show confirmation
      Get.defaultDialog(
        title: 'Delete Category',
        middleText: 'Are you sure you want to delete ${category.name}?',
        onConfirm: () async {
          Get.back(); // close dialog
          
          isLoading.value = true;
          
          // Delete Image
          await _categoryService.deleteCategoryImage(category.image);
          
          // Delete from DB
          await _categoryService.deleteCategory(category.id);
          
          Loaders.successSnackBar(title: 'Deleted', message: 'Category removed successfully');
          isLoading.value = false;
        },
        onCancel: () => Get.back(),
      );
    } catch (e) {
      isLoading.value = false;
      Loaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void _resetFields() {
    nameController.clear();
    parentId.value = '';
    isFeatured.value = false;
    isActive.value = true;
    selectedImage.value = null;
  }
}
