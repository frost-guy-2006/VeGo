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

    try {
      // Load environment variables from .env file
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Error loading .env file: $e');
    }

    await _initSupabase();

    _initialized = true;
  }

  static Future<void> _initSupabase() async {
    try {
      final url = Env.supabaseUrl;
      final key = Env.supabaseAnonKey;

      if (url.isEmpty || key.isEmpty) {
        debugPrint('Supabase URL or Key is missing. Skipping initialization.');
        return;
      }

      await Supabase.initialize(
        url: url,
        anonKey: key,
      );
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
    }
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
