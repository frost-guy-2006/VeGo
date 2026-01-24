# FreshFlow Project Todo List 2.0 (Post-MVP)

This list focuses on making the app production-ready by connecting real data, ensuring persistence, and polishing the UX.

## 1. 🔌 Connect Real Data (Critical)
- [x] **Database Setup (Supabase)**
    - [x] Create `products` table (id, name, price, market_price, image_url, stock, harvest_time).
    - [ ] Create `orders` table.
- [x] **Fetching Data**
    - [x] Update `HomeScreen` to fetch products via `FutureBuilder` or `StreamBuilder`.
    - [x] Remove mock data from `product_model.dart`.
- [x] **Real-time Inventory**
    - [x] Listen to `stock` changes using Supabase Realtime.
    - [x] Auto-disable "Add" button when stock hits 0.

## 2. 💾 Cart Persistence
- [x] **Local Storage**
    - [x] Add `shared_preferences` or `hive` dependency.
    - [x] Update `CartProvider` to save cart items to local storage on change.
    - [x] Load saved cart items on app startup.

## 3. 🗺️ Real-World Tracking
- [x] **Route Visualization**
    - [x] Integrate OSRM or Google Routes API for real polyline navigation.
    - [x] Replace straight-line polyline with actual road path.
- [x] **Live Updates**
    - [x] Create a mechanism (or mock stream) to update Rider position dynamically over time.

## 4. ✨ UI/UX Polish
- [x] **Interactions**
    - [x] Implement "Slide to Pay" using a dedicated package (e.g., `slider_button`) instead of a button.
    - [x] Add "Shimmer" loading skeletons for product images.
- [x] **Input Handling**
    - [x] Add validation for Phone Number format.
    - [x] handle "OTP Resend" timer.

## 5. 🛡️ Robustness
- [x] **Offline Mode**
    - [x] Handle connectivity loss gracefully (Connectivity Plus package).
    - [x] Show "No Internet" UI instead of crashes.
