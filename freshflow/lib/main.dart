import 'package:flutter/material.dart';
import 'package:vego/core/constants/env.dart';
import 'package:vego/core/providers/auth_provider.dart';
import 'package:vego/core/providers/theme_provider.dart';
import 'package:vego/features/auth/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/cart_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const VeGoApp());
}

class VeGoApp extends StatelessWidget {
  const VeGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'VeGo',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return Stack(
                children: [
                  if (child != null) child,
                  StreamBuilder<List<ConnectivityResult>>(
                    stream: Connectivity().onConnectivityChanged,
                    builder: (context, snapshot) {
                      final isOffline = snapshot.hasData &&
                          (snapshot.data!.contains(ConnectivityResult.none) ||
                              snapshot.data!.isEmpty);

                      if (isOffline) {
                        return Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Material(
                            color: Colors.red,
                            child: SafeArea(
                              top: false,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: const Text(
                                  'No Internet Connection',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              );
            },
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                // Check for existing session
                return auth.isAuthenticated
                    ? const HomeScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
