import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/services/analytics_service.dart';
import 'package:vego/features/auth/screens/login_screen.dart';
import 'package:vego/features/auth/screens/otp_screen.dart';
import 'package:vego/features/home/screens/home_screen.dart';
import 'package:vego/features/cart/screens/cart_screen.dart';
import 'package:vego/features/profile/screens/profile_screen.dart';
import 'package:vego/features/profile/screens/edit_profile_screen.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/features/orders/screens/order_history_screen.dart';
import 'package:vego/features/tracking/screens/tracking_screen.dart';
import 'package:vego/features/wishlist/screens/wishlist_screen.dart';
import 'package:vego/features/address/screens/address_management_screen.dart';
import 'package:vego/features/product/screens/product_detail_screen.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/features/category/screens/category_products_screen.dart';
import 'package:vego/core/theme/app_colors.dart';

abstract class AppRoutes {
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String wishlist = '/wishlist';
  static const String tracking = '/tracking';
  static const String product = '/product';
  static const String addresses = '/addresses';
  static const String category = '/category/:name';
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Route observer that logs screen views to [AnalyticsService].
class AnalyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      AnalyticsService().logScreenView(route.settings.name!);
    }
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  refreshListenable:
      GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
  observers: [AnalyticsRouteObserver()],
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.otp;

    if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
    if (isLoggedIn && isAuthRoute) return AppRoutes.home;
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const OrderHistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.wishlist,
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: AppRoutes.tracking,
      builder: (context, state) {
        final orderId = state.extra as String?;
        return TrackingScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: AppRoutes.product,
      builder: (context, state) {
        final product = state.extra as Product?;
        if (product == null) {
          // Fallback if accessed via deep link without object
          return const Scaffold(body: Center(child: Text('Product not found')));
        }
        return ProductDetailScreen(product: product);
      },
    ),
    GoRoute(
      path: AppRoutes.addresses,
      builder: (context, state) => const AddressManagementScreen(),
    ),
    GoRoute(
      path: AppRoutes.category,
      name: 'category',
      builder: (context, state) {
        final categoryName = state.pathParameters['name'] ?? '';
        return CategoryProductsScreen(
          categoryName: categoryName,
          categoryColor: AppColors.primary, // Default fallback
          categoryIcon: Icons.category,     // Default fallback
        );
      },
    ),
  ],
);