import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static String get supabaseUrl =>
      const String.fromEnvironment('SUPABASE_URL');

  static String get supabasePublishableKey =>
      const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static void validate() {
    if (!isConfigured && kReleaseMode) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY build variables.',
      );
    }
  }
}
