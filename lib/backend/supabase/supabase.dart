import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

export 'database/database.dart';

String _kSupabaseUrl = const String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://lfeyveflpbkrzsoscjcv.supabase.co',
);
String _kSupabaseAnonKey = const String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxmZXl2ZWZscGJrcnpzb3NjamN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2ODA0MDYsImV4cCI6MjA3NTI1NjQwNn0.-YOdUA6fTWhfdCnbWA0oDz3zcGq0zf2jpUS1LV00Z0o',
);

class SupaFlow {
  SupaFlow._();

  static SupaFlow? _instance;
  static SupaFlow get instance => _instance ??= SupaFlow._();

  final _supabase = Supabase.instance.client;
  static SupabaseClient get client => instance._supabase;

  static Future initialize() => Supabase.initialize(
        url: _kSupabaseUrl,
        headers: {
          'X-Client-Info': 'flutterflow',
        },
        anonKey: _kSupabaseAnonKey,
        debug: false,
        authOptions:
            FlutterAuthClientOptions(authFlowType: AuthFlowType.implicit),
      );
}
