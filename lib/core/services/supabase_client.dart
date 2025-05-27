import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseManager {
  static final SupabaseClient supabase = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Initialize Supabase - call this in main.dart
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }
  
  // Single bucket name
  static const String CHARACTERS_BUCKET = 'characters';
  
  // Get client shorthand
  static SupabaseClient get client => supabase;
}
