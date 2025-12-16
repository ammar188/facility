import 'dart:developer';

import 'package:facility/app/auth/token_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Flutter-style hooks for Supabase authentication
/// Matches the React hooks pattern from the reference implementation
class AuthHooks {
  AuthHooks({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Register hook - uses signInWithOtp (OTP-based registration)
  /// Matches: useRegister from React implementation
  Future<Map<String, dynamic>> useRegister({
    required String phone,
    required String fullName,
    String? referrerCode,
  }) async {
    try {
      log('📝 useRegister: Starting OTP-based registration', name: 'AuthHooks');
      log('  Phone: $phone', name: 'AuthHooks');
      log('  Full Name: $fullName', name: 'AuthHooks');
      log('  Referrer Code: ${referrerCode ?? "null"}', name: 'AuthHooks');
      print('[useRegister] Starting registration for phone: $phone, fullName: $fullName');
      
      // Format phone number to E.164 format
      String formattedPhone;
      final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (!cleaned.startsWith('+')) {
        formattedPhone = '+92$cleaned'; // Add Pakistan country code
      } else {
        formattedPhone = cleaned;
      }
      log('  Formatted phone: $formattedPhone', name: 'AuthHooks');
      print('[useRegister] Formatted phone: $formattedPhone');
      
      // Prepare user metadata
      final userMetadata = <String, dynamic>{
        'full_name': fullName,
      };
      if (referrerCode != null && referrerCode.isNotEmpty) {
        userMetadata['referred_by'] = referrerCode;
      }
      
      log('🚀 DIRECT SUPABASE CALL - signInWithOtp', name: 'AuthHooks');
      log('  Supabase URL: https://fdwwznmkotguczxahodq.supabase.co', name: 'AuthHooks');
      log('  Calling: _supabase.auth.signInWithOtp() directly', name: 'AuthHooks');
      print('[useRegister] Calling supabase.auth.signInWithOtp for $formattedPhone');
      
      // Call Supabase signInWithOtp (creates auth user if doesn't exist)
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
        data: userMetadata,
      );
      
      log('✅ useRegister: OTP sent successfully', name: 'AuthHooks');
      log('  Phone: $formattedPhone', name: 'AuthHooks');
      print('[useRegister] ✅ OTP sent successfully to $formattedPhone');
      
      return {
        'success': true,
        'message': 'OTP sent successfully',
      };
    } catch (e) {
      log('❌ useRegister: Error - $e', name: 'AuthHooks', error: e);
      rethrow;
    }
  }

  /// Set Password hook - sets password after OTP verification
  /// Matches: useSetPassword from React implementation
  Future<Map<String, dynamic>> useSetPassword({
    required String password,
  }) async {
    try {
      log('🔑 useSetPassword: Setting password', name: 'AuthHooks');
      
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );
      
      if (response.user == null) {
        throw Exception('Failed to set password');
      }
      
      log('✅ useSetPassword: Password set successfully', name: 'AuthHooks');
      log('  User ID: ${response.user?.id}', name: 'AuthHooks');
      
      return {
        'success': true,
        'user': {
          'id': response.user?.id,
          'email': response.user?.email,
          'phone': response.user?.phone,
        },
      };
    } catch (e) {
      log('❌ useSetPassword: Error - $e', name: 'AuthHooks', error: e);
      rethrow;
    }
  }

  /// Login hook - calls supabase.auth.signInWithPassword({ phone, password })
  /// Matches: useLogin from React implementation
  Future<Map<String, dynamic>> useLogin({
    required String phone,
    required String password,
  }) async {
    try {
      log('🔐 useLogin: Starting login', name: 'AuthHooks');
      log('  Phone: $phone', name: 'AuthHooks');
      
      // Format phone number to E.164 format
      String formattedPhone;
      final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (!cleaned.startsWith('+')) {
        formattedPhone = '+92$cleaned'; // Add Pakistan country code
      } else {
        formattedPhone = cleaned;
      }
      log('  Formatted phone: $formattedPhone', name: 'AuthHooks');
      
      log('🚀 DIRECT SUPABASE CALL - signInWithPassword', name: 'AuthHooks');
      log('  Calling: _supabase.auth.signInWithPassword() directly', name: 'AuthHooks');
      
      // Call Supabase signInWithPassword
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
      rethrow;
    }
  }

  /// Forgot Password hook - sends OTP for password reset
  /// Matches: useForgotPassword from React implementation
  Future<Map<String, dynamic>> useForgotPassword({
    required String phone,
  }) async {
    try {
      log('📱 useForgotPassword: Sending OTP to phone', name: 'AuthHooks');
      log('  Phone: $phone', name: 'AuthHooks');
      
      // Format phone number to E.164 format
      String formattedPhone;
      final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (!cleaned.startsWith('+')) {
        formattedPhone = '+92$cleaned';
      } else {
        formattedPhone = cleaned;
      }
      
      log('🚀 DIRECT SUPABASE CALL - signInWithOtp (password reset)', name: 'AuthHooks');
      log('  Calling: _supabase.auth.signInWithOtp() with shouldCreateUser: false', name: 'AuthHooks');
      
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
        shouldCreateUser: false,
      );
      
      log('✅ useForgotPassword: OTP sent successfully', name: 'AuthHooks');
      
      return {
        'success': true,
        'message': 'OTP sent for password reset',
      };
    } catch (e) {
      log('❌ useForgotPassword: Error - $e', name: 'AuthHooks', error: e);
      rethrow;
    }
  }

  /// Change Password hook - changes password after re-authentication
  /// Matches: useChangePassword from React implementation
  Future<Map<String, dynamic>> useChangePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      log('🔄 useChangePassword: Changing password', name: 'AuthHooks');
      
      // Get current user
      final currentUserResponse = await _supabase.auth.getUser();
      if (currentUserResponse.user?.phone == null) {
        throw Exception('No user or phone found');
      }
      
      final phone = currentUserResponse.user!.phone!;
      log('  Current user phone: $phone', name: 'AuthHooks');
      
      // Re-authenticate using old password
      log('  Re-authenticating with old password...', name: 'AuthHooks');
      final reauthResponse = await _supabase.auth.signInWithPassword(
        phone: phone,
        password: oldPassword,
      );
      
      if (reauthResponse.user == null) {
        throw Exception('Incorrect current password');
      }
      
      log('  ✅ Re-authentication successful', name: 'AuthHooks');
      
      // Update password
      log('  Updating password...', name: 'AuthHooks');
      final updateResponse = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      if (updateResponse.user == null) {
        throw Exception('Failed to update password');
      }
      
      log('✅ useChangePassword: Password updated successfully', name: 'AuthHooks');
      
      return {
        'success': true,
        'message': 'Password updated successfully',
        'user': {
          'id': updateResponse.user?.id,
          'email': updateResponse.user?.email,
          'phone': updateResponse.user?.phone,
        },
      };
    } catch (e) {
      log('❌ useChangePassword: Error - $e', name: 'AuthHooks', error: e);
      rethrow;
    }
  }

  /// Verify OTP hook - verifies OTP code
  /// Matches: useVerifyOtp from React implementation
  Future<Map<String, dynamic>> useVerifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      log('✅ useVerifyOtp: Verifying OTP', name: 'AuthHooks');
      log('  Phone: $phone', name: 'AuthHooks');
      log('  OTP: ${otp.substring(0, 2)}...', name: 'AuthHooks');
      
      // Format phone number
      String formattedPhone;
      final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (!cleaned.startsWith('+')) {
        formattedPhone = '+92$cleaned';
      } else {
        formattedPhone = cleaned;
      }
      
      log('🚀 DIRECT SUPABASE CALL - verifyOtp', name: 'AuthHooks');
      log('  Calling: _supabase.auth.verifyOtp() directly', name: 'AuthHooks');
      
      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
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
      rethrow;
    }
  }

  /// Logout hook
  /// Matches: useLogout from React implementation
  Future<void> useLogout() async {
    try {
      log('🚪 useLogout: Starting logout', name: 'AuthHooks');
      await _supabase.auth.signOut();
      log('✅ useLogout: Success', name: 'AuthHooks');
    } catch (e) {
      log('❌ useLogout: Error - $e', name: 'AuthHooks', error: e);
      rethrow;
    }
  }
}
