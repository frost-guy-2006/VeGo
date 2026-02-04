import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vego/features/cart/screens/cart_screen.dart';
import 'package:vego/features/cart/widgets/floating_cart_bar.dart';
import 'package:vego/features/home/widgets/category_grid.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/features/profile/screens/profile_screen.dart';
import 'package:vego/features/wishlist/screens/wishlist_screen.dart';
import 'package:vego/features/address/screens/address_management_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/providers/address_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/features/home/widgets/flash_price_widget.dart';
import 'package:vego/features/home/widgets/price_comparison_card.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
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
  final bool _isRaining = false; // Disabled by default as per user request

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
            _buildNavItem(Icons.home_rounded, Icons.home_outlined, 0),
            _buildNavItem(
                Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 1),
            _buildNavItem(Icons.person_rounded, Icons.person_outline, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData selectedIcon, IconData unselectedIcon, int index) {
    final isSelected = _currentIndex == index;
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        icon: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          color: isSelected ? AppColors.primary : AppColors.secondary,
          size: 28,
        ),
        onPressed: () {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Key to force rebuild of StreamBuilders on refresh
  Key _refreshKey = UniqueKey();

  late Future<List<Product>> _flashDealsFuture;

  // Pagination state
  final ProductRepository _productRepository = ProductRepository();
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _flashDealsFuture = _loadFlashDeals();
    _loadInitialProducts();
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
      _loadMoreProducts();
    }
  }

  Future<void> _loadInitialProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final products = await _productRepository.fetchProductsPaginated(
        page: 0,
        pageSize: ProductRepository.defaultPageSize,
      );

      setState(() {
        _products = products;
        _currentPage = 0;
        _hasMore = products.length >= ProductRepository.defaultPageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final newProducts = await _productRepository.fetchProductsPaginated(
        page: nextPage,
        pageSize: ProductRepository.defaultPageSize,
      );

      setState(() {
        _products.addAll(newProducts);
        _currentPage = nextPage;
        _hasMore = newProducts.length >= ProductRepository.defaultPageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _refreshKey = UniqueKey();
      _flashDealsFuture = _loadFlashDeals();
      _products = [];
      _currentPage = 0;
      _hasMore = true;
    });

    await _loadInitialProducts();
  }

  Future<List<Product>> _loadFlashDeals() async {
    final data =
        await Supabase.instance.client.from('products').select().limit(5);
    return data.map((item) => Product.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      strokeWidth: 3,
      displacement: 60,
      child: CustomScrollView(
        key: _refreshKey,
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Sticky Header with 10-min Delivery Badge
          // Header with dynamic address and wishlist button
          Consumer2<AddressProvider, WishlistProvider>(
            builder: (context, addressProvider, wishlistProvider, _) {
              final defaultAddress = addressProvider.defaultAddress;
              final addressLabel = defaultAddress?.label ?? 'Home';
              final addressText = defaultAddress != null
                  ? '${defaultAddress.city}, ${defaultAddress.state}'
                  : 'Add Address';
              final wishlistCount = wishlistProvider.itemCount;

              return SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                expandedHeight: 90,
                toolbarHeight: 70,
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressManagementScreen(),
                      ),
                    );
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
                              color: AppColors.textDark,
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
                              color: AppColors.secondary,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.secondary, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.favorite_outline,
                              color: AppColors.textDark),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WishlistScreen(),
                            ),
                          );
                        },
                      ),
                      if (wishlistCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              wishlistCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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

          // Categories Bar (Horizontal)
          const CategoryGrid(),

          // Scrollable Flash Widgets
          SliverToBoxAdapter(
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

          // Product Grid - Now using paginated data
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _buildProductGrid(),
          ),

          // Loading indicator for pagination
          if (_isLoading && _products.isNotEmpty)
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
          if (!_hasMore && _products.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'You\'ve seen all products! 🎉',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.secondary,
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

  Widget _buildProductGrid() {
    // Initial loading state
    if (_isLoading && _products.isEmpty) {
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
    if (_errorMessage != null && _products.isEmpty) {
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
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(_errorMessage!,
                    style: GoogleFonts.plusJakartaSans(
                        color: AppColors.secondary, fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadInitialProducts,
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
    if (_products.isEmpty) {
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
                        color: AppColors.textDark,
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

    // Products grid with pagination
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childCount: _products.length,
      itemBuilder: (context, index) {
        return SizedBox(
          child: PriceComparisonCard(
            product: _products[index],
            index: index,
          ),
        );
      },
    );
  }

  Future<void> _seedData() async {
    try {
      // Data from seed_data.sql with categories
      final data = [
        // Vegetables
        {
          'name': 'Fresh Tomatoes',
          'image_url':
              'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=300&q=80',
          'current_price': 45,
          'market_price': 60,
          'harvest_time': 'Harvested 2 hours ago',
          'stock': 100,
          'category': 'Vegetables'
        },
        {
          'name': 'Organic Carrots',
          'image_url':
              'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=300&q=80',
          'current_price': 60,
          'market_price': 85,
          'harvest_time': 'Harvested today morning',
          'stock': 50,
          'category': 'Vegetables'
        },
        {
          'name': 'Green Spinach',
          'image_url':
              'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80',
          'current_price': 30,
          'market_price': 45,
          'harvest_time': 'Harvested 4 hours ago',
          'stock': 30,
          'category': 'Vegetables'
        },
        {
          'name': 'Red Bell Pepper',
          'image_url':
              'https://images.unsplash.com/photo-1563565375-f3fdf5dbc240?auto=format&fit=crop&w=300&q=80',
          'current_price': 120,
          'market_price': 160,
          'harvest_time': 'Harvested yesterday',
          'stock': 40,
          'category': 'Vegetables'
        },
        {
          'name': 'Fresh Broccoli',
          'image_url':
              'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=300&q=80',
          'current_price': 85,
          'market_price': 120,
          'harvest_time': 'Harvested today',
          'stock': 60,
          'category': 'Vegetables'
        },
        {
          'name': 'Cucumber',
          'image_url':
              'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?auto=format&fit=crop&w=300&q=80',
          'current_price': 25,
          'market_price': 35,
          'harvest_time': 'Harvested 5 hours ago',
          'stock': 45,
          'category': 'Vegetables'
        },
        // Fruits
        {
          'name': 'Red Apples',
          'image_url':
              'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=300&q=80',
          'current_price': 180,
          'market_price': 220,
          'harvest_time': 'Fresh from Shimla',
          'stock': 80,
          'category': 'Fruits'
        },
        {
          'name': 'Bananas',
          'image_url':
              'https://images.unsplash.com/photo-1603833665858-e61d17a86271?auto=format&fit=crop&w=300&q=80',
          'current_price': 60,
          'market_price': 80,
          'harvest_time': 'Organic',
          'stock': 70,
          'category': 'Fruits'
        },
        {
          'name': 'Strawberries',
          'image_url':
              'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=300&q=80',
          'current_price': 250,
          'market_price': 300,
          'harvest_time': 'Freshly picked',
          'stock': 25,
          'category': 'Fruits'
        },
        {
          'name': 'Oranges',
          'image_url':
              'https://images.unsplash.com/photo-1547514354-9520a29f86b1?auto=format&fit=crop&w=300&q=80',
          'current_price': 100,
          'market_price': 140,
          'harvest_time': 'Juicy & Sweet',
          'stock': 60,
          'category': 'Fruits'
        },
        {
          'name': 'Mangoes',
          'image_url':
              'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=300&q=80',
          'current_price': 200,
          'market_price': 280,
          'harvest_time': 'Alphonso variety',
          'stock': 40,
          'category': 'Fruits'
        },
        // Dairy
        {
          'name': 'Fresh Milk',
          'image_url':
              'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=300&q=80',
          'current_price': 65,
          'market_price': 70,
          'harvest_time': 'Farm fresh daily',
          'stock': 100,
          'category': 'Dairy'
        },
        {
          'name': 'Greek Yogurt',
          'image_url':
              'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=300&q=80',
          'current_price': 120,
          'market_price': 150,
          'harvest_time': 'High protein',
          'stock': 50,
          'category': 'Dairy'
        },
        {
          'name': 'Cottage Cheese',
          'image_url':
              'https://images.unsplash.com/photo-1559561853-08451507cbe7?auto=format&fit=crop&w=300&q=80',
          'current_price': 180,
          'market_price': 220,
          'harvest_time': 'Fresh paneer',
          'stock': 35,
          'category': 'Dairy'
        },
        {
          'name': 'Butter',
          'image_url':
              'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=300&q=80',
          'current_price': 250,
          'market_price': 280,
          'harvest_time': 'Unsalted premium',
          'stock': 45,
          'category': 'Dairy'
        },
        // Bakery
        {
          'name': 'Whole Wheat Bread',
          'image_url':
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=300&q=80',
          'current_price': 45,
          'market_price': 55,
          'harvest_time': 'Baked fresh today',
          'stock': 80,
          'category': 'Bakery'
        },
        {
          'name': 'Croissants',
          'image_url':
              'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80',
          'current_price': 120,
          'market_price': 150,
          'harvest_time': 'Buttery & flaky',
          'stock': 30,
          'category': 'Bakery'
        },
        {
          'name': 'Chocolate Muffin',
          'image_url':
              'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?auto=format&fit=crop&w=300&q=80',
          'current_price': 80,
          'market_price': 100,
          'harvest_time': 'Double chocolate',
          'stock': 40,
          'category': 'Bakery'
        },
        {
          'name': 'Bagels',
          'image_url':
              'https://images.unsplash.com/photo-1558401391-7899b4bd5bbf?auto=format&fit=crop&w=300&q=80',
          'current_price': 60,
          'market_price': 80,
          'harvest_time': 'Plain & sesame',
          'stock': 50,
          'category': 'Bakery'
        },
        // Tea/Coffee
        {
          'name': 'Assam Tea',
          'image_url':
              'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=300&q=80',
          'current_price': 180,
          'market_price': 220,
          'harvest_time': 'Premium CTC',
          'stock': 60,
          'category': 'Tea/Coffee'
        },
        {
          'name': 'Green Tea',
          'image_url':
              'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?auto=format&fit=crop&w=300&q=80',
          'current_price': 250,
          'market_price': 300,
          'harvest_time': 'Japanese Sencha',
          'stock': 35,
          'category': 'Tea/Coffee'
        },
        {
          'name': 'Arabica Coffee',
          'image_url':
              'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=300&q=80',
          'current_price': 450,
          'market_price': 550,
          'harvest_time': 'Single origin',
          'stock': 25,
          'category': 'Tea/Coffee'
        },
        {
          'name': 'Earl Grey Tea',
          'image_url':
              'https://images.unsplash.com/photo-1594631252845-29fc4cc8cde9?auto=format&fit=crop&w=300&q=80',
          'current_price': 200,
          'market_price': 250,
          'harvest_time': 'Bergamot flavored',
          'stock': 40,
          'category': 'Tea/Coffee'
        },
      ];

      await Supabase.instance.client.from('products').upsert(data);
      debugPrint('Database seeded successfully!');
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }
}
