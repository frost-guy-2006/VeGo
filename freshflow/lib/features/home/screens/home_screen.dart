import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vego/core/providers/riverpod/providers.dart';
import 'package:vego/features/cart/screens/cart_screen.dart';

import 'package:vego/features/home/widgets/category_grid.dart';
import 'package:vego/features/wishlist/screens/wishlist_screen.dart';
import 'package:vego/features/address/widgets/address_picker_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/home/widgets/flash_price_widget.dart';
import 'package:vego/features/home/widgets/price_comparison_card.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vego/features/home/widgets/floating_island_navigation.dart';
import 'package:vego/features/home/widgets/weather_recommendations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // Rain Mode toggle (Simulated)
  final bool _isRaining = false; // Disabled by default as per user request

  final List<Widget> _pages = [
    const HomeContent(),
    const CartScreen(),
    const WishlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // Hero Feature: Rain Mode Overlay
          if (_currentIndex == 0) RainModeOverlay(isEnabled: _isRaining),

          // Gradient Overlay at bottom for better visibility of the floating island
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      context.backgroundColor,
                      context.backgroundColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Island Navigation
          // Positioned at the bottom, centering itself
          SafeArea(
            child: FloatingIslandNavigation(
              selectedIndex: _currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
      // No standard BottomNavigationBar
    );
  }
}

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  late Future<List<Product>> _flashDealsFuture;

  // Pagination state
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _flashDealsFuture = _loadFlashDeals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Trigger load more when user scrolls near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productProvider.notifier).loadMoreProducts();
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _flashDealsFuture = _loadFlashDeals();
    });

    await ref.read(productProvider.notifier).loadProducts();
  }

  Future<List<Product>> _loadFlashDeals() async {
    return ref.read(productProvider.notifier).fetchFlashDeals();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      backgroundColor: context.backgroundColor,
      strokeWidth: 3,
      displacement: 60,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Sticky Header with 10-min Delivery Badge
          // Header with dynamic address and wishlist button
          Builder(
            builder: (context) {
              final addressState = ref.watch(addressProvider);
              final selectedAddress = addressState.defaultAddress;
              final addressLabel = selectedAddress?.label ?? 'Home';
              final addressText = selectedAddress != null
                  ? '${selectedAddress.city}, ${selectedAddress.state}'
                  : 'Add Address';

              return SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: context.backgroundColor,
                elevation: 0,
                expandedHeight: 72,
                toolbarHeight: 64,
                title: GestureDetector(
                  onTap: () {
                    // Show address picker sheet instead of full navigation
                    AddressPickerSheet.show(context);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.bolt,
                                    color: Colors.yellow, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '10 MINS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'to $addressLabel',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            addressText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              color: context.textSecondary, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: CircleAvatar(
                      backgroundColor: context.surfaceColor,
                      child: Icon(Icons.person_outline,
                          color: context.textPrimary),
                    ),
                    onPressed: () {
                      context.push('/profile');
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),

          // Search Field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16), // Removed vertical padding
              child: GestureDetector(
                onTap: () {
                  context.push('/search');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: context.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        'Search "Red" or "Tomato"', // Updated hint for discovery
                        style: GoogleFonts.plusJakartaSans(
                            color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Categories Bar (Horizontal)
          const CategoryGrid(),

          // Weather-Based Recommendations
          const SliverToBoxAdapter(
            child: WeatherRecommendations(),
          ),

          // Scrollable Flash Widgets
          SliverToBoxAdapter(
            child: Container(
              color: context.backgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                height: 200,
                child: FutureBuilder<List<Product>>(
                  future: _flashDealsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ListView.builder(
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child:
                              FlashPriceWidget(product: snapshot.data![index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Fresh Harvest',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
          ),

          // Product Grid - Now using paginated data
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _buildProductGrid(productState),
          ),

          // Loading indicator for pagination
          if (productState.isLoading && productState.products.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            ),

          // "Load more" indicator or "End of list" message
          if (!productState.hasMore && productState.products.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'You\'ve seen all products! 🎉',
                    style: GoogleFonts.plusJakartaSans(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Padding for Floating Bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildProductGrid(ProductState productState) {
    // Initial loading state
    if (productState.isLoading && productState.products.isEmpty) {
      return SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childCount: 4,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      );
    }

    // Error state
    if (productState.error != null && productState.products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading products',
                    style: GoogleFonts.plusJakartaSans(
                        color: context.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(productState.error!,
                    style: GoogleFonts.plusJakartaSans(
                        color: context.textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.read(productProvider.notifier).loadProducts(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Empty state
    if (productState.products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const Icon(Icons.shopping_basket_outlined,
                    size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('No products found',
                    style: GoogleFonts.plusJakartaSans(
                        color: context.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('Try searching for different products.',
                    style: GoogleFonts.plusJakartaSans(
                        color: context.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    // Products grid with pagination
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childCount: productState.products.length,
      itemBuilder: (context, index) {
        return SizedBox(
          child: PriceComparisonCard(
            product: productState.products[index],
            index: index,
          ),
        );
      },
    );
  }
}
