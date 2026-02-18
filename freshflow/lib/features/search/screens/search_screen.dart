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
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductRepository _productRepository = ProductRepository();
  List<Product> _searchResults = [];
  bool _isLoading = false;
  String? _activeColorFilter; // "Red", "Blue", etc.
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Use post frame callback to avoid setState during build if called synchronously?
    // Actually, initial query should probably be debounced or run immediately.
    // Usually initial query is passed from another screen, so we want results immediately.
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      // No debounce for initial query
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  // Visual Search Logic:
  // If query matches a color name, switch to "Visual Mode"
  Future<void> _performSearch(String query) async {
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
    String? matchedColor;

    // Iterate over keys to find a match
    for (var key in Product.colorKeywords.keys) {
      if (key.toLowerCase() == lowerQuery) {
        matchedColor = key;
        break;
      }
    }

    if (matchedColor != null) {
      _activeColorFilter = matchedColor;
    } else {
      _activeColorFilter = null;
    }

    try {
      List<Product> filtered;
      if (_activeColorFilter != null) {
        // Filter by inferred color using server-side search
        filtered = await _productRepository.searchProductsByColor(_activeColorFilter!);
      } else {
        // Filter by name using server-side search
        filtered = await _productRepository.searchProducts(query);
      }

      if (!mounted) return;

      // Check if the query has changed while we were awaiting
      if (_searchController.text != query) return;

      setState(() {
        _searchResults = filtered;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor = AppColors.primary;
    if (_activeColorFilter == 'Red') themeColor = Colors.red;
    if (_activeColorFilter == 'Green') themeColor = Colors.green;
    if (_activeColorFilter == 'Orange') themeColor = Colors.orange;
    if (_activeColorFilter == 'Blue') themeColor = Colors.blue;

    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
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
            color: context.textPrimary,
          ),
          onChanged: _onSearchChanged,
        ),
      ),
      body: Column(
        children: [
          // Visual Context Header (Hero Feature)
          if (_activeColorFilter != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: themeColor.withValues(alpha: 0.1),
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
                            color: themeColor.withValues(alpha: 0.4),
                            blurRadius: 8)
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
                          color: context.textPrimary,
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
