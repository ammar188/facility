import 'dart:developer';

import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/homeScreen.dart';
import 'package:facility/screens/newpasswordscreen.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtpVerify extends StatefulWidget {
  const OtpVerify({
    super.key,
    required this.phone,
    this.isForgotPassword = false,
  });

  final String phone;
  final bool isForgotPassword;

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final OtpFieldController _otpController = OtpFieldController();
  String _currentOtp = '';
  final AuthHooks _authHooks = AuthHooks();

  Future<void> _handleVerify() async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = widget.phone;
    final otp = _currentOtp.trim();

    if (otp.length < 6) return;

    try {
      messenger.showSnackBar(const SnackBar(content: Text('Verifying OTP...')));
      log('🔐 Verifying OTP for phone: $phone, otp: $otp', name: 'OtpVerify');
      log('  isForgotPassword: ${widget.isForgotPassword}', name: 'OtpVerify');

      // For phone-based OTP (both registration and forgot password), use OtpType.sms
      // OtpType.recovery is only for email-based password recovery
      // When using signInWithOtp with phone, Supabase sends SMS OTP regardless of purpose
      final otpType = OtpType.sms;
      log('  Using OTP type: $otpType (phone-based OTP)', name: 'OtpVerify');
      
      final res = await _authHooks.useVerifyOtp(
        phone: phone,
        otp: otp,
        otpType: otpType,
      );

      log('✅ OTP verification success: ${res['success']}', name: 'OtpVerify');
      log('  isForgotPassword flag: ${widget.isForgotPassword}', name: 'OtpVerify');
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(content: Text('OTP verified!')));

      if (mounted) {
        // If this is from forgot password flow, navigate to new password screen
        // Otherwise, navigate to home screen (registration flow)
        log('  Navigating based on isForgotPassword: ${widget.isForgotPassword}', name: 'OtpVerify');
        if (widget.isForgotPassword) {
          log('  → Navigating to NewPasswordScreen', name: 'OtpVerify');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<NewPasswordScreen>(
              builder: (_) => const NewPasswordScreen(),
            ),
          );
        } else {
          log('  → Navigating to HomeScreen', name: 'OtpVerify');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<HomeScreen>(
              builder: (_) => const HomeScreen(),
            ),
          );
        }
      }
    } catch (e) {
      log('❌ OTP verification error: $e', name: 'OtpVerify', error: e);
      messenger.hideCurrentSnackBar();
      final msg = e.toString().replaceAll('Exception: ', '').split('\n').first;
      messenger.showSnackBar(SnackBar(content: Text(msg.isEmpty ? 'Verification failed' : msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ErrorBoundary(
        child: Container(
          color: const Color.fromRGBO(248, 248, 248, 1.0),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                   color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            // Image.asset('assets/images/logo.png', height: 72, fit: BoxFit.contain),
                            const SizedBox(height: 12),
                            const Text('OTP', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            const Text(
                              'Your OTP code is on its way to your\nWhatsApp, please enter it here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        OTPTextField(
                          length: 6,
                          controller: _otpController,
                          width: MediaQuery.of(context).size.width,
                          textFieldAlignment: MainAxisAlignment.center,
                          fieldWidth: 46,
                          fieldStyle: FieldStyle.box,
                          outlineBorderRadius: 6,
                          spaceBetween: 12,
                          style: const TextStyle(fontSize: 18),
                          contentPadding: const EdgeInsets.all(0),
                          otpFieldStyle: OtpFieldStyle(
                            backgroundColor: const Color.fromRGBO(245, 245, 245, 1.0),
                            borderColor: const Color.fromRGBO(229, 231, 235, 1.0),
                            enabledBorderColor: const Color.fromRGBO(229, 231, 235, 1.0),
                            focusBorderColor: const Color.fromRGBO(229, 231, 235, 1.0),
                          ),
                          onChanged: (pin) {
                            setState(() {
                              _currentOtp = pin;
                            });
                          },
                          onCompleted: (pin) {
                            setState(() {
                              _currentOtp = pin;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: Text.rich(
                              TextSpan(
                                text: "Didn't get your code? ",
                                style: const TextStyle(fontWeight: FontWeight.w300),
                                children: [
                                  TextSpan(
                                    text: 'Resend',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Verify',
                          onPressed: () {
                            if (_currentOtp.length == 6) {
                              _handleVerify();
                            }
                          },
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
