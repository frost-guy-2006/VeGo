import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/init/app_initializer.dart';
import 'package:vego/core/providers/riverpod/providers.dart';
import 'package:vego/core/theme/app_theme.dart';
import 'package:vego/l10n/app_localizations.dart';
import 'package:vego/features/auth/screens/login_screen.dart';
import 'package:vego/features/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppInitializer.initialize();
    runApp(const ProviderScope(child: VeGoApp()));
  } catch (e, stackTrace) {
    debugPrint('=== APP INITIALIZATION FAILED ===');
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');
    runApp(const InitErrorApp(error: 'App initialization failed'));
  }
}

class VeGoApp extends ConsumerWidget {
  const VeGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'VeGo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _AuthGate(),
    );
  }
}

/// Decides which screen to show based on auth state.
class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    // Initialize addresses for current user when auth state changes
    final currentUserId = authState.user?.id;
    if (currentUserId != _lastUserId) {
      _lastUserId = currentUserId;
      // Schedule address initialization after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(addressProvider.notifier).initForUser(currentUserId);
        }
      });
    }

    return authState.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}

/// Fallback app shown when initialization fails (e.g. no network, bad .env).
class InitErrorApp extends StatelessWidget {
  final String error;
  const InitErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Failed to start VeGo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => main(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
