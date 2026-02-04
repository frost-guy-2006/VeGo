import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Utility for delivery radius calculations and geolocation checks.
/// Implements Geo Fundamentals skill patterns.
class DeliveryRadiusHelper {
  DeliveryRadiusHelper._();

  /// Default delivery radius in kilometers.
  static const double defaultRadiusKm = 5.0;

  /// Maximum delivery radius in kilometers.
  static const double maxRadiusKm = 10.0;

  /// Store/warehouse location (example: central hub).
  /// In production, this would come from backend configuration.
  static const LatLng defaultHubLocation =
      LatLng(12.9716, 77.5946); // Bangalore

  /// Calculate distance between two points using Haversine formula.
  /// Returns distance in kilometers.
  static double calculateDistanceKm(LatLng from, LatLng to) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, from, to);
  }

  /// Check if a delivery address is within the serviceable radius.
  /// [customerLocation] - The customer's delivery address coordinates.
  /// [hubLocation] - The warehouse/store location (defaults to central hub).
  /// [radiusKm] - Maximum delivery radius in km (defaults to 5km).
  static bool isWithinDeliveryRadius({
    required LatLng customerLocation,
    LatLng? hubLocation,
    double radiusKm = defaultRadiusKm,
  }) {
    final hub = hubLocation ?? defaultHubLocation;
    final distanceKm = calculateDistanceKm(hub, customerLocation);
    return distanceKm <= radiusKm;
  }

  /// Get delivery time estimate based on distance.
  /// Returns estimated delivery time in minutes.
  static int getDeliveryTimeMinutes({
    required LatLng customerLocation,
    LatLng? hubLocation,
  }) {
    final hub = hubLocation ?? defaultHubLocation;
    final distanceKm = calculateDistanceKm(hub, customerLocation);

    // Base time + 2 min per km (simplified estimate)
    const int baseTimeMinutes = 5;
    const double minutesPerKm = 2.0;

    return baseTimeMinutes + (distanceKm * minutesPerKm).ceil();
  }

  /// Get delivery fee based on distance.
  /// Returns fee in rupees.
  static double getDeliveryFee({
    required LatLng customerLocation,
    LatLng? hubLocation,
  }) {
    final hub = hubLocation ?? defaultHubLocation;
    final distanceKm = calculateDistanceKm(hub, customerLocation);

    // Free delivery within 2km, then ₹10 per km
    if (distanceKm <= 2.0) return 0.0;

    const double feePerKm = 10.0;
    return ((distanceKm - 2.0) * feePerKm).ceilToDouble();
  }

  /// Check if location is valid (non-zero coordinates).
  static bool isValidLocation(LatLng location) {
    return location.latitude != 0.0 || location.longitude != 0.0;
  }

  /// Format distance for display (e.g., "2.5 km" or "800 m").
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Calculate bearing between two points (for navigation arrows).
  /// Returns bearing in degrees (0-360).
  static double calculateBearing(LatLng from, LatLng to) {
    final dLon = _toRadians(to.longitude - from.longitude);
    final lat1 = _toRadians(from.latitude);
    final lat2 = _toRadians(to.latitude);

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return (_toDegrees(math.atan2(y, x)) + 360) % 360;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
  static double _toDegrees(double radians) => radians * 180 / math.pi;
}

/// Result of a delivery eligibility check.
class DeliveryCheckResult {
  final bool isEligible;
  final double distanceKm;
  final int estimatedTimeMinutes;
  final double deliveryFee;
  final String message;

  DeliveryCheckResult({
    required this.isEligible,
    required this.distanceKm,
    required this.estimatedTimeMinutes,
    required this.deliveryFee,
    required this.message,
  });

  factory DeliveryCheckResult.check({
    required LatLng customerLocation,
    LatLng? hubLocation,
    double maxRadiusKm = DeliveryRadiusHelper.defaultRadiusKm,
  }) {
    final hub = hubLocation ?? DeliveryRadiusHelper.defaultHubLocation;
    final distanceKm =
        DeliveryRadiusHelper.calculateDistanceKm(hub, customerLocation);
    final isEligible = distanceKm <= maxRadiusKm;

    return DeliveryCheckResult(
      isEligible: isEligible,
      distanceKm: distanceKm,
      estimatedTimeMinutes: isEligible
          ? DeliveryRadiusHelper.getDeliveryTimeMinutes(
              customerLocation: customerLocation,
              hubLocation: hubLocation,
            )
          : 0,
      deliveryFee: isEligible
          ? DeliveryRadiusHelper.getDeliveryFee(
              customerLocation: customerLocation,
              hubLocation: hubLocation,
            )
          : 0,
      message: isEligible
          ? '🚀 Delivery available! ${DeliveryRadiusHelper.formatDistance(distanceKm)} away.'
          : '📍 Sorry, we don\'t deliver to this location yet.',
    );
  }
}
