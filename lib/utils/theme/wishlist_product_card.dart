import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/personalization/controller/wishlist_controller.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/features/products/screen/product_details.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class WishlistProductCard extends StatelessWidget {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;

  const WishlistProductCard({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        final product = ProductModel(
          id: productId,
          name: name,
          price: price,
          originalPrice: null,
          description: '',
          rating: 4.5,
          reviewCount: 10,
          imageUrls: [imageUrl],
          availableSizes: [],
          isFeatured: false,
          soldCount: 0,
          categoryName: '',
          categoryId: '',
          createdAt: DateTime.now(),
        );

        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ProductDetailsScreen(product: product),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 130,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ),
                // Heart Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(() {
                    final isFav = wishlistController.isInWishlist(productId);
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        wishlistController.toggleWishlistItem({
                          'id': productId,
                          'name': name,
                          'price': price,
                          'imageUrl': imageUrl,
                        });
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Icon(
                          Icons.favorite,
                          size: 18,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                      ),
                    );
                  }),
                ),
              ],
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
                  Text(
                    "₹${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
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
