import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/features/shop/models/category_model.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class CategoryService extends GetxController {
  static CategoryService get instance => Get.find();
  static const String categoryImageBucket = 'category_images';

  final _supabase = sb.Supabase.instance.client;

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final List<dynamic> response = await _supabase
          .from('categories')
          .select()
          .order('name', ascending: true);

      return response
          .map((data) => CategoryModel.fromMap(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  Future<List<ProductModel>> getByCategories(String categoryId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('products')
          .select()
          .eq('category_id', categoryId);

      return response
          .map((data) => ProductModel.fromMap(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  Future<String> uploadCategoryImage({
    required String categoryId,
    required XFile image,
  }) async {
    final fileExtension = _getExtension(image.name);
    final storagePath =
        '$categoryId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final imageBytes = await image.readAsBytes();

    await _supabase.storage.from(categoryImageBucket).uploadBinary(
          storagePath,
          imageBytes,
          fileOptions: const sb.FileOptions(upsert: true),
        );

    return _supabase.storage.from(categoryImageBucket).getPublicUrl(storagePath);
  }

  Future<void> deleteCategoryImage(String imageUrl) async {
    final imagePath = _extractCategoryImagePath(imageUrl);
    if (imagePath == null || imagePath.isEmpty) return;

    await _supabase.storage.from(categoryImageBucket).remove([imagePath]);
  }

  Future<void> createCategory(CategoryModel category) async {
    await _supabase.from('categories').insert({
      'id': category.id,
      ...category.toMap(),
    });
  }

  Future<void> updateCategory(String categoryId, CategoryModel category) async {
    await _supabase
        .from('categories')
        .update(category.toMap())
        .eq('id', categoryId);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _supabase.from('categories').delete().eq('id', categoryId);
  }

  Future<int> countProductsForCategory(String categoryId) async {
    final List<dynamic> response = await _supabase
        .from('products')
        .select('id')
        .eq('category_id', categoryId);
    return response.length;
  }

  Future<int> countChildCategories(String categoryId) async {
    return 0;
  }

  String? _extractCategoryImagePath(String imageUrl) {
    final bucketPrefix = '$categoryImageBucket/';
    final bucketIndex = imageUrl.indexOf(bucketPrefix);

    if (bucketIndex == -1) return null;

    return imageUrl.substring(bucketIndex + bucketPrefix.length);
  }

  String _getExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return 'jpg';
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }
}
