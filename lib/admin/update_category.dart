import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/admin/admin_category_controller.dart';
import 'package:jewello/features/shop/models/category_model.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/color_theme.dart';

class UpdateCategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const UpdateCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<UpdateCategoryScreen> createState() => _UpdateCategoryScreenState();
}

class _UpdateCategoryScreenState extends State<UpdateCategoryScreen> {
  final controller = Get.put(AdminCategoryController());

  @override
  void initState() {
    super.initState();
    // Initialize controller with current category data
    controller.nameController.text = widget.category.name;
    controller.isFeatured.value = widget.category.isFeatured;
    controller.isActive.value = widget.category.isActive;
    controller.selectedImage.value = null; // Clear any previously selected image
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: 'Update Category'),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Selection
                    GestureDetector(
                      onTap: () => controller.pickImage(),
                      child: Center(
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: controller.selectedImage.value != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    File(controller.selectedImage.value!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    widget.category.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Replace Image', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(child: Text('Tap to change image', style: TextStyle(color: Colors.grey, fontSize: 12))),
                    const SizedBox(height: 30),

                    // Category Name
                    const Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controller.nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter category name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Featured Checkbox
                    Row(
                      children: [
                        Obx(() => Checkbox(
                          value: controller.isFeatured.value,
                          onChanged: (val) => controller.isFeatured.value = val ?? false,
                          activeColor: DDSilverColors.primary,
                        )),
                        const Text('Is Featured Category'),
                      ],
                    ),
                    
                    // Active Checkbox
                    Row(
                      children: [
                        Obx(() => Checkbox(
                          value: controller.isActive.value,
                          onChanged: (val) => controller.isActive.value = val ?? false,
                          activeColor: DDSilverColors.primary,
                        )),
                        const Text('Is Active Category'),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DDSilverColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => controller.updateCategory(widget.category),
                        child: const Text('UPDATE CATEGORY'),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('CANCEL', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            )),
    );
  }
}
