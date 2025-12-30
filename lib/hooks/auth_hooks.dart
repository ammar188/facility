import 'dart:developer';

import 'package:facility/app/auth/token_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Flutter-style hooks for Supabase authentication
/// Matches the React hooks pattern from the reference implementation
class AuthHooks {
  AuthHooks({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Format phone number to E.164 format
  /// Handles various input formats and converts to +92XXXXXXXXXX
  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    
    // Remove all spaces, dashes, and parentheses but keep + for now
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '').trim();
    
    // If already starts with +92, return as is
    if (cleaned.startsWith('+92')) {
      return cleaned;
    }
    
    // If starts with 92 (without +), add +
    if (cleaned.startsWith('92') && cleaned.length >= 12) {
      return '+$cleaned';
    }
    
    // If starts with 0 (local format like 03001234567), remove 0 and add +92
    if (cleaned.startsWith('0') && cleaned.length >= 11) {
      return '+92${cleaned.substring(1)}';
    }
    
    // If starts with + but not +92, return as is (might be different country)
    if (cleaned.startsWith('+')) {
      return cleaned;
    }
    
    // Default: assume it's a local number without country code, add +92
    if (cleaned.isNotEmpty) {
      // Remove leading 0 if present
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      return '+92$cleaned';
    }
    
    return phone; // Fallback: return original
  }

  /// Login hook - calls supabase.auth.signInWithPassword({ phone, password })
  /// Matches: useLogin from React implementation
  Future<Map<String, dynamic>> useLogin({
    required String phone,
    required String password,
  }) async {
    try {
      log('🔐 useLogin: Starting login', name: 'AuthHooks');
      log('  Original phone: $phone', name: 'AuthHooks');
      
      // Format phone number to E.164 format
      final formattedPhone = _formatPhoneNumber(phone);
      log('  Formatted phone: $formattedPhone', name: 'AuthHooks');
      
      log('🚀 DIRECT SUPABASE CALL - signInWithPassword', name: 'AuthHooks');
      log('  Calling: _supabase.auth.signInWithPassword() directly', name: 'AuthHooks');
      
      // Call Supabase signInWithPassword
      log('  Attempting signInWithPassword with:', name: 'AuthHooks');
      log('    phone: $formattedPhone', name: 'AuthHooks');
      log('    password length: ${password.length}', name: 'AuthHooks');
      
      final response = await _supabase.auth.signInWithPassword(
        phone: formattedPhone,
        password: password,
      );
      
      log('✅ useLogin: Success - User ID: ${response.user?.id}', name: 'AuthHooks');
      
      // Verify token is available
      if (response.session?.accessToken != null) {
        final tokenPreview = response.session!.accessToken.substring(0, 20) + '...';
        log('  Access token available: $tokenPreview', name: 'AuthHooks');
      } else {
        log('  ⚠️ No access token in session after login', name: 'AuthHooks');
      }
      
      // Save tokens using TokenStorage
      final tokenStorage = TokenStorage(_supabase);
      await tokenStorage.saveTokens(
        response.session?.accessToken,
        response.session?.refreshToken,
      );
      
      return {
        'success': true,
        'data': {
          'accessToken': response.session?.accessToken,
          'refreshToken': response.session?.refreshToken,
          'user': {
            'id': response.user?.id,
            'email': response.user?.email,
            'phone': response.user?.phone,
          },
        },
      };
    } catch (e) {
      log('❌ useLogin: Error - $e', name: 'AuthHooks', error: e);
      
      // Extract better error message from Supabase exceptions
      String errorMessage = 'Login failed';
      final errorStr = e.toString();
      
      // Check for specific Supabase error types
      if (e is AuthException) {
        errorMessage = e.message;
        log('  AuthException message: $errorMessage', name: 'AuthHooks');
      } else if (errorStr.contains('Invalid login credentials') || 
                 errorStr.contains('Invalid credentials')) {
        // Simple, clear message for invalid phone/password
        errorMessage = 'Invalid phone number or password.';
      } else if (errorStr.contains('Email not confirmed')) {
        errorMessage = 'Please verify your email first';
      } else if (errorStr.contains('User not found')) {
        errorMessage = 'No account found with this phone number';
      } else if (errorStr.contains('Password')) {
        errorMessage = 'Invalid password. If you registered with OTP, you may need to set a password first.';
      } else {
        // Try to extract a cleaner error message
        errorMessage = errorStr
            .replaceAll('Exception: ', '')
            .replaceAll('AuthException: ', '')
            .replaceAll('GotrueException: ', '')
            .split('\n')
            .first
            .trim();
        if (errorMessage.isEmpty) {
          errorMessage = 'Login failed. Please check your credentials and try again.';
        }
      }
      
      log('  Final error message: $errorMessage', name: 'AuthHooks');
      throw Exception(errorMessage);
    }
  }

  /// Login with OTP hook - sends OTP for login (for users without password)
  /// This is useful for users who registered with OTP and don't have a password set
  Future<Map<String, dynamic>> useLoginWithOtp({
    required String phone,
  }) async {
    try {
      log('📱 useLoginWithOtp: Sending OTP to phone: $phone', name: 'AuthHooks');
      
      // Format phone number to E.164 format
      final formattedPhone = _formatPhoneNumber(phone);
      log('  Formatted phone: $formattedPhone', name: 'AuthHooks');
      
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
        shouldCreateUser: false, // Don't create new user, only login existing
      );
      
      log('✅ useLoginWithOtp: OTP sent successfully', name: 'AuthHooks');
      return {
        'success': true,
        'message': 'OTP sent to your phone',
      };
    } catch (e) {
      log('❌ useLoginWithOtp: Error - $e', name: 'AuthHooks', error: e);
      rethrow;
    }
  }

  /// Verify OTP hook - verifies OTP code
  /// Matches: useVerifyOtp from React implementation
  Future<Map<String, dynamic>> useVerifyOtp({
    required String phone,
    required String otp,
    OtpType? otpType,
  }) async {
    try {
      log('✅ useVerifyOtp: Verifying OTP', name: 'AuthHooks');
      log('  Phone: $phone', name: 'AuthHooks');
      log('  OTP: ${otp.length >= 2 ? otp.substring(0, 2) + "..." : "***"}', name: 'AuthHooks');
      
      // Format phone number
      final formattedPhone = _formatPhoneNumber(phone);
      
      log('🚀 DIRECT SUPABASE CALL - verifyOtp', name: 'AuthHooks');
      log('  Calling: _supabase.auth.verifyOtp() directly', name: 'AuthHooks');
      log('  OTP Type: ${otpType ?? OtpType.sms}', name: 'AuthHooks');
      log('  Formatted Phone: $formattedPhone', name: 'AuthHooks');
      
      // For phone-based OTP verification, always use OtpType.sms
      // This works for both registration and password recovery flows
      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms, // Always use SMS for phone-based OTP
      );
      
      if (response.user == null) {
        throw Exception('OTP verification failed');
      }
      
      log('✅ useVerifyOtp: OTP verified successfully', name: 'AuthHooks');
      log('  User ID: ${response.user?.id}', name: 'AuthHooks');
      
      // Save tokens if session is available
      if (response.session != null) {
        final tokenStorage = TokenStorage(_supabase);
        await tokenStorage.saveTokens(
          response.session?.accessToken,
          response.session?.refreshToken,
        );
        log('  ✅ Tokens saved', name: 'AuthHooks');
      }
      
      return {
        'success': true,
        'user': {
          'id': response.user?.id,
          'email': response.user?.email,
          'phone': response.user?.phone,
        },
      };
    } catch (e) {
      log('❌ useVerifyOtp: Error - $e', name: 'AuthHooks', error: e);
      
      // Extract better error message
      String errorMessage = 'OTP verification failed';
      final errorStr = e.toString();
      
      if (e is AuthException) {
        errorMessage = e.message;
        log('  AuthException message: $errorMessage', name: 'AuthHooks');
      } else if (errorStr.contains('expired') || errorStr.contains('Expired')) {
        errorMessage = 'OTP has expired. Please request a new one.';
      } else if (errorStr.contains('invalid') || errorStr.contains('Invalid')) {
        errorMessage = 'Invalid OTP code. Please check and try again.';
      } else {
        errorMessage = errorStr
            .replaceAll('Exception: ', '')
            .replaceAll('AuthException: ', '')
            .replaceAll('GotrueException: ', '')
            .split('\n')
            .first
            .trim();
        if (errorMessage.isEmpty) {
          errorMessage = 'OTP verification failed. Please try again.';
        }
      }
      
      log('  Final error message: $errorMessage', name: 'AuthHooks');
      throw Exception(errorMessage);
    }
  }

  /// Logout hook
  /// Matches: useLogout from React implementation
  Future<void> useLogout() async {
    try {
      log('🚪 useLogout: Starting logout', name: 'AuthHooks');
      
      // Clear tokens using TokenStorage
      final tokenStorage = TokenStorage(_supabase);
      await tokenStorage.clearTokens();
      
      // Also call Supabase signOut to ensure session is cleared
      await _supabase.auth.signOut();
      
      log('✅ useLogout: Success', name: 'AuthHooks');
    } catch (e) {
      log('❌ useLogout: Error - $e', name: 'AuthHooks', error: e);
      rethrow;
    }
  }
}
