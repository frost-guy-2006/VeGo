import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/constants/env.dart';

/// Application initialization service.
/// Handles all one-time setup before the app runs.
class AppInitializer {
  AppInitializer._();

  static bool _initialized = false;

  /// Initialize all required services for the app.
  /// Call this before runApp().
  static Future<void> initialize() async {
    if (_initialized) return;

    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables from .env file
    await dotenv.load(fileName: '.env');

    // Fail fast if critical config is missing
    if (!Env.isLoaded) {
      throw Exception(
        'Critical Error: Environment variables not loaded. '
        'Ensure .env file exists and contains SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    await _initSupabase();

    _initialized = true;
  }

  static Future<void> _initSupabase() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  }
}

/// Global error handler for uncaught exceptions.
/// Wraps the app in error catching zones.
class GlobalErrorHandler {
  GlobalErrorHandler._();

  /// Run the app with global error catching.
  static void runAppWithErrorHandling(Widget app) {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Handle errors outside Flutter framework
    runZonedGuarded(
      () => runApp(app),
      (error, stackTrace) {
        _logError(error, stackTrace);
      },
    );
  }

  static void _logError(Object error, StackTrace? stackTrace) {
    // In debug mode, print to console
    if (kDebugMode) {
      debugPrint('=== UNCAUGHT ERROR ===');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
      debugPrint('======================');
    }

    // TODO: In production, send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
  }
}
