import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/data/services/auth_service.dart';
import 'package:jewello/features/authentication/screens/login.dart';
import 'package:jewello/features/cart/order_summary.dart';
import 'package:jewello/features/products/controllers/product_details_controller.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/buttons_theme.dart';
import 'package:jewello/utils/theme/color_theme.dart';
import 'package:jewello/utils/theme/dropdown_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';
import 'package:jewello/features/personalization/controller/wishlist_controller.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final WishlistController wishlistController =
        Get.isRegistered<WishlistController>()
            ? Get.find<WishlistController>()
            : Get.put(WishlistController());
    final productDetailsController =
        Get.isRegistered<ProductDetailsController>(tag: product.id)
            ? Get.find<ProductDetailsController>(tag: product.id)
            : Get.put(
                ProductDetailsController(productId: product.id),
                tag: product.id,
              );

    if (product.availableSizes.isNotEmpty &&
        productDetailsController.selectedSize.value.isEmpty) {
      productDetailsController.selectedSize.value =
          product.availableSizes.first;
    }

    return Scaffold(
      appBar: AppBarThemeStyle(title: 'Product Detail'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              // 🖼 Product Image
              Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: product.imageUrls.isNotEmpty
                      ? Image.network(
                          product.imageUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              // 🏷 Product Name + Wishlist
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      product.name,
                      style: DDSilverTextStyles.productTitle,
                    ),
                  ),
                  Obx(() {
                    final isFav = wishlistController.isInWishlist(product.id);
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? DDSilverColors.primary : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        wishlistController.toggleWishlistItem({
                          'id': product.id,
                          'name': product.name,
                          'price': product.price,
                          'imageUrl': product.imageUrls.isNotEmpty
                              ? product.imageUrls.first
                              : '',
                        });
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 10),

              // Price
              Row(
                children: [
                  if (product.originalPrice != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DDSilverTextStyles.finalPrice(
                          "₹ ${product.price}",
                          true,
                        ),
                        const SizedBox(height: 8),
                        DDSilverTextStyles.originalPrice(
                          "₹ ${product.originalPrice}",
                          true,
                        ),
                      ],
                    )
                  else
                    DDSilverTextStyles.finalPrice("₹ ${product.price}", true),
                ],
              ),

              const SizedBox(height: 20),

              // 📏 Size and Quantity
              Row(
                children: [
                  if (product.availableSizes.isNotEmpty)
                    Flexible(
                      child: CustomDropdownTheme(
                        label: 'Select Size',
                        options: product.availableSizes,
                        initialValue: product.availableSizes.first,
                        onChanged: (val) =>
                            productDetailsController.selectedSize.value = val,
                      ),
                    ),
                  const SizedBox(width: 20),
                  Flexible(
                    child: CustomDropdownTheme(
                      label: 'Quantity',
                      options: ['1', '2', '3', '4', '5'],
                      initialValue: "1",
                      onChanged: (val) =>
                          productDetailsController.quantity.value = val,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Product Description
              Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Description',
                        style: DDSilverTextStyles.prodDescTitle,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.description,
                        style: DDSilverTextStyles.prodDesc,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),

              // Reviews Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DDSilverTextStyles.revieweLabel,
                      SizedBox(width: 10),
                      Icon(
                        Icons.star,
                        color: DDSilverColors.ratingStar,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: DDSilverTextStyles.ratingCalc,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '(${product.reviewCount} Reviews)',
                        style: DDSilverTextStyles.totalRating,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Review Items
                  Obx(() {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: productDetailsController.reviews.length,
                      itemBuilder: (context, index) {
                        final review = productDetailsController.reviews[index];
                        return _buildReviewItem(
                          review.userName,
                          review.comment,
                          review.profilePicture ?? "",
                        );
                      },
                    );
                  }),
                ],
              ),
              SizedBox(height: 30),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      // Bottom Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DDSilverColors.bottomBG,
          border: Border.all(color: DDSilverColors.bottomBorder, width: 1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: DDSilverAuthButton(
                text: 'Add to Cart',
                onPressed: auth.isLoggedIn ?
                () async {
                  await productDetailsController.addToCart();
                }
                : (){
                    Loaders.errorSnackBar(title: 'Unauthorized', message: 'Please login to access this feature');
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: LoginScreen(),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );
                  },
                // onPressed: () async {
                //   await productDetailsController.addToCart();
                // },
                inv: true,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: DDSilverAuthButton(
                text: 'Buy Now',
                onPressed: auth.isLoggedIn ?
                () {
                  // Get selected size and quantity
                  final selectedSize =
                      productDetailsController.selectedSize.value.isNotEmpty
                      ? productDetailsController.selectedSize.value
                      : (product.availableSizes.isNotEmpty
                            ? product.availableSizes.first
                            : 'Default');

                  final quantity = int.parse(
                    productDetailsController.quantity.value,
                  );

                  // Create single product map
                  final singleProductData = {
                    'productId': product.id,
                    'name': product.name,
                    'price': product.price,
                    'imageUrl': product.imageUrls.isNotEmpty
                        ? product.imageUrls.first
                        : '',
                    'size': selectedSize,
                    'quantity': quantity,
                  };

                  // Navigate to Order Summary with single product
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderSummaryScreen(singleProduct: singleProductData),
                    ),
                  );
                }
                : () {
                  Loaders.errorSnackBar(title: 'Unauthorized', message: 'Please login to access this feature');
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: LoginScreen(),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );
                  },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildReviewItem(String name, String review, String avatarUrl) {
  return Container(
    margin: EdgeInsets.only(bottom: 15),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          backgroundImage: (avatarUrl.isNotEmpty)
              ? NetworkImage(avatarUrl)
              : const AssetImage('assets/images/customer.png') as ImageProvider,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: DDSilverTextStyles.reviewerName),
              SizedBox(height: 4),
              Text(review, style: DDSilverTextStyles.comment),
            ],
          ),
        ),
      ],
    ),
  );
}
