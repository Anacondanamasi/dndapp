import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/admin/add_category.dart';
import 'package:jewello/admin/admin_category_controller.dart';
import 'package:jewello/features/shop/controller/category_controller.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/color_theme.dart';

class AdminCategoryListScreen extends StatelessWidget {
  const AdminCategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We can use the existing CategoryController to display the list
    final categoryController = Get.put(CategoryController());
    final adminController = Get.put(AdminCategoryController());

    return Scaffold(
      appBar: AppBarThemeStyle(title: 'Manage Categories'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: DDSilverColors.primary,
        onPressed: () => Get.to(() => const AddCategoryScreen()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (categoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryController.allCategories.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categoryController.allCategories.length,
          itemBuilder: (context, index) {
            final category = categoryController.allCategories[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    category.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 40),
                  ),
                ),
                title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(category.isFeatured ? 'Featured' : ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => adminController.deleteCategory(category),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
