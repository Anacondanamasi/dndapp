import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/features/shop/models/category_model.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/color_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:jewello/utils/theme/card_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _supabase = sb.Supabase.instance.client;
  
  final List<String> _selectedCategoryIds = <String>['All'].obs;
  final List<String> _selectedGenders = <String>['All'].obs;
  bool _isSearching = false;
  bool _isLoading = true;

  final RxList<ProductModel> _allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> _filteredProducts = <ProductModel>[].obs;
  final RxList<CategoryModel> _categories = <CategoryModel>[].obs;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch products from Supabase
  Future<void> _fetchProducts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final List<dynamic> response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true);
      
      final fetchedProducts = response.map((data) => ProductModel.fromMap(data)).toList();
      _allProducts.assignAll(fetchedProducts);

      setState(() {
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Loaders.errorSnackBar(title: 'Oh Snap', message: "Error loading products.");
      }
    }
  }

  // Fetch categories for filter
  Future<void> _fetchCategories() async {
    try {
      final List<dynamic> response = await _supabase
          .from('categories')
          .select()
          .eq('is_active', true);
      
      final fetchedCategories = response.map((data) => CategoryModel.fromMap(data)).toList();
      _categories.assignAll(fetchedCategories);
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    _filteredProducts.value = _allProducts.where((product) {
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      
      final bool matchesCategory = _selectedCategoryIds.contains('All') || 
                                   _selectedCategoryIds.contains(product.categoryId);
      
      final bool matchesGender = _selectedGenders.contains('All') || 
                                 _selectedGenders.contains(product.gender);
      
      return matchesQuery && matchesCategory && matchesGender;
    }).toList();
  }

  void _filterProducts(String query) {
    setState(() {
      _isSearching = query.isNotEmpty || 
                     !_selectedCategoryIds.contains('All') || 
                     !_selectedGenders.contains('All');
      _applyFilters();
    });
  }

  void _showFilterModal() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildFilterChip('Category', 'All'),
                  ..._categories.map((cat) => _buildFilterChip('Category', cat.id, label: cat.name)),
                ],
              )),
              
              const SizedBox(height: 20),
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildFilterChip('Gender', 'All'),
                  _buildFilterChip('Gender', 'Men'),
                  _buildFilterChip('Gender', 'Ladies'),
                ],
              )),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DDSilverColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategoryIds.assignAll(['All']);
                      _selectedGenders.assignAll(['All']);
                      _applyFilters();
                    });
                    Get.back();
                  },
                  child: const Text('RESET ALL', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String type, String value, {String? label}) {
    final List<String> selectionList = type == 'Category' ? _selectedCategoryIds : _selectedGenders;
    bool isSelected = selectionList.contains(value);
    
    return FilterChip(
      label: Text(label ?? value),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (value == 'All') {
            selectionList.assignAll(['All']);
          } else {
            if (selected) {
              selectionList.remove('All');
              selectionList.add(value);
            } else {
              selectionList.remove(value);
              if (selectionList.isEmpty) {
                selectionList.add('All');
              }
            }
          }
          _applyFilters();
        });
      },
      checkmarkColor: DDSilverColors.primary,
      selectedColor: DDSilverColors.primary.withOpacity(0.12),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? DDSilverColors.primary : Colors.grey.shade300),
      ),
      labelStyle: TextStyle(
        color: isSelected ? DDSilverColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBarThemeStyle(title: 'Search'),
      body: Column(
        children: [
          // Search Bar Section
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterProducts,
                          decoration: InputDecoration(
                            hintText: "Search Product",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey[600]),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterProducts('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showFilterModal,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (!_selectedCategoryIds.contains('All') || !_selectedGenders.contains('All')) 
                              ? DDSilverColors.primary 
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          Icons.filter_list, 
                          color: (!_selectedCategoryIds.contains('All') || !_selectedGenders.contains('All')) 
                              ? Colors.white 
                              : Colors.grey[600]
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results Count
          if ((_isSearching || !_selectedCategoryIds.contains('All') || !_selectedGenders.contains('All')) && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_filteredProducts.length} results found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Products Grid or Loading
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: DDSilverColors.primary,
                    ),
                  )
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return ProductCard(
                              product: product,
                              img: product.imageUrls.isNotEmpty
                                  ? product.imageUrls.first
                                  : '',
                              name: product.name,
                              price: '₹ ${product.price.toStringAsFixed(2)}',
                              discount: product.originalPrice != null
                                  ? '₹ ${product.originalPrice!.toStringAsFixed(2)}'
                                  : '',
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
