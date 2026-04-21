import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/admin/add_category.dart';
import 'package:jewello/admin/update_category.dart';
import 'package:jewello/admin/admin_category_controller.dart';
import 'package:jewello/features/shop/controller/category_controller.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/color_theme.dart';

class AllCategoryScreen extends StatelessWidget {
  const AllCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared controllers
    final categoryController = Get.put(CategoryController());
    final adminController = Get.put(AdminCategoryController());

    return Scaffold(
      appBar: AppBarThemeStyle(title: 'All Categories'),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton.extended(
          backgroundColor: DDSilverColors.primary,
          onPressed: () async {
             await Get.to(() => const AddCategoryScreen());
             categoryController.fetchCategories(); // Refresh list
          },
          label: const Text('ADD CATEGORY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (categoryController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (categoryController.allCategories.isEmpty) {
          return const Center(
            child: Text(
              'No categories found.\nAdd your first category!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => categoryController.fetchCategories(),
          child: GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemCount: categoryController.allCategories.length,
            itemBuilder: (context, index) {
              final category = categoryController.allCategories[index];

              return GestureDetector(
                onTap: () async {
                  final result = await Get.to(() => UpdateCategoryScreen(category: category));
                  if (result == true) {
                    categoryController.fetchCategories(); // Refresh list on update
                  }
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                              child: Hero(
                                tag: 'cat_${category.id}',
                                child: Image.network(
                                  category.image,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Center(child: Icon(Icons.category_outlined, size: 40, color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    await adminController.deleteCategory(category);
                                    categoryController.fetchCategories();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: category.isFeatured 
                                  ? DDSilverColors.primary.withOpacity(0.12)
                                  : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category.isFeatured ? 'Featured' : 'Standard',
                                style: TextStyle(
                                  color: category.isFeatured ? DDSilverColors.primary : Colors.grey.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
