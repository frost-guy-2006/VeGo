import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/riverpod/providers.dart';
import 'package:vego/core/services/weather_service.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/product/screens/product_detail_screen.dart';

/// Weather-aware product recommendations for the home screen.
///
/// Reads live weather from [weatherProvider], maps the condition to
/// product categories, and shows a horizontal product strip.
class WeatherRecommendations extends ConsumerWidget {
  const WeatherRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final productState = ref.watch(productProvider);

    if (weatherState.isLoading) return _buildShimmer(context);
    final weather = weatherState.data;
    if (weather == null) return const SizedBox.shrink();

    final cats = ref.read(weatherProvider.notifier).recommendedCategories;
    final products = productState.products
        .where((p) => p.category != null && cats.contains(p.category))
        .take(8)
        .toList();

    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: weather badge + title + subtitle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: _gradientFor(weather.condition),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_emojiFor(weather.condition),
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${weather.temperature.round()}°C',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _titleFor(weather),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _subtitleFor(weather),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Horizontal product strip
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) =>
                _WeatherProductCard(product: products[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String _emojiFor(String c) {
    switch (c) {
      case 'sunny':
        return '☀️';
      case 'cloudy':
        return '☁️';
      case 'rainy':
        return '🌧️';
      case 'snowy':
        return '❄️';
      case 'stormy':
        return '⚡';
      default:
        return '🌤️';
    }
  }

  String _titleFor(WeatherData w) {
    if (w.isHot) return 'Beat the Heat';
    if (w.isRainy) return 'Rainy Day Cravings';
    if (w.isCold) return 'Warm Up Today';
    if (w.condition == 'sunny') return 'Sunny Day Picks';
    if (w.condition == 'cloudy') return 'Cloudy Day Comfort';
    return 'Weather Picks';
  }

  String _subtitleFor(WeatherData w) {
    if (w.isHot) return 'Cool off with fresh fruits and light bites';
    if (w.isRainy) return 'Perfect weather for comfort food';
    if (w.isCold) return 'Warm up with dairy and baked goods';
    if (w.condition == 'sunny') return 'Light and refreshing picks for today';
    return "Curated for today's weather";
  }

  LinearGradient _gradientFor(String c) {
    switch (c) {
      case 'sunny':
        return const LinearGradient(
            colors: [AppColors.weatherSunnyStart, AppColors.weatherSunnyEnd]);
      case 'cloudy':
        return const LinearGradient(
            colors: [AppColors.weatherCloudyStart, AppColors.weatherCloudyEnd]);
      case 'rainy':
        return const LinearGradient(
            colors: [AppColors.weatherRainyStart, AppColors.weatherRainyEnd]);
      case 'snowy':
        return const LinearGradient(
            colors: [AppColors.weatherSnowyStart, AppColors.weatherSnowyEnd]);
      case 'stormy':
        return const LinearGradient(
            colors: [AppColors.weatherNightStart, AppColors.weatherNightEnd]);
      default:
        return const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primary]);
    }
  }
}

/// Compact product card for the horizontal weather strip.
class _WeatherProductCard extends StatelessWidget {
  final Product product;
  const _WeatherProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final discount = product.marketPrice > 0
        ? (((product.marketPrice - product.currentPrice) /
                    product.marketPrice) *
                100)
            .round()
        : 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[200]),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 24),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹${product.currentPrice.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (discount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '$discount% off',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
