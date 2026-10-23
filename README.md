# VeGo 🥬 (FreshFlow)
> *Fresh groceries delivered in 10 minutes.*

**VeGo** (formerly FreshFlow) is a premium quick-commerce grocery delivery application built with Flutter. It features a modern, nature-inspired design system, robust architecture, and a seamless user experience.

![VeGo Banner](https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=1200&q=80)

---

## 📱 Android APK Download
Try out VeGo directly on your Android phone!
Download the latest APK from the **[GitHub Releases](https://github.com/frost-guy-2006/V1/releases)** page:
* **FreshFlow-Release.apk** (Universal Android APK)

---

## ✨ Key Features

- **Premium UI/UX**: Custom design system with "Space Grotesk" & "Plus Jakarta Sans" typography, atmospheric backgrounds, and orchestrated animations.
- **Dark Mode**: Fully supported dark theme for late-night shopping.
- **Smart Cart**: Interactive cart with gamified delivery progress, image caching, and order undo restoration.
- **💳 YouPI-PG Payment Gateway**: Integrated [YouPI-PG](https://github.com/youpi-pg/YouPI-PG) self-hosted 0% fee payments:
  - **UPI Intent**: Direct deep linking into Google Pay, PhonePe, Paytm, BHIM, CRED.
  - **Dynamic Vector QR Code**: On-screen generated QR with countdown timer.
  - **Cash on Delivery (COD)**: Doorstep cash payment with instant order placement.
  - **Sandbox / Demo Verification**: Simulated instant approval for showcase without requiring companion bank nodes.
- **Order Tracking**: Visual road route mapping (OSRM) with live status updates.
- **Order History & Sync**: Automatically synchronizes and caches user orders with Supabase.
- **Address Management**: Location picker and multiple delivery addresses.
- **Optimized Performance**: 60 FPS scrolling, cached images, and clean state management.

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.38 (Dart 3.10)
- **Backend / Database**: Supabase (PostgreSQL, Auth, Storage)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Navigation & Routing**: GoRouter (`go_router`)
- **Payment Gateway**: YouPI-PG (`url_launcher`, `qr_flutter`)
- **Mapping & Geolocation**: `flutter_map`, `latlong2`
- **UI Libraries**: `google_fonts`, `shimmer`, `flutter_staggered_grid_view`, `cached_network_image`, `slide_to_act`

---

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/frost-guy-2006/V1.git
   cd V1/freshflow
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run tests & analysis**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```
freshflow/
├── lib/
│   ├── core/               # Shared core components
│   │   ├── models/         # Data models (Product, Order, Address)
│   │   ├── providers/      # Riverpod providers (Cart, Order, Auth, Theme)
│   │   ├── repositories/   # Data access layer
│   │   ├── services/       # YouPI-PG payment, analytics, weather
│   │   └── theme/          # App theme & colors
│   ├── features/           # Feature modules
│   │   ├── auth/           # Login/Signup/OTP
│   │   ├── home/           # Home screen & category grids
│   │   ├── cart/           # Cart, checkout & YouPI-PG payment sheet
│   │   ├── tracking/       # Live order delivery tracking
│   │   ├── profile/        # User profile & settings
│   │   └── product/        # Product details
│   └── main.dart           # App entry point
```

---

*Built with ❤️ by the VeGo Team*
