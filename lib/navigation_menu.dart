import 'package:jewello/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:jewello/utils/theme/color_theme.dart';
import 'package:jewello/features/authentication/screens/home.dart';
import 'package:jewello/features/authentication/screens/login.dart';
import 'package:jewello/features/cart/my_cart.dart';
import 'package:jewello/features/personalization/screens/profile/profile.dart';
import 'package:jewello/features/personalization/screens/profile/search.dart';
import 'package:jewello/features/personalization/screens/profile/wishlist.dart';
import 'package:get/get.dart';
import 'package:jewello/features/cart/controllers/my_cart_controller.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainBottomNavBar extends StatefulWidget {
  const MainBottomNavBar({super.key});

  @override
  State<MainBottomNavBar> createState() => _MainBottomNavBarState();
}

class _MainBottomNavBarState extends State<MainBottomNavBar> {
  late PersistentTabController _controller;
  final cartController = Get.isRegistered<MyCartController>()
      ? Get.find<MyCartController>()
      : Get.put(MyCartController());

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      const HomeScreen(),
      const WishlistScreen(),
      const MyCartScreen(),
      const SearchScreen(),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        inactiveIcon: const Icon(Icons.home_outlined),
        title: "Home",
        activeColorPrimary: DDSilverColors.primary,
        inactiveColorPrimary: Colors.black,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.favorite),
        inactiveIcon: const Icon(Icons.favorite_outline),
        title: "Wishlist",
        activeColorPrimary: DDSilverColors.primary,
        inactiveColorPrimary: Colors.black,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PersistentBottomNavBarItem(
        icon: Obx(() => Badge(
          label: Text(cartController.cartItems.length.toString()),
          isLabelVisible: cartController.cartItems.isNotEmpty,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DDSilverColors.primary,
              boxShadow: [
                if (_controller.index == 2)
                 const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 24,
            ),
          ),
        )),
        title: "",
        activeColorPrimary: DDSilverColors.primary,
        inactiveColorPrimary: DDSilverColors.primary.withOpacity(0.6),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        inactiveIcon: const Icon(Icons.search_outlined),
        title: "Search",
        activeColorPrimary: DDSilverColors.primary,
        inactiveColorPrimary: Colors.black,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        inactiveIcon: const Icon(Icons.settings_outlined),
        title: "Settings",
        activeColorPrimary: DDSilverColors.primary,
        inactiveColorPrimary: Colors.black,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarItems(),

      onItemSelected: (index) {
        final isLoggedIn = AuthService.instance.isLoggedIn;

        // tabs that need authentication to access
        final protectedTabs = [1, 2, 4]; 

        if (protectedTabs.contains(index) && !isLoggedIn) {
          // stop navigation and open login screen
          setState(() {
            _controller.index = _controller.index;   // stay on current tab
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          return;
        }
        // if logged in, allow switching tab
        setState(() {
          _controller.index = index;
        });
      },

      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      backgroundColor: Colors.white,
      isVisible: true,

      decoration: const NavBarDecoration(
        colorBehindNavBar: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 1)),
      ),

      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          // screenTransitionAnimationType: ScreenTransitionAnimationType.fade,
        ),
      ),
      
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight + 10,
      navBarStyle: NavBarStyle.style15, // You can change this style
    );
  }
}
