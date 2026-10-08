import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/features/categories/categories_screen.dart';
import 'package:magna_data_ai_ecommerce/features/favourites/favourites_screen.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_screen.dart';
import 'package:magna_data_ai_ecommerce/features/main/main_shell_controller.dart';
import 'package:magna_data_ai_ecommerce/features/users-profile/user_profile_screen.dart';

class MainShell extends GetView<MainShellController> {
  const MainShell({super.key});

  static const primary = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    debugPrint('MainShell build');
    return Obx(() {
      final index = controller.currentIndex.value;
      return PopScope(
        canPop: index == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) controller.goTo(0);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: IndexedStack(
            index: index,
            children: [
              const HomeScreen(),
              controller.hasVisited(1)
                  ? const CategoriesScreen()
                  : const SizedBox.shrink(),
              controller.hasVisited(2)
                  ? const FavouriteScreen()
                  : const SizedBox.shrink(),
              controller.hasVisited(3)
                  ? const ProfileScreen()
                  : const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SnakeNavigationBar.color(
              behaviour: SnakeBarBehaviour.floating,
              snakeShape: SnakeShape.circle,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              backgroundColor: Colors.white,
              snakeViewColor: primary,
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color(0xFF8A94A6),
              currentIndex: index,
              onTap: controller.goTo,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_rounded),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
