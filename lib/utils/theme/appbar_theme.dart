import 'package:flutter/material.dart';
import 'package:jewello/features/cart/my_cart.dart';
import 'package:jewello/utils/theme/text_theme.dart';

class AppBarThemeStyle extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showWishlist;
  final bool showCart;
  final int cartCount;
  final bool showLogo;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onCartTap;
                 

  const AppBarThemeStyle({
    super.key,
    required this.title,
    this.showWishlist = false,
    this.showCart = false,
    this.showLogo = false,
    this.onWishlistTap,
    this.onCartTap,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: showLogo ? 80 : kToolbarHeight,
      titleSpacing: 8,
      leading: Navigator.canPop(context)
      ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        )
      : null,

      title: _buildTitle(),
      centerTitle: false,
      actions: [
        if(showWishlist)
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: onWishlistTap,
          ),
        if (showCart)
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: onCartTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyCartScreen()),
                  );
                },
          ),
      ],
    );
  }

  Widget _buildTitle() {
    if (showLogo && title.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'assets/logo/Horizontal_logo.png',
          height: 55,
          fit: BoxFit.contain,
        ),
      );
    }

    if (showLogo && title.isNotEmpty) {
      return Row(
        children: [
          Image.asset(
            'assets/logo/Horizontal_logo.png',
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DDSilverTextStyles.appBarStyle,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: DDSilverTextStyles.appBarStyle,
    );
  }
  
  @override
  Size get preferredSize =>
      Size.fromHeight(showLogo ? 80 : kToolbarHeight);
}
