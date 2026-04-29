import 'package:flutter/foundation.dart';

/// Centralized analytics service for tracking user events.
///
/// Currently logs to debug console. Swap in Firebase Analytics,
/// Mixpanel, or a Supabase `events` table INSERT for production.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  void logEvent(String name, [Map<String, dynamic>? params]) {
    debugPrint('Analytics: $name ${params ?? ''}');
    // TODO: Replace with Firebase Analytics, Mixpanel, or Supabase events table
  }

  void logScreenView(String screenName) {
    logEvent('screen_view', {'screen': screenName});
  }

  void logAddToCart(String productId, String productName, double price) {
    logEvent('add_to_cart', {
      'product_id': productId,
      'name': productName,
      'price': price,
    });
  }

  void logRemoveFromCart(String productId) {
    logEvent('remove_from_cart', {'product_id': productId});
  }

  void logPurchase(String orderId, double total, int itemCount) {
    logEvent('purchase', {
      'order_id': orderId,
      'total': total,
      'items': itemCount,
    });
  }

  void logSearch(String query, int resultCount) {
    logEvent('search', {'query': query, 'results': resultCount});
  }

  void logCancelOrder(String orderId, String? reason) {
    logEvent('cancel_order', {
      'order_id': orderId,
      'reason': reason ?? 'none',
    });
  }
}
