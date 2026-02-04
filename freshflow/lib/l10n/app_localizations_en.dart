// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'VeGo';

  @override
  String get homePageTitle => 'Fresh Harvest';

  @override
  String get searchHint => 'Search \"Red\" or \"Tomato\"';

  @override
  String get deliveryIn => '10 MINS';

  @override
  String toAddress(String address) {
    return 'to $address';
  }

  @override
  String get addAddress => 'Add Address';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get checkout => 'Checkout';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logout => 'Log Out';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get password => 'Password';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get myWishlist => 'My Wishlist';

  @override
  String get myOrders => 'My Orders';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get errorLoadingProducts => 'Error loading products';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get retry => 'Retry';

  @override
  String get endOfList => 'You\'ve seen all products! 🎉';

  @override
  String itemAddedToCart(String productName) {
    return '$productName added to cart';
  }

  @override
  String totalPrice(String price) {
    return 'Total: ₹$price';
  }

  @override
  String discountOff(int percent) {
    return '$percent% OFF';
  }

  @override
  String harvestedAgo(String time) {
    return 'Harvested $time ago';
  }

  @override
  String get categories => 'Categories';

  @override
  String get all => 'All';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get fruits => 'Fruits';

  @override
  String get dairy => 'Dairy';

  @override
  String get bakery => 'Bakery';

  @override
  String get teaCoffee => 'Tea/Coffee';

  @override
  String get flashDeals => 'Flash Deals';

  @override
  String get orderPlaced => 'Order Placed Successfully!';

  @override
  String swapSaved(String amount) {
    return 'Swapped! You saved ₹$amount.';
  }
}
