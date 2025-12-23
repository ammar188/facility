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
    String? email,
    String? referrerCode,
  }) async {
    try {
      log('📝 useRegister: Starting OTP-based registration', name: 'AuthHooks');
      log('  Phone: $phone', name: 'AuthHooks');
      log('  Full Name: $fullName', name: 'AuthHooks');
      log('  Email: ${email ?? "null"}', name: 'AuthHooks');
      log('  Referrer Code: ${referrerCode ?? "null"}', name: 'AuthHooks');
      print('[useRegister] Starting registration for phone: $phone, fullName: $fullName, email: ${email ?? "null"}');
      
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
      if (email != null && email.isNotEmpty) {
        userMetadata['email'] = email;
      }
      if (referrerCode != null && referrerCode.isNotEmpty) {
        userMetadata['referred_by'] = referrerCode;
      }
      
      log('🚀 DIRECT SUPABASE CALL - signInWithOtp', name: 'AuthHooks');
      log('  Supabase URL: https://fdwwznmkotguczxahodq.supabase.co', name: 'AuthHooks');
      log('  Calling: _supabase.auth.signInWithOtp() directly', name: 'AuthHooks');
      print('[useRegister] Calling supabase.auth.signInWithOtp for $formattedPhone');
      
      // Call Supabase signInWithOtp (creates auth user if doesn't exist)
      // Note: shouldCreateUser defaults to true, which creates user in auth.users
      log('  Calling signInWithOtp with shouldCreateUser: true (default)', name: 'AuthHooks');
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
        data: userMetadata,
        // shouldCreateUser: true is default - this creates user in auth.users
      );
      
      log('✅ useRegister: OTP sent successfully', name: 'AuthHooks');
      log('  Phone: $formattedPhone', name: 'AuthHooks');
      log('  ⚠️ NOTE: User will be created in auth.users AFTER OTP verification', name: 'AuthHooks');
      print('[useRegister] ✅ OTP sent successfully to $formattedPhone');
      print('⚠️ User will be created in auth.users table after OTP is verified');
      
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
      String formattedPhone;
      final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (!cleaned.startsWith('+')) {
        formattedPhone = '+92$cleaned';
      } else {
        formattedPhone = cleaned;
      }
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
    OtpType? otpType,
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
      log('  OTP Type: ${otpType ?? OtpType.sms}', name: 'AuthHooks');
      log('  Formatted Phone: $formattedPhone', name: 'AuthHooks');
      
      // For phone-based OTP verification, always use OtpType.sms
      // This works for both registration and password recovery flows
      // IMPORTANT: verifyOTP creates the user in auth.users if they don't exist
      log('  ⚠️ CRITICAL: verifyOTP should create user in auth.users if not exists', name: 'AuthHooks');
      
      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms, // Always use SMS for phone-based OTP
      );
      
      print('');
      print('═══════════════════════════════════════════════════════');
      print('✅✅✅ OTP VERIFICATION COMPLETE!');
      print('═══════════════════════════════════════════════════════');
      
      log('✅ useVerifyOtp: OTP verified successfully', name: 'AuthHooks');
      print('[useVerifyOtp] ✅ OTP verified successfully');
      
      log('  Response received from Supabase', name: 'AuthHooks');
      print('[useVerifyOtp] Response received from Supabase');
      print('[useVerifyOtp] User in response: ${response.user != null}');
      print('[useVerifyOtp] Session in response: ${response.session != null}');
      
      if (response.user == null) {
        log('  ❌ CRITICAL: User is null after OTP verification!', name: 'AuthHooks');
        print('');
        print('❌❌❌ CRITICAL ERROR: User was not created in auth.users table!');
        print('This means Supabase did not create the user. Check:');
        print('  1. Supabase project settings');
        print('  2. Phone authentication is enabled');
        print('  3. OTP was valid');
        print('═══════════════════════════════════════════════════════');
        throw Exception('User was not created after OTP verification');
      }
      
      log('  ✅ User exists in response!', name: 'AuthHooks');
      print('[useVerifyOtp] ✅ User exists in response!');
      print('[useVerifyOtp] User ID: ${response.user?.id}');
      print('[useVerifyOtp] User Phone: ${response.user?.phone}');
      print('[useVerifyOtp] User Created At: ${response.user?.createdAt}');
      
      log('  User ID: ${response.user?.id}', name: 'AuthHooks');
      log('  User Phone: ${response.user?.phone}', name: 'AuthHooks');
      log('  User Created At: ${response.user?.createdAt}', name: 'AuthHooks');

      // IMPORTANT: According to Supabase documentation, user data is automatically stored
      // in auth.users table when OTP is verified. No separate Users table is needed.
      // User metadata (full_name, referred_by, etc.) is stored in user_metadata JSONB column.
      
      // Save session for authenticated requests
      if (response.session != null) {
        log('  Setting session on Supabase client...', name: 'AuthHooks');
        try {
          await _supabase.auth.setSession(response.session!.refreshToken!);
          log('  ✅ Session set successfully', name: 'AuthHooks');
          
          // Verify session is set
          final currentSession = _supabase.auth.currentSession;
          if (currentSession != null) {
            log('  ✅ Verified: Current session exists', name: 'AuthHooks');
            log('  Session user ID: ${currentSession.user.id}', name: 'AuthHooks');
          }
        } catch (sessionError) {
          log('  ❌ Error setting session: $sessionError', name: 'AuthHooks', error: sessionError);
        }
      }

      // Verify user exists in auth.users (this is automatic - Supabase stores it)
      try {
        final authUser = response.user!;
        final metadata = authUser.userMetadata ?? <String, dynamic>{};

        log('✅✅✅ User registered successfully in auth.users table!', name: 'AuthHooks');
        log('  User ID: ${authUser.id}', name: 'AuthHooks');
        log('  Phone: ${authUser.phone ?? formattedPhone}', name: 'AuthHooks');
        log('  Email: ${authUser.email ?? "null"}', name: 'AuthHooks');
        log('  Full Name: ${metadata['full_name'] ?? "null"}', name: 'AuthHooks');
        log('  Referred By: ${metadata['referred_by'] ?? "null"}', name: 'AuthHooks');
        log('  Created At: ${authUser.createdAt}', name: 'AuthHooks');
        log('  Phone Confirmed At: ${authUser.phoneConfirmedAt ?? "null"}', name: 'AuthHooks');
        
        // CRITICAL: Double-check by fetching the user again from Supabase
        // This confirms the user is actually persisted in auth.users
        log('  🔍 VERIFYING: Fetching user from auth.users to confirm persistence...', name: 'AuthHooks');
        try {
          // Wait a moment for Supabase to persist
          await Future<void>.delayed(const Duration(milliseconds: 500));
          
          final verifyUserResponse = await _supabase.auth.getUser();
          if (verifyUserResponse.user != null) {
            log('  ✅✅✅ CONFIRMED: User exists and is accessible in auth.users!', name: 'AuthHooks');
            log('  Verified User ID: ${verifyUserResponse.user!.id}', name: 'AuthHooks');
            log('  Verified Phone: ${verifyUserResponse.user!.phone}', name: 'AuthHooks');
            log('  Verified Created At: ${verifyUserResponse.user!.createdAt}', name: 'AuthHooks');
            log('  Verified Phone Confirmed: ${verifyUserResponse.user!.phoneConfirmedAt != null}', name: 'AuthHooks');
            
            print('');
            print('═══════════════════════════════════════════════════════');
            print('✅✅✅ CONFIRMED: User exists in Supabase auth.users!');
            print('═══════════════════════════════════════════════════════');
            print('User ID: ${verifyUserResponse.user!.id}');
            print('Phone: ${verifyUserResponse.user!.phone}');
            print('Full Name: ${verifyUserResponse.user!.userMetadata?['full_name'] ?? "Not provided"}');
            print('Created At: ${verifyUserResponse.user!.createdAt}');
            print('Phone Confirmed: ${verifyUserResponse.user!.phoneConfirmedAt != null}');
            print('');
            print('💡 WHERE TO FIND IN SUPABASE DASHBOARD:');
            print('   1. Go to: https://app.supabase.com');
            print('   2. Select your project');
            print('   3. Go to: Authentication → Users');
            print('   4. Look for phone: ${verifyUserResponse.user!.phone}');
            print('   5. Make sure filter shows "All users" (not just confirmed)');
            print('   6. Refresh the page if needed');
            print('═══════════════════════════════════════════════════════');
            print('');
            
            // Also log to console with log() for developer tools
            log('✅✅✅ CONFIRMED: User exists in Supabase auth.users!', name: 'AuthHooks');
            log('  User ID: ${verifyUserResponse.user!.id}', name: 'AuthHooks');
            log('  Phone: ${verifyUserResponse.user!.phone}', name: 'AuthHooks');
          } else {
            log('  ❌❌❌ CRITICAL: getUser() returned null user!', name: 'AuthHooks');
            print('❌❌❌ CRITICAL ERROR: User was NOT persisted in auth.users!');
            print('The user object exists in the response but is not accessible via getUser()');
            print('This indicates the user was not actually saved to the database.');
            print('');
            print('Possible causes:');
            print('  1. Supabase project configuration issue');
            print('  2. Database connection problem');
            print('  3. RLS policies blocking user creation');
            print('  4. Phone authentication not properly enabled');
          }
        } catch (verifyError) {
          log('  ❌❌❌ CRITICAL: Could not verify user via getUser(): $verifyError', name: 'AuthHooks', error: verifyError);
          print('❌❌❌ CRITICAL ERROR: Could not verify user persistence!');
          print('Error: $verifyError');
          print('');
          print('This means we cannot confirm the user was saved to auth.users.');
        }
        
        print('✅✅✅ SUCCESS: User registered in Supabase auth.users table!');
        print('User ID: ${authUser.id}');
        print('Phone: ${authUser.phone ?? formattedPhone}');
        print('Full Name: ${metadata['full_name'] ?? "Not provided"}');
        print('');
        print('💡 NOTE: User data is stored in auth.users table (Supabase built-in).');
        print('   To access user data, use: supabase.auth.getUser()');
        print('   User metadata is in: user.user_metadata');
        
      } catch (e) {
        log('⚠️ Could not verify user data: $e', name: 'AuthHooks');
        print('❌ ERROR: Could not verify user data: $e');
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
      await _supabase.auth.signOut();
      log('✅ useLogout: Success', name: 'AuthHooks');
    } catch (e) {
      log('❌ useLogout: Error - $e', name: 'AuthHooks', error: e);
      rethrow;
    }
  }
}
