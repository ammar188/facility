import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  void _log(String label, dynamic data) {
    log('$label -> $data', name: 'AuthRepository');
  }

  /// Login using Supabase auth (phone or email)
  Future<Map<String, dynamic>> login(Map<String, dynamic> payload) async {
    try {
      log('AuthRepository: Login with payload: $payload', name: 'AuthRepository');
      
      final phone = payload['phone'] as String?;
      final email = payload['email'] as String?;
      final password = payload['password'] as String;

      if (phone != null && phone.isNotEmpty) {
        // Format phone number to E.164 format
        final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        String formattedPhone;
        if (!cleaned.startsWith('+')) {
          formattedPhone = '+92$cleaned'; // Add Pakistan country code
        } else {
          formattedPhone = cleaned;
        }
        
        log('Formatted phone for login: $formattedPhone', name: 'AuthRepository');
        
        // Phone login
        final response = await _supabase.auth.signInWithPassword(
          phone: formattedPhone,
          password: password,
        );
        _log('login (phone)', 'Success: ${response.user?.id}');
        return {
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
      } else if (email != null && email.isNotEmpty) {
        // Format email (lowercase, trim)
        final formattedEmail = email.trim().toLowerCase();
        log('Formatted email for login: $formattedEmail', name: 'AuthRepository');
        
        // Email login
        final response = await _supabase.auth.signInWithPassword(
          email: formattedEmail,
          password: password,
        );
        _log('login (email)', 'Success: ${response.user?.id}');
        return {
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
      } else {
        throw Exception('Either phone or email is required');
      }
    } catch (e) {
      _log('login', 'Error: $e');
      log('Login error details: $e', name: 'AuthRepository', error: e);
      rethrow;
    }
  }

  /// Logout using Supabase
  Future<Map<String, dynamic>> logout() async {
    try {
      await _supabase.auth.signOut();
      _log('logout', 'Success');
      return {'success': true, 'message': 'Logged out'};
    } catch (e) {
      _log('logout', 'Error: $e');
      rethrow;
    }
  }

  /// Register using Supabase auth
  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    try {
      log('AuthRepository: Register with payload: $payload', name: 'AuthRepository');
      
      final email = payload['email'] as String?;
      final phone = payload['phone'] as String?;
      final password = payload['password'] as String;
      final firstName = payload['firstName'] as String?;
      final lastName = payload['lastName'] as String?;

      // Validate password
      if (password.isEmpty || password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      final userMetadata = <String, dynamic>{};
      if (firstName != null && firstName.isNotEmpty) userMetadata['firstName'] = firstName;
      if (lastName != null && lastName.isNotEmpty) userMetadata['lastName'] = lastName;
      
      // Format phone number to E.164 format if provided
      String? formattedPhone;
      if (phone != null && phone.isNotEmpty) {
        // Remove any spaces, dashes, or parentheses
        final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        // If doesn't start with +, add country code +92 (Pakistan)
        if (!cleaned.startsWith('+')) {
          formattedPhone = '+92$cleaned';
        } else {
          formattedPhone = cleaned;
        }
        userMetadata['phone'] = formattedPhone;
      }

      // Format email - minimal validation, let Supabase validate
      String? formattedEmail;
      if (email != null && email.isNotEmpty) {
        // Just trim and lowercase - let Supabase do the validation
        formattedEmail = email.trim().toLowerCase();
        
        log('📧 Email formatting:', name: 'AuthRepository');
        log('  Original: "$email"', name: 'AuthRepository');
        log('  Formatted: "$formattedEmail"', name: 'AuthRepository');
        
        // Only check if it's empty after formatting
        if (formattedEmail.isEmpty) {
          throw Exception('Email cannot be empty');
        }
        
        // Basic check - just needs @ symbol, let Supabase validate the rest
        if (!formattedEmail.contains('@')) {
          throw Exception('Email must contain @ symbol');
        }
        
        log('✅ Email formatted, sending to Supabase for validation', name: 'AuthRepository');
        
        // Prioritize email registration if both are provided
        log('🚀 Attempting Supabase signUp with email: $formattedEmail', name: 'AuthRepository');
        log('Password length: ${password.length}', name: 'AuthRepository');
        log('User metadata: $userMetadata', name: 'AuthRepository');
        
        try {
          // Email registration
          log('📤 Calling Supabase signUp API...', name: 'AuthRepository');
          log('  📧 email: "$formattedEmail"', name: 'AuthRepository');
          log('  🔑 password length: ${password.length}', name: 'AuthRepository');
          log('  📝 metadata: $userMetadata', name: 'AuthRepository');
          
          final response = await _supabase.auth.signUp(
            email: formattedEmail,
            password: password,
            data: userMetadata,
          );
          _log('register (email)', 'Success: ${response.user?.id}');
          return {
            'data': {
              'user': {
                'id': response.user?.id,
                'email': response.user?.email,
                'phone': response.user?.phone,
              },
            },
          };
        } catch (e) {
          log('❌ Supabase signUp error: $e', name: 'AuthRepository', error: e);
          log('Error type: ${e.runtimeType}', name: 'AuthRepository');
          
          // Try to extract detailed error message from Supabase
          String errorMessage = 'Registration failed';
          final errorStr = e.toString();
          log('Full error string: $errorStr', name: 'AuthRepository');
          
          // Try to extract error message from Supabase exception
          // Supabase errors are usually AuthException from gotrue
          try {
            // Check if error has a message property
            final errorType = e.runtimeType.toString();
            log('Error type: $errorType', name: 'AuthRepository');
            
            // Try multiple ways to extract the error message
            String? extractedMessage;
            
            // Method 1: Try to access message property directly
            try {
              final dynamicErr = e as dynamic;
              if (dynamicErr.message != null) {
                extractedMessage = dynamicErr.message.toString();
                log('Extracted message (method 1): $extractedMessage', name: 'AuthRepository');
              }
            } catch (_) {}
            
            // Method 2: Try to access statusCode and message
            try {
              final dynamicErr = e as dynamic;
              if (extractedMessage == null && dynamicErr.statusCode != null) {
                final statusCode = dynamicErr.statusCode;
                final msg = dynamicErr.message?.toString() ?? errorStr;
                extractedMessage = 'Error $statusCode: $msg';
                log('Extracted message (method 2): $extractedMessage', name: 'AuthRepository');
              }
            } catch (_) {}
            
            // Method 3: Try to parse JSON from error string
            try {
              if (extractedMessage == null && errorStr.contains('{')) {
                final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(errorStr);
                if (jsonMatch != null) {
                  log('Found JSON in error: ${jsonMatch.group(0)}', name: 'AuthRepository');
                }
              }
            } catch (_) {}
            
            if (extractedMessage != null && extractedMessage.isNotEmpty) {
              errorMessage = extractedMessage;
              log('✅ Using extracted error message: $errorMessage', name: 'AuthRepository');
            }
          } catch (ex) {
            log('Error extracting message: $ex', name: 'AuthRepository');
          }
          
          // If we still don't have a good error message, check patterns
          if (errorMessage == 'Registration failed') {
            // Check for common Supabase error patterns
            if (errorStr.contains('User already registered') || 
                errorStr.contains('already registered') ||
                errorStr.contains('already exists') ||
                errorStr.contains('duplicate')) {
              errorMessage = 'This email is already registered. Please use a different email or try logging in.';
            } else if (errorStr.contains('Password') || errorStr.contains('password') || errorStr.contains('weak')) {
              errorMessage = 'Password does not meet requirements. Please use at least 6 characters.';
            } else if (errorStr.contains('email') || errorStr.contains('Email') || errorStr.contains('invalid')) {
              // Our validation passed, so this is likely a Supabase-specific issue
              log('⚠️ Supabase rejected email that passed our validation: $formattedEmail', name: 'AuthRepository');
              log('⚠️ Full error string: $errorStr', name: 'AuthRepository');
              
              // Show the actual error if we extracted it, otherwise show helpful message
              if (errorMessage == 'Registration failed') {
                errorMessage = 'Email validation error.\n'
                    'Email: "$formattedEmail"\n'
                    'Error: ${errorStr.length > 200 ? errorStr.substring(0, 200) + "..." : errorStr}\n\n'
                    'Possible causes:\n'
                    '• Email already exists\n'
                    '• Check Supabase dashboard for restrictions\n'
                    '• Try a different email';
              }
            } else if (errorStr.contains('400') || errorStr.contains('Bad Request')) {
              // 400 Bad Request - try to be more specific
              if (errorStr.contains('email')) {
                errorMessage = 'Invalid email address. Please check: $formattedEmail';
              } else if (errorStr.contains('password')) {
                errorMessage = 'Password is too weak. Please use a stronger password (at least 6 characters).';
              } else {
                errorMessage = 'Invalid registration data. Please check all fields and try again.';
              }
            } else {
              // Use the error message as-is, but clean it up
              errorMessage = errorStr
                  .replaceAll('Exception: ', '')
                  .replaceAll('AuthException: ', '')
                  .replaceAll('GotrueException: ', '')
                  .split('\n')
                  .first;
            }
          }
          
          log('Final error message: $errorMessage', name: 'AuthRepository');
          throw Exception(errorMessage);
        }
      } else {
        log('Email is null or empty', name: 'AuthRepository');
        throw Exception('Email is required');
      }
      
      // If email registration didn't happen, try phone registration
      if (formattedPhone != null && formattedPhone.isNotEmpty) {
        // Phone registration
        final response = await _supabase.auth.signUp(
          phone: formattedPhone,
          password: password,
          data: userMetadata,
        );
        _log('register (phone)', 'Success: ${response.user?.id}');
        return {
          'data': {
            'user': {
              'id': response.user?.id,
              'phone': response.user?.phone,
            },
          },
        };
      } else {
        throw Exception('Either phone or email is required');
      }
    } catch (e) {
      _log('register', 'Error: $e');
      rethrow;
    }
  }

  /// Verify registration (OTP verification)
  Future<Map<String, dynamic>> verifyRegistration(Map<String, dynamic> payload) async {
    try {
      final token = payload['token'] as String? ?? payload['otp'] as String?;
      
      if (token == null) {
        throw Exception('OTP token is required');
      }

      // Supabase handles OTP verification automatically on signUp
      // This is for manual verification if needed
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        token: token,
        email: payload['email'] as String?,
        phone: payload['phone'] as String?,
      );
      
      _log('verifyRegistration', 'Success: ${response.user?.id}');
      return {
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
      _log('verifyRegistration', 'Error: $e');
      rethrow;
    }
  }

  /// Forgot password using Supabase
  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> payload) async {
    try {
      final email = payload['email'] as String?;
      final phone = payload['phone'] as String?;

      if (email != null) {
        await _supabase.auth.resetPasswordForEmail(email);
      } else if (phone != null) {
        await _supabase.auth.resetPasswordForEmail(phone);
      } else {
        throw Exception('Either phone or email is required');
      }
      
      _log('forgotPassword', 'Success');
      return {'success': true, 'message': 'Password reset email sent'};
    } catch (e) {
      _log('forgotPassword', 'Error: $e');
      rethrow;
    }
  }

  /// Reset password using Supabase
  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> payload) async {
    try {
      final password = payload['password'] as String;
      await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );
      _log('resetPassword', 'Success');
      return {
        'data': {
          'accessToken': _supabase.auth.currentSession?.accessToken,
          'refreshToken': _supabase.auth.currentSession?.refreshToken,
          'user': {
            'id': _supabase.auth.currentUser?.id,
          },
        },
      };
    } catch (e) {
      _log('resetPassword', 'Error: $e');
      rethrow;
    }
  }
}

