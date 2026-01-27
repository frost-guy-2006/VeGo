# VeGo 🥬
> *Fresh groceries delivered in 10 minutes.*

**VeGo** (formerly FreshFlow) is a premium grocery delivery application built with Flutter. It features a modern, nature-inspired design system, robust architecture, and a seamless user experience.

![VeGo Banner](https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=1200&q=80)

## ✨ Key Features

- **Premium UI/UX**: Custom design system with "Space Grotesk" typography, atmospheric backgrounds, and orchestrated animations.
- **Dark Mode**: Fully supported dark theme for late-night shopping.
- **Smart Cart**: Interactive cart with gamified delivery progress and image caching.
- **Wishlist**: Save your favorite items for later.
- **Order History**: Track your past orders with ease.
- **Address Management**: Manage multiple delivery addresses.
- **Optimized Performance**: 60 FPS scrolling, cached images, and efficient state management.

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **Backend /db**: Supabase
- **State Management**: Provider
- **Networking**: `cached_network_image`, Supabase Client
- **UI Libraries**: `google_fonts`, `shimmer`, `flutter_staggered_grid_view`, `page_transition`

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/vego.git
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    ```bash
    flutter run
    ```
    (Ensure you have a device connected or emulator running)

## 📂 Project Structure

```
lib/
├── core/               # Core shared components
│   ├── models/         # Data models (Product, Order, Address)
│   ├── providers/      # State management
│   ├── repositories/   # Data access layer
│   └── theme/          # App theme & colors
├── features/           # Feature-based folders
│   ├── auth/           # Login/Signup
│   ├── home/           # Home screen & widgets
│   ├── cart/           # Cart & Checkout
│   ├── profile/        # User profile & settings
│   └── product/        # Product details
└── main.dart           # Entry point
```

## 📸 Screenshots

| Home (Light) | Home (Dark) | Product Details |
|--------------|-------------|-----------------|
| <img src="docs/screenshots/home_light.png" width="200" /> | <img src="docs/screenshots/home_dark.png" width="200" /> | <img src="docs/screenshots/detail.png" width="200" /> |

---
*Built with ❤️ by the VeGo Team*
