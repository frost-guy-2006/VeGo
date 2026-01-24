# FreshFlow Project Todo List 2.0 (Post-MVP)

This list focuses on making the app production-ready by connecting real data, ensuring persistence, and polishing the UX.

## 1. 🔌 Connect Real Data (Critical)
- [ ] **Database Setup (Supabase)**
    - [ ] Create `products` table (id, name, price, market_price, image_url, stock, harvest_time).
    - [ ] Create `orders` table.
- [ ] **Fetching Data**
    - [ ] Update `HomeScreen` to fetch products via `FutureBuilder` or `StreamBuilder`.
    - [ ] Remove mock data from `product_model.dart`.
- [ ] **Real-time Inventory**
    - [ ] Listen to `stock` changes using Supabase Realtime.
    - [ ] Auto-disable "Add" button when stock hits 0.

## 2. 💾 Cart Persistence
- [ ] **Local Storage**
    - [ ] Add `shared_preferences` or `hive` dependency.
    - [ ] Update `CartProvider` to save cart items to local storage on change.
    - [ ] Load saved cart items on app startup.

## 3. 🗺️ Real-World Tracking
- [ ] **Route Visualization**
    - [ ] Integrate OSRM or Google Routes API for real polyline navigation.
    - [ ] Replace straight-line polyline with actual road path.
- [ ] **Live Updates**
    - [ ] Create a mechanism (or mock stream) to update Rider position dynamically over time.

## 4. ✨ UI/UX Polish
- [ ] **Interactions**
    - [ ] Implement "Slide to Pay" using a dedicated package (e.g., `slider_button`) instead of a button.
    - [ ] Add "Shimmer" loading skeletons for product images.
- [ ] **Input Handling**
    - [ ] Add validation for Phone Number format.
    - [ ] handle "OTP Resend" timer.

## 5. 🛡️ Robustness
- [ ] **Offline Mode**
    - [ ] Handle connectivity loss gracefully (Connectivity Plus package).
    - [ ] Show "No Internet" UI instead of crashes.
