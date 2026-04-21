import 'package:flutter/material.dart';
import 'package:jewello/features/personalization/screens/profile/review.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/features/products/screen/product_details.dart';
import 'package:jewello/utils/theme/text_theme.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String img;
  final String name;
  final String price;
  final String? discount;

  const ProductCard({
    super.key,
    required this.product,
    required this.img,
    required this.name,
    required this.price,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),   // ripple effect respects border
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ProductDetailsScreen(product: product),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: (img.isNotEmpty && img.startsWith('http'))
                  ? Image.network(
                      img,
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 130,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 130,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 130,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 5),

                  // If discount available
                  if (discount != null && discount!.isNotEmpty)
                    Column(
                      children: [
                        DDSilverTextStyles.finalPrice(price, false),
                 
                        const SizedBox(width: 6),
                        
                        DDSilverTextStyles.originalPrice(discount, false),
                      ],
                    )
                  else
                    // If no discount, just show price
                    DDSilverTextStyles.finalPrice(price, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final ProductModel product;

  final String imagePath;
  final String title;
  final String description;
  final int price;

  final String? selectedSize;
  final List<String>? sizeOptions;
  final ValueChanged<String>? onSizeChanged;

  final int quantity;
  final List<int> quantityOptions;
  final ValueChanged<int> onQuantityChanged;

  final VoidCallback onDelete;

  const CartItemCard({
    super.key,
    required this.product,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    this.sizeOptions, // <- optional
    this.selectedSize, // <- optional
    this.onSizeChanged, // <- optional
    this.quantity = 1,
    required this.quantityOptions,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ProductDetailsScreen(product: product),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Container(
        height: 175,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- Product Image -----
            Container(
              width: 130,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.diamond,
                      color: Color(0xFFD4AF37),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
      
            const SizedBox(width: 20),
      
            // ----- Details Section -----
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title & Delete
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.black,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
      
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
      
                  const SizedBox(height: 10),
      
                  // Row with optional size selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (sizeOptions != null &&
                          selectedSize != null) // Only show if provided
                        _buildDropdown<String>(
                          value: selectedSize!,
                          items: sizeOptions!,
                          onChanged: (newVal) => onSizeChanged?.call(newVal),
                          labelBuilder: (s) => 'Size $s',
                        ),
      
                      _buildDropdown<int>(
                        value: quantity,
                        items: quantityOptions,
                        onChanged: onQuantityChanged,
                        labelBuilder: (q) => 'Quantity $q',
                      ),
                    ],
                  ),
      
                  const SizedBox(height: 8),
      
                  // Price
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '₹ $price',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
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
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T> onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Container(
      height: 30,
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        style: const TextStyle(fontSize: 12, color: Colors.black),
        alignment: Alignment.centerRight,
        items: items.map((e) {
          return DropdownMenuItem<T>(value: e, child: Text(labelBuilder(e)));
        }).toList(),
        onChanged: (newVal) {
          if (newVal != null) onChanged(newVal);
        },
      ),
    );
  }
}

//  my Order theme
// class MyOrderTheme extends StatelessWidget {
//   final String imagePath;
//   final String title;
//   final String description;
//   final int price;
//   final String? selectedSize;
//   final int quantity;

//   const MyOrderTheme({
//     super.key,
//     required this.imagePath,
//     required this.title,
//     required this.description,
//     required this.price,
//     this.selectedSize,
//     this.quantity = 1,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ReviewScreen(),
//           ),
//         );
//       },
//       child: Container(
//         height: 175,
//         decoration: BoxDecoration(
//           color: const Color(0xFFF8F8F8),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ----- Product Image -----
//             Container(
//               width: 130,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8F8F8),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(8.0),
//                   bottomLeft: Radius.circular(8.0),
//                 ),
//                 child: Image.asset(
//                   imagePath,
//                   width: double.infinity,
//                   height: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) => const Center(
//                     child: Icon(
//                       Icons.diamond,
//                       color: Color(0xFFD4AF37),
//                       size: 40,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
      
//             const SizedBox(width: 20),
      
//             // ----- Details Section -----
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Title & Delete
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
      
//                   // Description
//                   Text(
//                     description,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                       height: 1.3,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
      
//                   const SizedBox(height: 10),
      
//                   // Row with optional size selector
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Container(
//                         height: 30,
//                         width: 100,
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "Size - $selectedSize",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
      
//                       Container(
//                         height: 30,
//                         width: 100,
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Center(
//                           child: Text(
//                             "Quantity - $quantity",
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
      
//                   const SizedBox(height: 8),
      
//                   // Price
//                   Padding(
//                     padding: const EdgeInsets.only(right: 16, bottom: 8),
//                     child: Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         '₹ $price',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
