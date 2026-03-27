import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from .env file.
/// SECURITY: Never hardcode secrets - use .env file (excluded from git).
class Env {
  Env._();

  /// Supabase project URL.
  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_URL')
          : (dotenv.env['SUPABASE_URL'] ?? '');

  /// Supabase anonymous (public) key.
  /// Safe for client-side use - RLS policies restrict access.
  static String get supabaseAnonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  /// Check if environment is properly loaded.
  static bool get isLoaded =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
