import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/init/app_initializer.dart';
import 'package:vego/core/init/app_providers.dart';
import 'package:vego/core/providers/auth_provider.dart';
import 'package:vego/core/providers/address_provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/order_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/providers/theme_provider.dart';
import 'package:vego/core/theme/app_theme.dart';
import 'package:vego/l10n/app_localizations.dart';
import 'package:vego/features/auth/screens/login_screen.dart';
import 'package:vego/features/home/screens/home_screen.dart';

Future<void> main() async {
  await AppInitializer.initialize();
  runApp(const VeGoApp());
}

class VeGoApp extends StatelessWidget {
  const VeGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'VeGo',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

/// Decides which screen to show based on auth state.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Initialize addresses for current user when auth state changes
        final currentUserId = auth.currentUser?.id;
        if (currentUserId != _lastUserId) {
          _lastUserId = currentUserId;
          // Schedule address initialization after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<AddressProvider>().initForUser(currentUserId);
              context.read<CartProvider>().initForUser(currentUserId);
              context.read<WishlistProvider>().initForUser(currentUserId);
              context.read<OrderProvider>().initForUser(currentUserId);
            }
          });
        }

        return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
