import 'package:get/get.dart';
import 'package:magna_data_ai_ecommerce/core/services/cart_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/category_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/checkout_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/favourites_services.dart';
import 'package:magna_data_ai_ecommerce/core/services/location_service.dart';
import 'package:magna_data_ai_ecommerce/core/services/product_services.dart';
import 'package:magna_data_ai_ecommerce/data/models/product.dart';
import 'package:magna_data_ai_ecommerce/features/add-to-cart/add_to_cart_screen.dart';
import 'package:magna_data_ai_ecommerce/features/add-to-cart/cart_controller.dart';
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
import 'package:magna_data_ai_ecommerce/features/favourites/favourites_controller.dart';
import 'package:magna_data_ai_ecommerce/features/favourites/favourites_screen.dart';
import 'package:magna_data_ai_ecommerce/features/home/home_controller.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_controller.dart';
import 'package:magna_data_ai_ecommerce/features/onboarding/onboarding_screen.dart';
import 'package:magna_data_ai_ecommerce/features/order-confirmation/order_confirmation_screen.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-details/product_details_screen.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_controller.dart';
import 'package:magna_data_ai_ecommerce/features/product-list/product_list_screen.dart';
import 'package:magna_data_ai_ecommerce/features/users-profile/user_profile_screen.dart';
import 'package:magna_data_ai_ecommerce/features/main/main_shell.dart';
import 'package:magna_data_ai_ecommerce/features/main/main_shell_controller.dart';

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
      page: () => const MainShell(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MainShellController>(() => MainShellController());
        Get.lazyPut<HomeController>(
          () => HomeController(
            Get.find<ProductService>(),
            Get.find<CategoryService>(),
            Get.find<LocationService>(),
          ),
        );
      }),
    ),

    GetPage(
      name: AppRoutes.productList,
      page: () => const ProductListScreen(),
      binding: BindingsBuilder(() {
        final args = Get.arguments as ProductListArgs;
        Get.lazyPut<ProductListController>(
          () => ProductListController(
            Get.find<ProductService>(),
            Get.find<CategoryService>(),
            args,
          ),
        );
      }),
    ),

    GetPage(
      name: AppRoutes.productList,
      page: () => const ProductListScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductListController>(
          () => ProductListController(
            Get.find<ProductService>(),
            Get.find<CategoryService>(),
            const ProductListArgs(title: 'Search', searchMode: true),
          ),
        );
      }),
    ),

    GetPage(
      name: AppRoutes.productDetails,
      page: () {
        final args = Get.arguments;
        final productId = args is Product
            ? args.id
            : args is int
            ? args
            : 0;
        final tag = 'product-details-$productId';
        return ProductDetailsScreen(controllerTag: tag);
      },
      binding: BindingsBuilder(() {
        final args = Get.arguments;
        final productId = args is Product
            ? args.id
            : args is int
            ? args
            : 0;

        final tag = 'product-details-$productId';

        Get.lazyPut<ProductDetailsController>(
          () => ProductDetailsController(
            Get.find<ProductService>(),
            Get.find<CartService>(),
            args,
          ),
          tag: tag,
        );
      }),
    ),

    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CartController>(
          () => CartController(Get.find<CartService>()),
        );
      }),
    ),

    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CheckoutController>(
          () => CheckoutController(
            Get.find<CartService>(),
            Get.find<CheckoutService>(),
          ),
        );
      }),
    ),

    GetPage(
      name: AppRoutes.orderConfirmation,
      page: () => const OrderConfirmationScreen(),
    ),

    GetPage(
      name: AppRoutes.favourites,
      page: () => const FavouriteScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FavouriteController>(
          () => FavouriteController(Get.find<FavouriteService>()),
        );
      }),
    ),

    GetPage(name: AppRoutes.categories, page: () => const CategoriesScreen()),

    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
  ];
}
