import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimal token storage facade. Update to secure storage as needed.
class TokenStorage {
  const TokenStorage(this._supabase) : _enabled = true;
  const TokenStorage.noop()
      : _supabase = null,
        _enabled = false;

  final SupabaseClient? _supabase;
  final bool _enabled;

  Future<void> saveTokens(String? accessToken, String? refreshToken) async {
    if (!_enabled) return;
    if (accessToken == null || refreshToken == null) return;
    try {
      // Supabase setSession expects a refresh token string or Session object
      // Using refreshToken to set the session
      await _supabase!.auth.setSession(refreshToken);
    } catch (e) {
      // Log error for debugging
      print('TokenStorage: Error saving tokens: $e');
    }
  }

  Future<void> clearTokens() async {
    if (!_enabled) return;
    try {
      await _supabase!.auth.signOut();
    } catch (_) {
      // ignore
    }
  }
}
