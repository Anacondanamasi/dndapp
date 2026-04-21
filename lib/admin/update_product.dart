import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';

class UpdateProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const UpdateProductScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _regularPriceController;
  late TextEditingController _salePriceController;
  late TextEditingController _stockQuantityController;
  late TextEditingController _availableSizesController;
  
  // State variables
  List<XFile> _newImages = [];
  List<String> _existingImageUrls = [];
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
    _initializeControllers();
    _fetchCategories();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.productData['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.productData['description'] ?? '');
    _regularPriceController = TextEditingController(
      text: widget.productData['original_price']?.toString() ?? ''
    );
    _salePriceController = TextEditingController(
      text: widget.productData['price']?.toString() ?? ''
    );
    _stockQuantityController = TextEditingController(
      text: widget.productData['stock_quantity']?.toString() ?? '0'
    );
    
    // Join sizes with comma
    List<dynamic> sizes = widget.productData['available_sizes'] ?? [];
    _availableSizesController = TextEditingController(
      text: sizes.join(', ')
    );
    
    _selectedCategoryId = widget.productData['category_id'];
    _isActive = widget.productData['is_active'] ?? true;
    _selectedProductTag = widget.productData['product_tag'] ?? 'none';
    _selectedGender = widget.productData['gender'] ?? 'All';
    
    // Load existing images
    List<dynamic> imageUrls = widget.productData['image_urls'] ?? [];
    _existingImageUrls = imageUrls.map((url) => url.toString()).toList();
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
        _categories = response.map((data) {
          return {
            'id': data['id'],
            'name': data['name'] ?? 'Unknown',
          };
        }).where((cat) => cat['name'] != 'Unknown').toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
    }
  }

  // Pick images from gallery
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _newImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  // Upload new images to Supabase Storage
  Future<List<String>> _uploadNewImages() async {
    List<String> imageUrls = [];
    final supabase = Supabase.instance.client;
    
    for (int i = 0; i < _newImages.length; i++) {
      try {
        int index = _existingImageUrls.length + i;
        String fileName = '${widget.productId}_$index.jpg';
        
        final bytes = await _newImages[i].readAsBytes();
        await supabase.storage.from('products').uploadBinary(fileName, bytes);
        
        final url = supabase.storage.from('products').getPublicUrl(fileName);
        imageUrls.add(url);
      } catch (e) {
        print('Error uploading image $i: $e');
      }
    }
    
    return imageUrls;
  }

  // Delete image from Supabase Storage
  Future<void> _deleteImageFromStorage(String imageUrl) async {
    try {
      final fileName = imageUrl.split('/').last;
      await Supabase.instance.client.storage.from('products').remove([fileName]);
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Update product
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new images
      List<String> newImageUrls = [];
      if (_newImages.isNotEmpty) {
        newImageUrls = await _uploadNewImages();
      }
      
      // Combine
      List<String> allImageUrls = [..._existingImageUrls, ...newImageUrls];

      // Parse sizes
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
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid sale price format')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Prepare updated data
      Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategoryId,
        'original_price': regularPrice,
        'price': displayPrice,
        'stock_quantity': int.parse(_stockQuantityController.text),
        'available_sizes': sizes,
        'image_urls': allImageUrls,
        'product_tag': _selectedProductTag,
        'is_featured': _selectedProductTag == 'featured',
        'gender': _selectedGender,
        'is_active': _isActive,
      };

      // Update in Supabase
      await Supabase.instance.client
          .from('products')
          .update(updatedData)
          .eq('id', widget.productId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete product
  Future<void> _deleteProduct() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Storage cleanup
      for (String imageUrl in _existingImageUrls) {
        await _deleteImageFromStorage(imageUrl);
      }

      // Delete from Supabase
      await Supabase.instance.client
          .from('products')
          .delete()
          .eq('id', widget.productId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: "Update Product"),
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
                      child: (_existingImageUrls.isEmpty && _newImages.isEmpty)
                          ? const Icon(Icons.image, size: 60, color: Colors.grey)
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _existingImageUrls.length + _newImages.length,
                              itemBuilder: (context, index) {
                                bool isExisting = index < _existingImageUrls.length;
                                
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      isExisting
                                          ? Image.network(
                                              _existingImageUrls[index],
                                              height: 164,
                                              width: 164,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _buildImageFallback(),
                                             )
                                        : _buildPickedImagePreview(
                                            _newImages[index - _existingImageUrls.length],
                                          ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              if (isExisting) {
                                                _existingImageUrls.removeAt(index);
                                              } else {
                                                _newImages.removeAt(index - _existingImageUrls.length);
                                              }
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "ADD MORE PICTURES",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildReadOnlyField("Sold Count", widget.productData['sold_count']?.toString() ?? '0'),
                    _buildReadOnlyField("Rating", widget.productData['rating']?.toString() ?? '0.0'),
                    _buildReadOnlyField("Review Count", widget.productData['review_count']?.toString() ?? '0'),
                    const SizedBox(height: 20),

                    // Product Name
                    const Text("Product Name",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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
                      onPressed: _updateProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("UPDATE"),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: _deleteProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003049),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("DELETE"),
                    ),
                    const SizedBox(height: 10),

                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
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
