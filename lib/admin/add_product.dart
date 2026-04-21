import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _regularPriceController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _availableSizesController = TextEditingController();

  // State variables
  List<XFile> _selectedImages = [];
  String? _selectedCategoryId;
  bool _isActive = true;
  String _selectedProductTag = 'none';
  String _selectedGender = 'All';
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];

  final List<String> _productTags = ['none', 'new_arrival', 'featured', 'trending'];
  final List<String> _genderOptions = ['All', 'Men', 'Ladies'];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _regularPriceController.dispose();
    _salePriceController.dispose();
    _stockQuantityController.dispose();
    _availableSizesController.dispose();
    super.dispose();
  }

  // Fetch categories from Supabase
  Future<void> _fetchCategories() async {
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('categories')
          .select();

      setState(() {
        _categories = response
            .map((data) {
              return {
                'id': data['id'],
                'name': data['name'] ?? 'Unknown',
              };
            })
            .where((cat) => cat['name'] != 'Unknown')
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error fetching categories: $e')));
    }
  }

  // Pick images
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error picking images: $e')));
    }
  }

  // Upload images to Supabase Storage
  Future<List<String>> _uploadImages(String productId) async {
    List<String> imageUrls = [];
    final supabase = Supabase.instance.client;

    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        String fileName = '${productId}_$i.jpg';
        
        final bytes = await _selectedImages[i].readAsBytes();
        
        await supabase.storage.from('products').uploadBinary(fileName, bytes);
        
        final url = supabase.storage.from('products').getPublicUrl(fileName);
        imageUrls.add(url);
      } catch (e) {
        print('Error uploading image $i: $e');
      }
    }

    return imageUrls;
  }

  // Add product
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Generate unique ID
      final String productId = DateTime.now().millisecondsSinceEpoch.toString();

      // 2. Upload images
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _uploadImages(productId);
      } else {
        imageUrls = [
          "https://images.unsplash.com/photo-1506630448388-4e683c67ddb0?w=800"
        ];
      }

      // Sizes parsing
      List<String> sizes = _availableSizesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Pricing logic
      int regularPrice = int.parse(_regularPriceController.text.trim());
      int displayPrice = regularPrice;

      if (_salePriceController.text.trim().isNotEmpty) {
        try {
          int salePrice = int.parse(_salePriceController.text.trim());
          displayPrice = salePrice;
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid sale price format')));
          setState(() => _isLoading = false);
          return;
        }
      }

      // Product data
      Map<String, dynamic> productData = {
        'id': productId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategoryId,
        'original_price': regularPrice,
        'price': displayPrice,
        'stock_quantity': int.parse(_stockQuantityController.text),
        'available_sizes': sizes,
        'image_urls': imageUrls,
        'product_tag': _selectedProductTag,
        'is_featured': _selectedProductTag == 'featured',
        'gender': _selectedGender,
        'is_active': _isActive,
        'sold_count': 0,
        'rating': 0.0,
        'review_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('products').insert(productData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding product: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: "Add Product"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF003049)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image preview
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _selectedImages.isEmpty
                          ? const Icon(Icons.image, size: 60, color: Colors.grey)
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      _buildPickedImagePreview(
                                        _selectedImages[index],
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _selectedImages.removeAt(index);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 10),

                    Center(
                      child: ElevatedButton(
                        onPressed: _pickImages,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003049),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          "ADD PICTURE",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product Name
                    const Text("Product Name",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        hintText: 'Enter product name',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter product name' : null,
                    ),
                    const SizedBox(height: 15),

                    // Description
                    const Text("Description",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        hintText: 'Enter product description',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter description' : null,
                    ),
                    const SizedBox(height: 15),

                    // Category Dropdown
                    const Text("Category",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 15),

                    // Available Sizes
                    const Text("Available Sizes (comma-separated)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _availableSizesController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        hintText: 'e.g., Adjustable, Small, Medium',
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Regular Price
                    const Text("Regular Price",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _regularPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        hintText: 'Enter regular price',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter regular price' : null,
                    ),
                    const SizedBox(height: 15),

                    // Sale Price
                    const Text("Sale Price (Optional)",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _salePriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        hintText: 'Enter sale price (if on discount)',
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Stock Quantity
                    const Text("Stock Quantity",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _stockQuantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                        hintText: 'Enter stock quantity',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter stock quantity' : null,
                    ),
                    const SizedBox(height: 15),

                    // Product Tag Dropdown
                    const Text("Product Tag",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: _selectedProductTag,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      items: _productTags.map((tag) {
                        return DropdownMenuItem<String>(
                          value: tag,
                          child: Text(tag.replaceAll('_', ' ').toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProductTag = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Gender Dropdown
                    const Text("Target Gender",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      items: _genderOptions.map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Checkbox(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() => _isActive = value ?? false);
                          },
                        ),
                        const Text("Is Active Product (Visible in Shop)",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003049),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("ADD PRODUCT"),
                    ),
                    const SizedBox(height: 10),

                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("CANCEL",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPickedImagePreview(XFile image) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 164,
            width: 164,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return _buildImageFallback();
        }

        return Image.memory(
          snapshot.data!,
          height: 164,
          width: 164,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildImageFallback(),
        );
      },
    );
  }

  Widget _buildImageFallback() {
    return Container(
      height: 164,
      width: 164,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, size: 36, color: Colors.grey),
    );
  }
}
