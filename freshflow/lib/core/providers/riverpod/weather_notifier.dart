import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/services/weather_service.dart';

/// State for weather data.
class WeatherState {
  final WeatherData? data;
  final bool isLoading;
  final String? error;

  const WeatherState({this.data, this.isLoading = false, this.error});

  WeatherState copyWith({WeatherData? data, bool? isLoading, String? error}) =>
      WeatherState(
        data: data ?? this.data,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final WeatherService _service = WeatherService();

  WeatherNotifier() : super(const WeatherState()) {
    fetch();
  }

  Future<void> fetch({double? lat, double? lon}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getCurrentWeather(
        lat: lat ?? 22.5726,
        lon: lon ?? 88.3639,
      );
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      debugPrint('WeatherNotifier: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Categories recommended for the current weather.
  List<String> get recommendedCategories {
    if (state.data == null) return ['Vegetables', 'Fruits'];
    return WeatherService.recommendedCategories(state.data!);
  }
}

/// Riverpod provider for weather state.
final weatherProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier();
});
