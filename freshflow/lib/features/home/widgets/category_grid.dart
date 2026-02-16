import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/category/screens/category_products_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryGrid extends StatefulWidget {
  final Function(String category)? onCategoryChanged;

  const CategoryGrid({super.key, this.onCategoryChanged});

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = -1;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Vegetables', 'icon': Icons.eco_rounded, 'color': 0xFF22C55E},
    {'name': 'Fruits', 'icon': Icons.spa_rounded, 'color': 0xFFE63946},
    {'name': 'Dairy', 'icon': Icons.local_drink_rounded, 'color': 0xFF3B82F6},
    {
      'name': 'Bakery',
      'icon': Icons.breakfast_dining_rounded,
      'color': 0xFFA3584E
    },
    {'name': 'Tea/Coffee', 'icon': Icons.coffee_rounded, 'color': 0xFF6D4C41},
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 64,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = index == _selectedIndex;
            final categoryColor = Color(cat['color'] as int);
            final categoryName = cat['name'] as String;
            final categoryIcon = cat['icon'] as IconData;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onCategoryChanged?.call(categoryName);

                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: CategoryProductsScreen(
                      categoryName: categoryName,
                      categoryColor: categoryColor,
                      categoryIcon: categoryIcon,
                    ),
                  ),
                );
              },
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      // Glass fill
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                categoryColor,
                                categoryColor.withValues(alpha: 0.8),
                              ],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFF1F2F4)),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? categoryColor.withValues(alpha: 0.6)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFD8DADF)),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: categoryColor.withValues(
                                    alpha: _glowAnimation.value * 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryIcon,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? context.textSecondary
                                  : categoryColor.withValues(alpha: 0.85)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoryName,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? context.textSecondary
                                    : context.textPrimary),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
