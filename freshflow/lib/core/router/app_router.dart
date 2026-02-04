import 'package:go_router/go_router.dart';
import 'package:vego/features/auth/screens/login_screen.dart';
import 'package:vego/features/home/screens/home_screen.dart';
import 'package:vego/features/cart/screens/cart_screen.dart';
import 'package:vego/features/profile/screens/profile_screen.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/features/orders/screens/order_history_screen.dart';
import 'package:vego/features/wishlist/screens/wishlist_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// App route paths as constants.
abstract class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String orders = '/orders';
  static const String wishlist = '/wishlist';
}

/// GoRouter configuration for the app.
/// Provides declarative routing with auth redirects.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final isLoggingIn = state.matchedLocation == AppRoutes.login;

    // If not logged in and not on login page, redirect to login
    if (!isLoggedIn && !isLoggingIn) {
      return AppRoutes.login;
    }

    // If logged in and on login page, redirect to home
    if (isLoggedIn && isLoggingIn) {
      return AppRoutes.home;
    }

    // No redirect needed
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
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
  ],
);
