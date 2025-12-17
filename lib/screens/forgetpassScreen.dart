import 'dart:developer';

import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/otpVerify.dart';
import 'package:facility/widgets/phone_input_field.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool phoneError = false;
  final AuthHooks _authHooks = AuthHooks();

  Future<void> _handleForgotPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = _phoneController.text.trim();
    
    // Validate phone number
    final phoneDigits = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (phoneDigits.length < 10) {
      setState(() {
        phoneError = true;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }
    
    try {
      messenger.showSnackBar(const SnackBar(content: Text('Sending OTP...')));
      log('📱 Forgot password button clicked - Phone: $phone', name: 'ForgetPassScreen');
      
      final result = await _authHooks.useForgotPassword(phone: phone);
      
      log('✅ OTP sent successfully: ${result['success']}', name: 'ForgetPassScreen');
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('OTP sent to $phone'),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate to OTP verification screen with isForgotPassword flag
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<OtpVerify>(
            builder: (_) => OtpVerify(phone: phone, isForgotPassword: true),
          ),
        );
      }
    } catch (e) {
      log('❌ Forgot password error: $e', name: 'ForgetPassScreen', error: e);
      messenger.hideCurrentSnackBar();
      String errorMessage = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AuthException: ', '')
          .replaceAll('GotrueException: ', '')
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
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ErrorBoundary(
        child: Container(
          color: const Color.fromRGBO(248, 248, 248, 1.0),
          width: double.infinity,
          height: double.infinity,
          child: Align(
            alignment: Alignment.topCenter,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 60,
                          width: 60,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Forgot Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(24, 24, 27, 1.0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your phone number to receive OTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PhoneInputField(
                                hintText: '',
                                flagAssetPath: 'assets/images/flag.png',
                                controller: _phoneController,
                                hasError: phoneError,
                                onChanged: (_) => setState(() => phoneError = false),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Send OTP',
                                onPressed: _handleForgotPassword,
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
      ),
    );
  }
}

