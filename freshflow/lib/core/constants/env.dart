import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from .env file.
/// SECURITY: Never hardcode secrets - use .env file (excluded from git).
class Env {
  Env._();

  /// Supabase project URL.
  static String get supabaseUrl {
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  /// Supabase anonymous (public) key.
  /// Safe for client-side use - RLS policies restrict access.
  static String get supabaseAnonKey {
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  /// Check if environment is properly loaded.
  static bool get isLoaded =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
