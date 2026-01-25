# 🚀 FreshFlow App Demo Guide

This document outlines the key "Hero Features" implemented in FreshFlow, designed to showcase the modern, emotional, and efficient UX of the app. Use this guide to walk through the application during demos.

---

## 🌟 1. Home Screen & Discovery
**Goal:** Show off the minimalist aesthetic and visual discovery capabilities.

*   **Header**: Notice the compact, professional header with the "10 MINS" delivery badge.
*   **Horizontal Categories**: Swipe through the minimalist "Vegetables, Fruits, Dairy" bar. It uses outline icons and no background boxes for a cleaner look.
*   **Price Comparison Cards**: Browse the product grid.
    *   *Highlight:* The crossed-out "Market Price" vs. bold "Current Price" (e.g., ₹45 vs ₹60 for Tomatoes).
    *   *Highlight:* The vivid product images and "Harvested at..." timestamps.

## 🔍 2. Visual Search ("Blue Packet")
**Goal:** Demonstrate the "Visual Search" capability.

1.  Tap the **Search Bar** (Search "Red" or "Tomato").
2.  Type **"Red"**.
3.  **Observe:**
    *   The Header Theme turns **Red**.
    *   The results show red items like Tomatoes and Apples.
4.  Clear and type **"Blue"** or **"Green"** to see the theme adjust essentially instantly.

## 🛒 3. Cart Gamification
**Goal:** Show how we encourage higher order values.

1.  Add items to the cart using the **"+"** button on product cards.
2.  Go to the **Cart Tab** (Bottom Navigation).
3.  **Observe:** The **"Free Delivery" Progress Bar** at the bottom.
    *   *Action:* Add more items until the bar fills up and turns green ("Free Delivery Unlocked!").

## ⚡ 4. Smart Swaps (Upsell/Cross-sell)
**Goal:** Demonstrate helpful suggestions.

1.  Ensure you have a specific item in the cart (e.g., standard milk).
2.  *Note: Implementation relies on specific triggers, usually visible in the Cart or Checkout flow if "Better Option" is available.*
    *   *Focus:* If you see a "Smart Swap" banner, highlight how it saves money or offers a better product.

## ↩️ 5. The "Undo" Button
**Goal:** Show the anxiety-reducing post-purchase experience.

1.  Proceed to **Checkout** and "Slide to Pay".
2.  **IMMEDIATELY** after the order is placed, look at the bottom of the screen.
3.  **Observe:** A large red **"Undo Order"** button with a 60-second countdown.
    *   *Action:* Explain that this allows users to correct mistakes (wrong address, forgot item) without chatting with support.

## 📦 6. Granular Timeline & Tracking
**Goal:** Showcase the detailed, transparent order status.

1.  Let the "Undo" timer run out (or navigate to the **Tracking Screen**).
2.  **Observe:** The Granular Timeline at the bottom.
    *   Instead of just "Order Placed", it shows specific steps:
        *   "Packing Items (2 mins)"
        *   "Rider Assigned"
        *   "On the way"
3.  This transparency builds trust and reduces "Where is my order?" anxiety.

---

## 🌧️ Bonus: Rain Mode (Currently Disabled)
*   *Note:* The app supports a dynamic **"Rain Mode"** that adds a rain overlay and updates the delivery message to manage expectations. This can be re-enabled in `home_screen.dart` (`_isRaining = true`).

---

## 🛠️ Troubleshooting
*   **No Products?** If the home screen says "No products found", tap the **"Seed Database"** button to load the demo data immediately.
