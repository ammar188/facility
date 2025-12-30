import 'dart:developer';

import 'package:facility/dashboard/view/dashboard_page.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/otp_verify_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool remember = false;
  bool loginPhoneError = false;
  bool loginPassError = false;
  final TextEditingController _loginPhoneController = TextEditingController();
  final TextEditingController _loginPassController = TextEditingController();
  final AuthHooks _authHooks = AuthHooks();

  Future<void> _handleLogin() async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = _loginPhoneController.text.trim();
    final password = _loginPassController.text.trim();
    
    try {
      messenger.showSnackBar(const SnackBar(content: Text('Logging in...')));
      log('🔐 Login button clicked - Phone: $phone', name: 'LoginScreen');
      
      final result = await _authHooks.useLogin(
        phone: phone,
        password: password,
      );
      
      log('✅ Login successful: ${result['success']}', name: 'LoginScreen');
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(content: Text('Login successful!')));
      
      // Navigate to dashboard after successful password login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<DashboardPage>(
            builder: (_) => const DashboardPage(),
          ),
        );
      }
    } catch (e) {
      log('❌ Login error: $e', name: 'LoginScreen', error: e);
      messenger.hideCurrentSnackBar();

      // Extract error message (already formatted by auth_hooks)
      String errorMessage = e.toString()
          .replaceAll('Exception: ', '')
          .split('\n')
          .first
          .trim();

      if (errorMessage.isEmpty) {
        errorMessage = 'Login failed. Please check your credentials and try again.';
      }

      // If it's an invalid phone/password error, automatically fall back to OTP login
      final errorStr = errorMessage.toLowerCase();
      if (errorStr.contains('invalid') &&
          (errorStr.contains('credentials') || errorStr.contains('password'))) {
        log('ℹ️ Invalid phone/password. Falling back to OTP login for phone: $phone', name: 'LoginScreen');
        // Try OTP login: will only succeed if phone exists; otherwise shows clear error
        await _handleLoginWithOtp();
        return;
      }

      log('  Showing error to user: $errorMessage', name: 'LoginScreen');
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _handleLoginWithOtp() async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = _loginPhoneController.text.trim();
    
    if (phone.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }
    
    try {
      messenger.showSnackBar(const SnackBar(content: Text('Sending OTP...')));
      log('📱 Login with OTP button clicked - Phone: $phone', name: 'LoginScreen');
      
      final result = await _authHooks.useLoginWithOtp(phone: phone);
      
      log('✅ OTP sent successfully: ${result['success']}', name: 'LoginScreen');
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('OTP sent to $phone'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate to OTP verification screen
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<OtpVerifyScreen>(
            builder: (_) => OtpVerifyScreen(phone: phone),
          ),
        );
      }
    } catch (e) {
      log('❌ OTP login error: $e', name: 'LoginScreen', error: e);
      messenger.hideCurrentSnackBar();
      String errorMessage = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AuthException: ', '')
          .split('\n')
          .first
          .trim();
      if (errorMessage.isEmpty) {
        errorMessage = 'Failed to send OTP. Please try again.';
      }
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  void dispose() {
    _loginPhoneController.dispose();
    _loginPassController.dispose();
    super.dispose();
  }

  bool _validateLogin() {
    final cleaned = _loginPhoneController.text.trim().replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    setState(() {
      // allow variable length, require at least 10 digits
      loginPhoneError = cleaned.length < 10;
      loginPassError = _loginPassController.text.trim().isEmpty;
    });
    return !(loginPhoneError || loginPassError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromRGBO(248, 248, 248, 1.0),
        width: double.infinity,
        child: Align(
          alignment: Alignment.topCenter,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 0, bottom: 2.0, left: 2.0, right: 2.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Logo and Heading
                  Column(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.account_circle, size: 80);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Log In Your Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(24, 24, 27, 1.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Card with input fields
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Phone field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Phone Number',
                                  style: TextStyle(fontSize: 12, color: Color.fromARGB(137, 0, 0, 0)),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _loginPhoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Enter your phone number',
                                    filled: true,
                                    fillColor: const Color.fromRGBO(248, 248, 248, 1.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: loginPhoneError
                                          ? const BorderSide(color: Colors.red)
                                          : BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: loginPhoneError
                                          ? const BorderSide(color: Colors.red)
                                          : BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: loginPhoneError
                                          ? const BorderSide(color: Colors.red)
                                          : BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onChanged: (_) => setState(() => loginPhoneError = false),
                                ),
                              ],
                            ),

                            // Password field
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Password',
                                  style: TextStyle(fontSize: 12, color: Color.fromARGB(137, 0, 0, 0)),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _loginPassController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Enter your password',
                                    filled: true,
                                    fillColor: const Color.fromRGBO(248, 248, 248, 1.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: loginPassError
                                          ? const BorderSide(color: Colors.red)
                                          : BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: loginPassError
                                          ? const BorderSide(color: Colors.red)
                                          : BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: loginPassError
                                          ? const BorderSide(color: Colors.red)
                                          : BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  onChanged: (_) => setState(() => loginPassError = false),
                                ),
                              ],
                            ),

                            // Remember me checkbox
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Transform.scale(
                                  scale: 0.85,
                                  child: Checkbox(
                                    value: remember,
                                    onChanged: (value) => setState(() => remember = value ?? false),
                                    visualDensity: VisualDensity.compact,
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                                    activeColor: const Color.fromARGB(255, 81, 76, 76),
                                    checkColor: Colors.white,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const Text('Remember me', style: TextStyle(fontSize: 12)),
                              ],
                            ),

                            // Sign In button
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_validateLogin()) {
                                  _handleLogin();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 81, 76, 76),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

