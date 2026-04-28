# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VeGo is a premium grocery delivery mobile app built with Flutter/Dart. The Flutter project lives in `freshflow/`. Backend is Supabase (PostgreSQL, Auth, Realtime, Storage).

## Common Commands

All commands run from `freshflow/`:

```bash
# Install dependencies
flutter pub get

# Run app
flutter run              # connected device/emulator
flutter run -d chrome    # web

# Build
flutter build apk --release
flutter build web --release

# Tests
flutter test                           # all tests
flutter test test/unit_tests.dart      # single test file

# Code quality
flutter analyze
dart format lib/
dart fix --apply
```

## Architecture

### Feature-based structure (`lib/`)

- `core/` — shared logic: models, providers, repositories, theme, router, utils
- `features/` — feature modules (auth, home, cart, product, orders, profile, wishlist, search, address, tracking, category), each with `screens/` and `widgets/` subdirs
- `l10n/` — internationalization (code-generated via `flutter generate`)

### State management: Riverpod

All providers use `StateNotifierProvider` with immutable state classes. Import `core/providers/riverpod/providers.dart` (barrel file) to access all providers: `authProvider`, `productProvider`, `cartProvider`, `orderProvider`, `addressProvider`, `themeProvider`, `wishlistProvider`.

### Data layer: Repository pattern

Repositories in `core/repositories/` wrap Supabase queries. Each notifier delegates data fetching to its repository.

### Routing

`core/router/app_router.dart` defines GoRouter config with auth redirects. Route constants are in `AppRoutes`. However, `main.dart` currently uses `_AuthGate` (manual auth-based navigation) instead of GoRouter — both exist.

### Initialization

`AppInitializer.initialize()` in `core/init/app_initializer.dart` loads `.env` via `flutter_dotenv` and initializes the Supabase client. Runs before `runApp()`.

## Environment Setup

Create `freshflow/.env` (gitignored) with:

```
SUPABASE_URL=<your-supabase-url>
SUPABASE_ANON_KEY=<your-anon-key>
```

The `.env` file is bundled as a Flutter asset — it must exist for the app to start.

## Supabase Database

Tables: `products`, `orders`, `profiles`, `addresses` — all with Row-Level Security enabled. See `BACKEND.md` for full schema and RLS policies. Only the anon key is used in the app; never use the service role key client-side.

## Testing

Tests live in `freshflow/test/`. Uses `flutter_test` + `mocktail` for mocking. `SharedPreferences.setMockInitialValues({})` is needed before tests that touch local storage.

## Key Dependencies

- `supabase_flutter` — BaaS (auth, database, realtime)
- `flutter_riverpod` — state management
- `go_router` — declarative routing
- `shared_preferences` — cart/wishlist local persistence
- `flutter_dotenv` — env config
- `cached_network_image` — image caching
- `flutter_map` + `latlong2` — map display for order tracking
- `google_fonts` — typography (Space Grotesk, Outfit)
