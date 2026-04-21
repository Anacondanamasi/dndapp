import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:jewello/admin/add_product.dart';
import 'package:jewello/admin/update_product.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';

class AllProductScreen extends StatefulWidget {
  const AllProductScreen({super.key});

  @override
  State<AllProductScreen> createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  final _supabase = sb.Supabase.instance.client;
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      setState(() => _isLoading = true);
      final response = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);
      
      setState(() {
        _products = response as List;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: 'All Products'),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
            ? const Center(
                child: Text(
                  'No products found.\nAdd your first product!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final productData = _products[index] as Map<String, dynamic>;
                  
                  return ProductCard(
                    productId: productData['id'],
                    productData: productData,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProductScreen(
                            productId: productData['id'],
                            productData: productData,
                          ),
                        ),
                      );
                      
                      if (result == true) {
                        _fetchProducts();
                      }
                    },
                  );
                },
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProduct()),
            );
            
            // Refresh if product was added
            if (result == true) {
              _fetchProducts();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003049),
            foregroundColor: Colors.white,
            minimumSize: const Size(160, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "ADD PRODUCT",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> productData;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.productId,
    required this.productData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get first image URL
    List<dynamic> imageUrls = productData['image_urls'] ?? [];
    String imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

    // Get prices
    num originalPrice = productData['original_price'] ?? 0;
    num displayPrice = productData['price'] ?? 0;
    
    // Check if there's a sale (Price is less than OriginalPrice)
    bool hasSale = displayPrice < originalPrice;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 6),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 6),
                            Text(
                              'No Image',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    productData['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Price row
                  Row(
                    children: [
                      Text(
                        '₹$displayPrice',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF003049),
                        ),
                      ),
                      if (hasSale) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹$originalPrice',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  // Stock info
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${productData['stock_quantity'] ?? 0}',
                    style: TextStyle(
                      fontSize: 11,
                      color: (productData['stock_quantity'] ?? 0) > 0 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
