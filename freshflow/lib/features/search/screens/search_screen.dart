import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/home/widgets/price_comparison_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final ProductRepository? productRepository;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.productRepository,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final ProductRepository _productRepository;
  List<Product> _searchResults = [];
  bool _isLoading = false;
  String? _activeColorFilter; // "Red", "Blue", etc.
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _productRepository = widget.productRepository ?? ProductRepository();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Visual Search Logic:
  // If query matches a color name, switch to "Visual Mode"
  void _performSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _activeColorFilter = null;
        });
        return;
      }

      setState(() => _isLoading = true);

      // Check for color keywords
      final lowerQuery = query.toLowerCase();
      if (['red', 'blue', 'green', 'orange', 'yellow'].contains(lowerQuery)) {
        _activeColorFilter = lowerQuery;
        // Capitalize first letter for display
        _activeColorFilter =
            lowerQuery[0].toUpperCase() + lowerQuery.substring(1);
      } else {
        _activeColorFilter = null;
      }

      try {
        List<Product> results;
        if (_activeColorFilter != null) {
          // Optimized: Use server-side filtering for color mapping
          results = await _productRepository
              .searchProductsByColor(_activeColorFilter!);
        } else {
          // Optimized: Use server-side filtering for name search
          results = await _productRepository.searchProducts(query);
        }

        if (!mounted) return;
        // Check for race condition: if query changed while fetching
        if (_searchController.text != query) return;

        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      } catch (e) {
        debugPrint('Search error: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = AppColors.primary;
    if (_activeColorFilter == 'Red') themeColor = Colors.red;
    if (_activeColorFilter == 'Green') themeColor = Colors.green;
    if (_activeColorFilter == 'Orange') themeColor = Colors.orange;
    if (_activeColorFilter == 'Blue') themeColor = Colors.blue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search "Red" or "Tomato"',
            border: InputBorder.none,
            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeColor,
          ),
          onChanged: (val) {
            // Debounce could be added here
            _performSearch(val);
          },
        ),
      ),
      body: Column(
        children: [
          // Visual Context Header (Hero Feature)
          if (_activeColorFilter != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: themeColor.withOpacity(0.1),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: themeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: themeColor.withOpacity(0.4), blurRadius: 8)
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visual Search Active',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Showing $_activeColorFilter Products',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 64, color: Colors.grey),
                            Text('No items found',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey)),
                          ],
                        ),
                      )
                    : MasonryGridView.count(
                        padding: const EdgeInsets.all(16),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return PriceComparisonCard(
                              product: _searchResults[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
