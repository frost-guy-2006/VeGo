import 'package:flutter/material.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Vegetables', 'color': Color(0xFFE8F5E9), 'icon': '🥦'},
    {'name': 'Fruits', 'color': Color(0xFFFFF3E0), 'icon': '🍎'},
    {'name': 'Dairy', 'color': Color(0xFFE3F2FD), 'icon': '🥛'},
    {'name': 'Munchies', 'color': Color(0xFFFFEBEE), 'icon': '🍿'},
    {'name': 'Cold Drinks', 'color': Color(0xFFE0F2F1), 'icon': '🥤'},
    {'name': 'Instant', 'color': Color(0xFFF3E5F5), 'icon': '🍜'},
    {'name': 'Bakery', 'color': Color(0xFFFFF8E1), 'icon': '🍞'},
    {'name': 'Tea/Coffee', 'color': Color(0xFFEFEBE9), 'icon': '☕'},
  ];

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final cat = categories[index];
            return Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cat['color'],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        cat['icon'],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
          childCount: categories.length,
        ),
      ),
    );
  }
}
