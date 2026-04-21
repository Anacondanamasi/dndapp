import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/personalization/controller/wishlist_controller.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/wishlist_product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController = Get.put(WishlistController());

    // Initial load
    wishlistController.loadWishlist();

    return SafeArea(
      child: Scaffold(
        appBar: AppBarThemeStyle(
          title: "Wishlist",
        ),
        body: Obx(() {
          if (wishlistController.wishlistItems.isEmpty) {
            return const Center(
              child: Text(
                "Your wishlist is empty.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: wishlistController.wishlistItems.length,
            itemBuilder: (context, index) {
              final item = wishlistController.wishlistItems[index];
              return WishlistProductCard(
                productId: item['id'],
                name: item['name'] ?? '',
                price: (item['price'] as num).toDouble(),
                imageUrl: item['imageUrl'] ?? '',
              );
            },
          );
        }),
      ),
    );
  }
}
