/// App-wide utility functions
class AppUtils {
  /// Format price with rupee symbol
  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(0)}';
  }

  /// Format price with decimals
  static String formatPriceWithDecimals(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }

  /// Calculate discount percentage
  static int calculateDiscount(double currentPrice, double marketPrice) {
    if (marketPrice <= 0) return 0;
    return (((marketPrice - currentPrice) / marketPrice) * 100).round();
  }

  /// Format harvest time for display
  static String formatHarvestTime(String harvestTime) {
    if (harvestTime.isEmpty) return 'Fresh';
    return harvestTime;
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
