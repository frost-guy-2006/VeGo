import 'package:flutter/material.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'All', 'icon': Icons.grid_view},
    {'name': 'Vegetables', 'icon': Icons.eco_outlined},
    {'name': 'Fruits', 'icon': Icons.apple_outlined},
    {'name': 'Dairy', 'icon': Icons.local_drink_outlined},
    {'name': 'Munchies', 'icon': Icons.cookie_outlined},
    {'name': 'Cold Drinks', 'icon': Icons.local_bar_outlined},
    {'name': 'Instant', 'icon': Icons.ramen_dining_outlined},
    {'name': 'Bakery', 'icon': Icons.breakfast_dining_outlined},
    {'name': 'Tea/Coffee', 'icon': Icons.coffee_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        color: Colors.white,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 24),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = index == 0; // Default Select "All"
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat['icon'],
                  size: 28,
                  color: isSelected ? AppColors.textDark : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color:
                        isSelected ? AppColors.textDark : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(
                    height: 3,
                    width: 20,
                    decoration: BoxDecoration(
                      color: AppColors.textDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(height: 3),
              ],
            );
          },
        ),
      ),
    );
  }
}
