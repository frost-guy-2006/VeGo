import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/core/widgets/backgrounds.dart';

/// Tip section with frosted glass promotion banner and preset tip buttons.
class TipSectionWidget extends StatefulWidget {
  const TipSectionWidget({super.key});

  @override
  State<TipSectionWidget> createState() => _TipSectionWidgetState();
}

class _TipSectionWidgetState extends State<TipSectionWidget> {
  int? _selectedTip;

  final List<Map<String, dynamic>> _tipOptions = [
    {'emoji': '👋', 'amount': 20},
    {'emoji': '😊', 'amount': 30},
    {'emoji': '❤️', 'amount': 50},
    {'emoji': '🤩', 'amount': null}, // "Other"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: FrostedGlass(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Delivering happiness at\nyour doorstep!',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thank them by leaving a tip',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Decorative delivery icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Tip buttons row
            Row(
              children: _tipOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;
                final isSelected = _selectedTip == index;
                final amount = tip['amount'] as int?;
                final emoji = tip['emoji'] as String;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < _tipOptions.length - 1 ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTip = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : context.surfaceColor.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              amount != null ? '₹$amount' : 'Other',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            // Contextual kindness suggestion
            Row(
              children: [
                const Text('☀️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'It\'s a hot day! Show some kindness by offering a glass of water to your delivery partner',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: context.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
