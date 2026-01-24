# FreshFlow Project Todo List

Based on `Prd.docx`, `DesignDoc.docx`, and `TechStack.docx`.
**Stack:** Flutter + Supabase (Chosen for Student/MVP efficiency as per TechStack reference).

## Phase 1: Setup & Foundation
- [ ] **Project Initialization**
    - [ ] Create new Flutter project `freshflow`.
    - [ ] Set up version control (Git).
    - [ ] Install dependencies: `supabase_flutter`, `google_fonts`, `flutter_map` (or Mapbox), `provider`/`bloc`.

- [ ] **Design System Implementation**
    - [ ] Define Color Palette:
        - [ ] Primary: #4C5273 (Steel Indigo)
        - [ ] Background: #F7F6F6 (Soft Cloud)
        - [ ] Text: #252837 (Gunmetal)
        - [ ] Secondary: #686E8F (Slate Blue)
        - [ ] Accent: #A3584E (Terracotta)
    - [ ] Configure Typography (Plus Jakarta Sans / Inter).
    - [ ] Create base UI widgets:
        - [ ] `PriceComparisonCard`
        - [ ] `FlashPriceWidget`
        - [ ] Custom Buttons (Circular "Add").

- [ ] **Backend Setup (Supabase)**
    - [ ] Create Supabase Project.
    - [ ] Define Database Schema:
        - [ ] `users` (Profile data)
        - [ ] `products` (Name, ImageURL, CurrentPrice, MarketPrice, HarvestTime, Stock)
        - [ ] `orders`
    - [ ] Setup Storage Buckets for high-def product images.

## Phase 2: Authentication (The Customer App)
- [ ] **Registration / Login**
    - [ ] Implement UI for OTP-based login (No email initially).
    - [ ] Integrate Supabase Auth (Phone Auth).
    - [ ] Handle session persistence.

## Phase 3: Core Features - Home & Discovery
- [ ] **Home Screen Layout**
    - [ ] Implement Sticky Header.
    - [ ] Create "Flash Price" Widget:
        - [ ] Gradient background (#4C5273 to #252837).
        - [ ] 3D effect (Image breaking bounds).
        - [ ] Countdown timer logic.
    - [ ] Implement Product Masonry Grid.

- [ ] **Product Listing Components**
    - [ ] Build `PriceComparisonCard`:
        - [ ] Image (Top 60%).
        - [ ] Price block (Current vs Strikethrough Market).
        - [ ] "Add" Floating Action Button.
    - [ ] Connect to Real-time inventory (Supabase).
    - [ ] Implement "Harvest Time" tags.

## Phase 4: Product Detail & Interaction
- [ ] **Product Detail Screen**
    - [ ] Hero Image transition.
    - [ ] detailed "Harvested at [Time]" display.
    - [ ] Price comparison bar chart implementation.

- [ ] **Shopping Cart**
    - [ ] Implement internal Cart State management.
    - [ ] Create Slide-up Bottom Sheet for Cart.
        - [ ] Blurred background effect.
    - [ ] "Slide to Pay" interaction.

## Phase 5: Supply Chain & Tracking
- [ ] **Order Tracking**
    - [ ] Integrate Map view (Mapbox/Flutter Map).
    - [ ] Display Real-time Rider location (Mocked or Real-time updates via Supabase).
    - [ ] ETA calculation display.

- [ ] **Checkout Logic**
    - [ ] One-tap checkout implementation.
    - [ ] Wallet integration mock/stub.

## Phase 6: Polish & Performance
- [ ] **Optimization**
    - [ ] Convert assets to `.webp` and `.svg`.
    - [ ] Ensure 60fps scrolling performance.
    - [ ] App size audit (< 20MB target).

- [ ] **Testing**
    - [ ] Verify Spoilage Rate logic (Stock updates).
    - [ ] Test UI on different screen sizes.
