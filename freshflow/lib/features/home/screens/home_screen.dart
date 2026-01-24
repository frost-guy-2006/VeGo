import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:freshflow/core/models/product_model.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:freshflow/features/home/widgets/flash_price_widget.dart';
import 'package:freshflow/features/home/widgets/price_comparison_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            expandedHeight: 100,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivering to',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'HSR Layout, Sector 2', // Mock Location
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                // Notification Icon
                icon: Stack(children: [
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.textDark),
                  Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: AppColors.accent, shape: BoxShape.circle),
                        constraints:
                            const BoxConstraints(minWidth: 12, minHeight: 12),
                      ))
                ]),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundColor: AppColors.secondary,
                radius: 18,
                backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=12'), // Mock Profile
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Search Field Placeholder
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.secondary),
                    const SizedBox(width: 12),
                    Text(
                      'Search fresh vegetables...',
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Flash Widgets
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                scrollDirection: Axis.horizontal,
                itemCount: 3, // Mock count
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: FlashPriceWidget(),
                  );
                },
              ),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fresh Harvest',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'See all',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

// ... (inside build)

          // Product Grid (Simulated Loading)
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: StreamBuilder<List<Product>>(
              stream: Supabase.instance.client
                  .from('products')
                  .stream(primaryKey: ['id']).map((data) =>
                      data.map((item) => Product.fromJson(item)).toList()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childCount: 4,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                  );
                }

                return SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 280,
                      child:
                          PriceComparisonCard(product: snapshot.data![index]),
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      // Bottom Navigation Bar Placeholder
      bottomNavigationBar: Container(
        height: 70,
        decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: const Icon(Icons.home_filled, color: AppColors.primary),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.shopping_bag_outlined,
                    color: AppColors.secondary),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.person_outline,
                    color: AppColors.secondary),
                onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
