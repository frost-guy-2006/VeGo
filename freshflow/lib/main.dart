import 'package:flutter/material.dart';
import 'package:freshflow/core/constants/env.dart';
import 'package:freshflow/core/providers/auth_provider.dart';
import 'package:freshflow/features/auth/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/cart_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
