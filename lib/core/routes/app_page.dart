import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/cart_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/features/add-to-cart/add_to_cart_controller.dart';
import 'package:magna_data_ai_ecommerce/features/add-to-cart/add_to_cart_screen.dart';
import 'package:magna_data_ai_ecommerce/features/auth/forget-password/forget_password_controller.dart';
import 'package:magna_data_ai_ecommerce/features/auth/forget-password/forget_password_screen.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_controller.dart';
import 'package:magna_data_ai_ecommerce/features/auth/login/login_screen.dart';
import 'package:magna_data_ai_ecommerce/features/auth/register/register_screen.dart';
import 'package:magna_data_ai_ecommerce/features/auth/reset-password/reset_password_controller.dart';
import 'package:magna_data_ai_ecommerce/features/auth/reset-password/reset_password_screen.dart';
import 'package:magna_data_ai_ecommerce/features/categories/categories_screen.dart';
import 'package:magna_data_ai_ecommerce/features/checkout/checkout_controller.dart';
import 'package:magna_data_ai_ecommerce/features/checkout/checkout_screen.dart';
import 'package:magna_data_ai_ecommerce/features/favourites/favourites_screen.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_controller.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_screen.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_controller.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_screen.dart';
import 'package:magna_data_ai_ecommerce/features/order-confirmation/order_confirmation_screen.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_screen.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_screen.dart';
import 'package:magna_data_ai_ecommerce/features/users-profile/user_profile_screen.dart';

import '../../features/splash/splash_controller.dart';
import '../../features/splash/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder.put(() => SplashController()),
    ),

    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnboardingScreen(),
      binding: BindingsBuilder.put(() => OnboardingController()),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder.put(() => LoginController()),
    ),

    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),

    GetPage(
      name: AppRoutes.forgetPassword,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder.put(() => ForgotPasswordController()),
    ),

    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: BindingsBuilder.put(() => ResetPasswordController()),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => HomeController(
            Get.find<ProductService>(),
            Get.find<CategoryService>(),
          ),
        );
      }),
    ),

    GetPage(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(
          () => ProductDetailsController(
            Get.find<ProductService>(),
            Get.find<CartService>(),
          ),
        );
        Get.lazyPut(() => AddToCartController(Get.find<CartService>()));
      }),
    ),

    GetPage(
      name: AppRoutes.productList,
      page: () => const ProductListScreen(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as ProductListArgs;
        Get.lazyPut<ProductListController>(
          () => ProductListController(Get.find<ProductService>(), args),
        );
      }),
    ),

    GetPage(name: AppRoutes.cart, page: () => const CartScreen()),

    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CheckoutController>(() => CheckoutController());
      }),
    ),

    GetPage(
      name: AppRoutes.orderConfirmation,
      page: () => const OrderConfirmationScreen(),
    ),

    GetPage(
      name: AppRoutes.favourites,
      page: () => const FavouritesScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(
          () => GetPage(
            name: AppRoutes.orderConfirmation,
            page: () => const OrderConfirmationScreen(),
          ),
        ),
      ),
    ),

    GetPage(name: AppRoutes.categories, page: () => const CategoriesScreen()),

    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
  ];
}
