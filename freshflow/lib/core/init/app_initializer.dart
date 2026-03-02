import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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

    if (!Env.isLoaded) {
      throw Exception('Missing required environment variables. Please check .env file.');
    }

    await _initSupabase();
    await _initSentry();

    _initialized = true;
  }

  static Future<void> _initSentry() async {
    if (Env.sentryDsn.isNotEmpty) {
      await SentryFlutter.init(
        (options) {
          options.dsn = Env.sentryDsn;
          options.tracesSampleRate = 1.0;
        },
      );
    }
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

    if (!kDebugMode && Env.sentryDsn.isNotEmpty) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    }
  }
}
