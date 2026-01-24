import 'package:flutter/material.dart';
import 'package:freshflow/core/constants/env.dart';
import 'package:freshflow/core/providers/auth_provider.dart';
import 'package:freshflow/features/auth/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/cart_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const FreshFlowApp());
}

class FreshFlowApp extends StatelessWidget {
  const FreshFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'FreshFlow',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              StreamBuilder<List<ConnectivityResult>>(
                stream: Connectivity().onConnectivityChanged,
                builder: (context, snapshot) {
                  final isOffline = snapshot.hasData && 
                                  snapshot.data!.contains(ConnectivityResult.none) &&
                                  snapshot.data!.length == 1; // Only 'none' present
                  
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
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            final session = Supabase.instance.client.auth.currentSession;
            return session != null ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
