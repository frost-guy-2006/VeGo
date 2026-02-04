/// Mobile design constants ensuring touch-friendly, accessible UI.
/// Based on Mobile Design skill requirements.
library;

import 'package:flutter/material.dart';

/// Touch target and spacing constants for mobile-first design.
///
/// Follow these guidelines from Mobile Design skill:
/// - Minimum touch target: 48px (per WCAG 2.1 AAA)
/// - Apple HIG recommends 44pt, Android recommends 48dp
/// - Always provide visual feedback on touch
abstract class MobileDesign {
  MobileDesign._();

  // ─────────────────────────────────────────────────────────────
  // TOUCH TARGETS
  // ─────────────────────────────────────────────────────────────

  /// Minimum touch target size per WCAG guidelines
  static const double minTouchTarget = 48.0;

  /// Comfortable touch target for primary actions
  static const double comfortableTouchTarget = 56.0;

  /// Large touch target for hero actions (CTA buttons)
  static const double largeTouchTarget = 64.0;

  // ─────────────────────────────────────────────────────────────
  // BUTTON HEIGHTS
  // ─────────────────────────────────────────────────────────────

  /// Primary button height (CTA, checkout, submit)
  static const double primaryButtonHeight = 56.0;

  /// Secondary button height
  static const double secondaryButtonHeight = 48.0;

  /// Chip/tag minimum height
  static const double chipMinHeight = 40.0;

  // ─────────────────────────────────────────────────────────────
  // ICON SIZES
  // ─────────────────────────────────────────────────────────────

  /// Small icon (in badges, chips)
  static const double iconSmall = 16.0;

  /// Default icon size
  static const double iconDefault = 24.0;

  /// Large icon (nav bar, hero actions)
  static const double iconLarge = 28.0;

  // ─────────────────────────────────────────────────────────────
  // SPACING
  // ─────────────────────────────────────────────────────────────

  /// Screen edge padding
  static const double screenPadding = 16.0;

  /// Large screen edge padding
  static const double screenPaddingLarge = 24.0;

  /// Vertical spacing between items
  static const double itemSpacing = 12.0;

  /// Section spacing
  static const double sectionSpacing = 24.0;

  // ─────────────────────────────────────────────────────────────
  // BORDER RADIUS
  // ─────────────────────────────────────────────────────────────

  /// Small radius (chips, badges)
  static const double radiusSmall = 8.0;

  /// Default radius (cards, inputs)
  static const double radiusDefault = 12.0;

  /// Large radius (modals, sheets)
  static const double radiusLarge = 16.0;

  /// Full round (pills, circular buttons)
  static const double radiusRound = 24.0;

  // ─────────────────────────────────────────────────────────────
  // SAFE AREA HELPERS
  // ─────────────────────────────────────────────────────────────

  /// Bottom padding for floating elements above system nav
  static const double floatingBottomPadding = 16.0;

  /// Extra padding for notched devices (can use MediaQuery for dynamic)
  static const double notchPadding = 44.0;

  // ─────────────────────────────────────────────────────────────
  // CONSTRAINTS
  // ─────────────────────────────────────────────────────────────

  /// Ensures widget meets minimum touch target
  static BoxConstraints get minTouchConstraints => const BoxConstraints(
        minWidth: minTouchTarget,
        minHeight: minTouchTarget,
      );

  /// Preferred constraints for list item rows
  static BoxConstraints get listItemConstraints => const BoxConstraints(
        minHeight: minTouchTarget,
      );
}

/// Extension for applying touch-friendly constraints to widgets
extension TouchFriendlyWidget on Widget {
  /// Wraps widget to ensure minimum touch target size
  Widget ensureTouchTarget() {
    return ConstrainedBox(
      constraints: MobileDesign.minTouchConstraints,
      child: this,
    );
  }
}
