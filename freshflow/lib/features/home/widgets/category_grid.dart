import 'package:flutter/material.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryGrid extends StatefulWidget {
  final Function(String category)? onCategoryChanged;

  const CategoryGrid({super.key, this.onCategoryChanged});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> categories = const [
    {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': 0xFF1B4332},
    {'name': 'Vegetables', 'icon': Icons.eco_rounded, 'color': 0xFF22C55E},
    {'name': 'Fruits', 'icon': Icons.spa_rounded, 'color': 0xFFE63946},
    {'name': 'Dairy', 'icon': Icons.local_drink_rounded, 'color': 0xFF3B82F6},
    {'name': 'Munchies', 'icon': Icons.cookie_rounded, 'color': 0xFFFF9F1C},
    {
      'name': 'Cold Drinks',
      'icon': Icons.local_bar_rounded,
      'color': 0xFF06B6D4
    },
    {
      'name': 'Instant',
      'icon': Icons.ramen_dining_rounded,
      'color': 0xFFF59E0B
    },
    {
      'name': 'Bakery',
      'icon': Icons.breakfast_dining_rounded,
      'color': 0xFFA3584E
    },
    {'name': 'Tea/Coffee', 'icon': Icons.coffee_rounded, 'color': 0xFF6D4C41},
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = index == _selectedIndex;
            final categoryColor = Color(cat['color'] as int);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onCategoryChanged?.call(cat['name'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? categoryColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? categoryColor.withValues(alpha: 0.3)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? categoryColor : AppColors.surfaceAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        size: 20,
                        color: isSelected ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat['name'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? categoryColor : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
