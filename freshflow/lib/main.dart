import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/init/app_initializer.dart';
import 'package:vego/core/init/app_providers.dart';
import 'package:vego/core/providers/auth_provider.dart';
import 'package:vego/core/providers/theme_provider.dart';
import 'package:vego/core/theme/app_theme.dart';
// import 'package:vego/core/widgets/connectivity_overlay.dart';
import 'package:vego/features/auth/screens/login_screen.dart';
import 'package:vego/features/home/screens/home_screen.dart';

Future<void> main() async {
  await AppInitializer.initialize();
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
            // builder: (context, child) => ConnectivityOverlay(
            //   child: child ?? const SizedBox.shrink(),
            // ),
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

/// Decides which screen to show based on auth state.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
