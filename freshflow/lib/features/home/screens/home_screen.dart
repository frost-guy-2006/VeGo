import 'package:flutter/material.dart';
import 'package:freshflow/features/cart/screens/cart_screen.dart';
import 'package:freshflow/features/cart/widgets/floating_cart_bar.dart';
import 'package:freshflow/features/home/widgets/category_grid.dart';
import 'package:freshflow/features/search/screens/search_screen.dart'; // Added import
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
import 'package:freshflow/features/home/widgets/floating_bottom_nav_bar.dart';

import 'package:freshflow/core/services/notification_simulation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // Rain Mode toggle (Simulated)
  bool _isRaining = false; // Disabled by default as per user request

  String? _smartNudge;

  final List<Widget> _pages = [
    const HomeContent(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Check for smart nudge
    _smartNudge = NotificationSimulationService.getContextualNudge();
  }

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

          // Smart Notification Banner (Top)
          if (_smartNudge != null && _currentIndex == 0)
            Positioned(
              top: 40, // Below status bar
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withOpacity(0.8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active,
                          color: Colors.yellow, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _smartNudge!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _smartNudge = null),
                        child: const Icon(Icons.close,
                            color: Colors.white70, size: 18),
                      )
                    ],
                  ),
                ),
              ),
            ),

          // Floating Bottom Nav Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FloatingBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ),

          // Floating Cart Bar (Adjusted Position)
          if (_currentIndex == 0)
            const Positioned(
              bottom: 100, // Above Nav Bar
              left: 0,
              right: 0,
              child: FloatingCartBar(),
            ),
        ],
      ),
    );
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
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SearchScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ));
              },
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
                      'Search "Red" or "Tomato"', // Updated hint for discovery
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.secondary),
                    ),
                  ],
                ),
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
              if (snapshot.hasError) {
                debugPrint('Product Stream Error: ${snapshot.error}');
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Error loading products: ${snapshot.error}',
                          style:
                              GoogleFonts.plusJakartaSans(color: Colors.red)),
                    ),
                  ),
                );
              }

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
                      child: Column(
                        children: [
                          const Icon(Icons.shopping_basket_outlined,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text('No products found',
                              style: GoogleFonts.plusJakartaSans(
                                  color: AppColors
                                      .textDark, // Dark color for visibility
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text('Try running the seed script.',
                              style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.secondary, fontSize: 12)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _seedData,
                            icon: const Icon(Icons.cloud_upload, size: 16),
                            label: const Text('Seed Database'),
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

  Future<void> _seedData() async {
    try {
      // Data from seed_data.sql
      final data = [
        {
          'name': 'Fresh Tomatoes',
          'image_url':
              'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=300&q=80',
          'current_price': 45,
          'market_price': 60,
          'harvest_time': 'Harvested 2 hours ago',
          'stock': 100
        },
        {
          'name': 'Organic Carrots',
          'image_url':
              'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=300&q=80',
          'current_price': 60,
          'market_price': 85,
          'harvest_time': 'Harvested today morning',
          'stock': 50
        },
        {
          'name': 'Green Spinach',
          'image_url':
              'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80',
          'current_price': 30,
          'market_price': 45,
          'harvest_time': 'Harvested 4 hours ago',
          'stock': 30
        },
        {
          'name': 'Red Bell Pepper',
          'image_url':
              'https://images.unsplash.com/photo-1563565375-f3fdf5dbc240?auto=format&fit=crop&w=300&q=80',
          'current_price': 120,
          'market_price': 160,
          'harvest_time': 'Harvested yesterday',
          'stock': 40
        },
        {
          'name': 'Fresh Broccoli',
          'image_url':
              'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=300&q=80',
          'current_price': 85,
          'market_price': 120,
          'harvest_time': 'Harvested today',
          'stock': 60
        },
        {
          'name': 'Red Apples',
          'image_url':
              'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=300&q=80',
          'current_price': 180,
          'market_price': 220,
          'harvest_time': 'Fresh from Shimla',
          'stock': 80
        },
      ];

      await Supabase.instance.client.from('products').upsert(data);
      debugPrint('Database seeded successfully!');
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }
}
