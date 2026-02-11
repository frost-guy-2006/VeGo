import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:vego/core/providers/auth_provider.dart';
import 'package:vego/core/providers/theme_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/providers/order_provider.dart';
import 'package:vego/core/providers/address_provider.dart';
import 'package:vego/core/providers/product_provider.dart';
import 'package:vego/core/providers/cart_provider.dart';

/// Centralized provider configuration.
/// All app-wide providers are defined here for cleaner main.dart.
class AppProviders {
  AppProviders._();

  /// Returns all providers for the app.
  /// Returns all providers for the app.
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<WishlistProvider>(
            create: (_) => _createWishlistProvider()),
        ChangeNotifierProvider<OrderProvider>(
            create: (_) => _createOrderProvider()),
        ChangeNotifierProvider<AddressProvider>(
            create: (_) => _createAddressProvider()),
        ChangeNotifierProvider<ProductProvider>(
            create: (_) => _createProductProvider()),
      ];

  static WishlistProvider _createWishlistProvider() {
    return WishlistProvider();
  }

  static OrderProvider _createOrderProvider() {
    return OrderProvider();
  }

  static AddressProvider _createAddressProvider() {
    return AddressProvider();
  }

  static ProductProvider _createProductProvider() {
    final provider = ProductProvider();
    provider.initialize();
    return provider;
  }
}
