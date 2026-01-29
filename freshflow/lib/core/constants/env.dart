class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xstagwqwesafzirsxhjw.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzdGFnd3F3ZXNhZnppcnN4aGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyNDM1NDAsImV4cCI6MjA4NDgxOTU0MH0.-dy7yonmaOf1brijFlzMiS75ve99aeTPiih0CFoxncU',
  );
}
