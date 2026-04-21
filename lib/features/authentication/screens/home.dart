import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/data/services/auth_service.dart';
import 'package:jewello/features/authentication/controllers/home_banner_controller.dart';
import 'package:jewello/features/authentication/screens/login.dart';
import 'package:jewello/features/authentication/screens/view_all.dart';
import 'package:jewello/features/cart/my_cart.dart';
import 'package:jewello/features/personalization/screens/profile/wishlist.dart';
import 'package:jewello/features/products/controllers/product_controller.dart';
import 'package:jewello/features/shop/controller/category_controller.dart';
import 'package:jewello/features/products/models/product_model.dart';
import 'package:jewello/utils/loaders.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/card_theme.dart';
import 'package:jewello/utils/theme/color_theme.dart';
import 'package:jewello/utils/theme/text_theme.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final auth = Get.find<AuthService>();
  final productController = Get.put(ProductController());
  final categoryController = Get.put(CategoryController());
  final bannerController = Get.put(HomeBannerController());

  final List<String> fallbackBanners = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  final CarouselSliderController carouselController = CarouselSliderController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(
        title: '',
        showLogo: true,
        showWishlist: true,
        showCart: true,
        onWishlistTap: () {
          if (auth.isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistScreen()),
            );
          } else {
            Loaders.errorSnackBar(
              title: 'Unauthorized',
              message: 'Please login to access this feature',
            );
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const LoginScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }
        },
        onCartTap: () {
          if (auth.isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyCartScreen()),
            );
          } else {
            Loaders.errorSnackBar(
              title: 'Unauthorized',
              message: 'Please login to access this feature',
            );
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const LoginScreen(),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }
        },
      ),
      body: Obx(() {
        if (productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildBannerCarousel(),
                const SizedBox(height: 20),

                // Categories Section
                _buildCategorySection(),
                const SizedBox(height: 20),
                
                // Featured Products Section
                _buildProductSection(
                  context,
                  title: 'Featured Products',
                  viewType: 'featured',
                  products: productController.featuredProduct,
                ),
                
                const SizedBox(height: 25),

                // Trending Products Section
                _buildProductSection(
                  context,
                  title: 'Trending Jewellery',
                  viewType: 'trending',
                  products: productController.trendingProducts,
                ),

                const SizedBox(height: 25),

                // New Arrivals Section
                _buildProductSection(
                  context,
                  title: 'New Arrivals',
                  viewType: 'new_arrival',
                  products: productController.newArrivals,
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontSize: 21, fontFamily: 'Kurale'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: Obx(() {
            if (categoryController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = categoryController.featuredCategories
                .where((cat) => cat.isActive)
                .toList();

            if (categories.isEmpty) {
              return const Center(child: Text('No categories found'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: GestureDetector(
                    onTap: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: ViewAll(
                          viewType: 'category',
                          categoryId: category.id,
                        ),
                        withNavBar: false,
                        pageTransitionAnimation: PageTransitionAnimation.cupertino,
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: DDSilverColors.primary.withOpacity(0.2)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              category.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 85,
                          child: Text(
                            category.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductSection(BuildContext context,
      {required String title,
      required String viewType,
      required List<ProductModel> products}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 21, fontFamily: 'Kurale'),
            ),
            TextButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: ViewAll(viewType: viewType),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: Text(
                'View All',
                style: TextStyle(color: DDSilverColors.primary),
              ),
            ),
          ],
        ),
        Divider(
          thickness: 1,
          color: DDSilverColors.primary.withOpacity(0.25),
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No $title found.',
                style: DDSilverTextStyles.prodDesc,
              ),
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.65,
            children: products.map((product) {
              return ProductCard(
                product: product,
                img: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                name: product.name,
                price: '₹ ${product.price.toStringAsFixed(2)}',
                discount: product.originalPrice != null
                    ? '₹ ${product.originalPrice!.toStringAsFixed(2)}'
                    : '',
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildBannerCarousel() {
    return Obx(() {
      final bannerUrls = bannerController.banners
          .map((banner) => banner.imageUrl)
          .toList();
      final hasDbBanners = bannerUrls.isNotEmpty;
      final totalItems =
          hasDbBanners ? bannerUrls.length : fallbackBanners.length;
      final safeCurrentIndex = currentIndex >= totalItems ? 0 : currentIndex;

      if (safeCurrentIndex != currentIndex && totalItems > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            currentIndex = safeCurrentIndex;
          });
        });
      }

      return Stack(
        children: [
          CarouselSlider(
            carouselController: carouselController,
            items: List.generate(totalItems, (index) {
              final String imageSource =
                  hasDbBanners ? bannerUrls[index] : fallbackBanners[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: hasDbBanners
                    ? Image.network(
                        imageSource,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _bannerFallback();
                        },
                      )
                    : Image.asset(
                        imageSource,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _bannerFallback();
                        },
                      ),
              );
            }),
            options: CarouselOptions(
              scrollPhysics: const BouncingScrollPhysics(),
              autoPlay: totalItems > 1,
              aspectRatio: 2.05,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalItems, (entryIndex) {
                return GestureDetector(
                  onTap: () =>
                      carouselController.animateToPage(entryIndex),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: safeCurrentIndex == entryIndex ? 10 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: safeCurrentIndex == entryIndex
                          ? DDSilverColors.primary
                          : Colors.grey,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }

  Widget _bannerFallback() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 46, color: Colors.grey),
      ),
    );
  }
}
