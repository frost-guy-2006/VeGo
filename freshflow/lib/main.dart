import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/init/app_initializer.dart';
import 'package:vego/core/providers/riverpod/providers.dart';
import 'package:vego/core/theme/app_theme.dart';
import 'package:vego/core/router/app_router.dart';
import 'package:vego/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await AppInitializer.initialize();
    GlobalErrorHandler.runAppWithErrorHandling(const ProviderScope(child: VeGoApp()));
  } catch (e, stackTrace) {
    debugPrint('=== APP INITIALIZATION FAILED ===');
    debugPrint('Error: $e');
    debugPrint('StackTrace: $stackTrace');
    runApp(InitErrorApp(error: e.toString()));
  }
}

class VeGoApp extends ConsumerWidget {
  const VeGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    ref.listen(authProvider, (prev, next) {
      if (prev?.user?.id != next.user?.id) {
        ref.read(addressProvider.notifier).initForUser(next.user?.id);
      }
    });

    return MaterialApp.router(
      title: 'VeGo',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}

class InitErrorApp extends StatelessWidget {
  final String error;
  const InitErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.darkBg,
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