import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/search/screens/search_screen.dart';

/// Search bar widget for home screen.
/// Taps navigate to search screen with fade transition.
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GestureDetector(
          onTap: () => _navigateToSearch(context),
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
                  'Search "Red" or "Tomato"',
                  style:
                      GoogleFonts.plusJakartaSans(color: AppColors.secondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SearchScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }
}
