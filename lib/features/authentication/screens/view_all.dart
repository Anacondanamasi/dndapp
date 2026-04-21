import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/features/shop/controller/category_controller.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';
import 'package:jewello/utils/theme/card_theme.dart';
import 'package:jewello/features/authentication/controllers/homescreen_controller.dart';

class ViewAll extends StatefulWidget {
  final String viewType; // "featured", "bestSeller", or "newArrival"
  final String? categoryId;
  const ViewAll({Key? key, required this.viewType, this.categoryId}) : super(key: key);

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  late HomescreenController controller;
  final categoryController = CategoryController.instance;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomescreenController());

    // Fetch product list based on selected view type
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      switch (widget.viewType) {
        case "featured":
          await controller.fetchFeaturedProducts(limit: 15);
          break;
        case "trending":
          await controller.fetchTrendingProducts(limit: 15);
          break;
        case "new_arrival":
          await controller.fetchNewArrivals(limit: 15);
          break;
        case "category":
          print("Category ID: ${widget.categoryId}");
          if (widget.categoryId != null) {
            await categoryController.fetchProductsByCategory(widget.categoryId!);
          }
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    RxList products;

    if (widget.viewType == "featured") {
      products = controller.featuredProducts;
    } else if (widget.viewType == "trending") {
      products = controller.trendingProducts;
    } else if (widget.viewType == "category") {
      products = categoryController.fromCategory; 
    } else {
      products = controller.newArrivals;
    }

    return Scaffold(
      appBar: AppBarThemeStyle(
        title: widget.viewType == "featured"
            ? "Featured Products"
            : widget.viewType == "trending"
            ? "Trending Jewellery"
            : widget.viewType == "category"
            ? "Category Products"
            : "New Arrivals",
        showCart: true,
        showWishlist: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            //Product Grid
            Expanded(
              child: Obx(() {
                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
