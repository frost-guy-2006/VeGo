import 'package:flutter/material.dart';
import 'package:freshflow/features/cart/screens/cart_screen.dart';
import 'package:freshflow/features/cart/widgets/floating_cart_bar.dart';
import 'package:freshflow/features/home/widgets/category_grid.dart';
import 'package:freshflow/features/profile/screens/profile_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freshflow/core/models/product_model.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:freshflow/features/home/widgets/flash_price_widget.dart';
import 'package:freshflow/features/home/widgets/price_comparison_card.dart';
import 'package:freshflow/features/home/widgets/rain_mode_overlay.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // Rain Mode toggle (Simulated)
  bool _isRaining = true;

  final List<Widget> _pages = [
    const HomeContent(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          // Hero Feature: Rain Mode Overlay
          if (_currentIndex == 0) RainModeOverlay(isEnabled: _isRaining),

          // Show floating cart bar only on Home tab (index 0)
          if (_currentIndex == 0)
            const Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: FloatingCartBar(),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_filled, 0),
            _buildNavItem(Icons.shopping_bag_outlined, 1),
            _buildNavItem(Icons.person_outline, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    // Consumer to show badge on Cart Icon if needed, but we have floating bar now
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.secondary,
        size: 28,
      ),
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Sticky Header with 10-min Delivery Badge
        SliverAppBar(
          pinned: true,
          floating: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          expandedHeight: 120, // Increased for badge
          toolbarHeight: 80,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black, // Zepto-like dark badge
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.yellow, size: 14),
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
                    'to Home',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'HSR Layout, Sector 2',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.secondary, size: 18),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.textDark),
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
          ],
        ),

        // Search Field
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.secondary),
                  const SizedBox(width: 12),
                  Text(
                    'Search "Paneer"',
                    style:
                        GoogleFonts.plusJakartaSans(color: AppColors.secondary),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Categories Grid (New)
        const SliverPadding(
          padding: EdgeInsets.symmetric(vertical: 16),
          sliver: CategoryGrid(),
        ),

        // Scrollable Flash Widgets
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: StreamBuilder<List<Product>>(
              stream: Supabase.instance.client
                  .from('products')
                  .stream(primaryKey: ['id'])
                  .limit(5)
                  .map((data) =>
                      data.map((item) => Product.fromJson(item)).toList()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: FlashPriceWidget(product: snapshot.data![index]),
                    );
                  },
                );
              },
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
                color: AppColors.textDark,
              ),
            ),
          ),
        ),

        // Product Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: StreamBuilder<List<Product>>(
            stream: Supabase.instance.client
                .from('products')
                .stream(primaryKey: ['id']).map((data) =>
                    data.map((item) => Product.fromJson(item)).toList()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('No products found',
                          style: GoogleFonts.plusJakartaSans(
                              color: AppColors.secondary)),
                    ),
                  ),
                );
              }

              return SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    child: PriceComparisonCard(product: snapshot.data![index]),
                  );
                },
              );
            },
          ),
        ),

        // Bottom Padding for Floating Bar
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
