import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from .env file.
/// SECURITY: Never hardcode secrets - use .env file (excluded from git).
class Env {
  Env._();

  /// Supabase project URL.
  static String get supabaseUrl {
    final value = dotenv.env['SUPABASE_URL'];
    if (value == null || value.isEmpty) {
      throw Exception('Missing SUPABASE_URL in .env configuration');
    }
    return value;
  }

  /// Supabase anonymous (public) key.
  /// Safe for client-side use - RLS policies restrict access.
  static String get supabaseAnonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY'];
    if (value == null || value.isEmpty) {
      throw Exception('Missing SUPABASE_ANON_KEY in .env configuration');
    }
    return value;
  }

  /// Check if environment is properly loaded.
  static bool get isLoaded =>
      dotenv.env['SUPABASE_URL'] != null &&
      dotenv.env['SUPABASE_URL']!.isNotEmpty &&
      dotenv.env['SUPABASE_ANON_KEY'] != null &&
      dotenv.env['SUPABASE_ANON_KEY']!.isNotEmpty;
}
