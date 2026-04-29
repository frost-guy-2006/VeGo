import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Weather data model parsed from Open-Meteo API.
class WeatherData {
  final double temperature;
  final int weatherCode;

  const WeatherData({required this.temperature, required this.weatherCode});

  /// Map WMO weather codes to simple condition strings.
  String get condition {
    if (weatherCode <= 3) return 'sunny';
    if (weatherCode <= 48) return 'cloudy';
    if (weatherCode <= 67) return 'rainy';
    if (weatherCode <= 77) return 'snowy';
    return 'stormy';
  }

  bool get isRainy => condition == 'rainy' || condition == 'stormy';
  bool get isHot => temperature >= 30;
  bool get isCold => temperature <= 15;
}

/// Service for fetching real-time weather data.
///
/// Uses Open-Meteo (free, no API key needed) for MVP.
class WeatherService {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Cached weather data to avoid excessive API calls.
  WeatherData? _cache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 30);

  /// Fetch current weather for the given coordinates.
  /// Defaults to Kolkata (22.57°N, 88.36°E).
  Future<WeatherData> getCurrentWeather({
    double lat = 22.5726,
    double lon = 88.3639,
  }) async {
    // Return cached data if still fresh
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cache!;
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lon&current_weather=true',
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        throw Exception('Weather API returned ${response.statusCode}');
      }

      final json = jsonDecode(response.body);
      final current = json['current_weather'];
      final data = WeatherData(
        temperature: (current['temperature'] as num).toDouble(),
        weatherCode: current['weathercode'] as int,
      );

      _cache = data;
      _cacheTime = DateTime.now();
      return data;
    } catch (e) {
      debugPrint('WeatherService: Error fetching weather: $e');
      // Return a safe default if the API fails
      return const WeatherData(temperature: 30, weatherCode: 0);
    }
  }

  /// Map weather condition to recommended product categories.
  static List<String> recommendedCategories(WeatherData weather) {
    if (weather.isRainy) {
      return ['Dairy', 'Bakery']; // Comfort food
    }
    if (weather.isHot) {
      return ['Fruits']; // Cool off
    }
    if (weather.isCold) {
      return ['Dairy', 'Bakery']; // Warm up
    }
    return ['Vegetables', 'Fruits']; // Default seasonal
  }
}
