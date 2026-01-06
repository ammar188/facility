import 'dart:developer';

import 'package:facility/app/routes/app_routes.dart';
import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/auth/newpasswordscreen.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
          context.go(AppRoutes.home.path);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Responsive values
    final cardMaxWidth = isMobile ? screenWidth * 0.95 : (isTablet ? 500.0 : 600.0);
    final logoSize = isMobile ? 60.0 : (isTablet ? 72.0 : 80.0);
    final headingFontSize = isMobile ? 20.0 : (isTablet ? 22.0 : 24.0);
    final subheadingFontSize = isMobile ? 13.0 : (isTablet ? 14.0 : 15.0);
    final cardPadding = isMobile ? 20.0 : (isTablet ? 28.0 : 32.0);
    final spacingSmall = isMobile ? 8.0 : 12.0;
    final spacingMedium = isMobile ? 12.0 : 16.0;
    final spacingLarge = isMobile ? 16.0 : 20.0;
    final spacingXLarge = isMobile ? 20.0 : 24.0;
    
    return Scaffold(
      body: ErrorBoundary(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8.0 : 16.0,
                vertical: isMobile ? 16.0 : 20.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardMaxWidth),
                child: Card(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png', 
                              height: logoSize, 
                              width: logoSize,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  height: logoSize,
                                  width: logoSize,
                                  child: Icon(Icons.lock_outline, size: logoSize * 0.67),
                                );
                              },
                            ),
                            SizedBox(height: spacingSmall),
                            Text(
                              'OTP', 
                              textAlign: TextAlign.center, 
                              style: TextStyle(
                                fontSize: headingFontSize, 
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            SizedBox(height: spacingMedium),
                            Text(
                              'Your OTP code is on its way to your\nWhatsApp, please enter it here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: subheadingFontSize,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.grey[400] 
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacingXLarge),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate responsive field width based on available width
                            final availableWidth = constraints.maxWidth;
                            // For 6 fields with spacing: (6 * fieldWidth) + (5 * spaceBetween) <= availableWidth
                            // Let's use a smaller field width for mobile
                            final fieldWidth = availableWidth < 400 ? 36.0 : 40.0;
                            final spaceBetween = availableWidth < 400 ? 6.0 : 8.0;
                            
                            // Calculate the total width needed for all fields
                            final totalWidth = (6 * fieldWidth) + (5 * spaceBetween);
                            
                            return Center(
                              child: OTPTextField(
                                length: 6,
                                controller: _otpController,
                                width: totalWidth,
                                textFieldAlignment: MainAxisAlignment.center,
                                fieldWidth: fieldWidth,
                                fieldStyle: FieldStyle.box,
                                outlineBorderRadius: 6,
                                spaceBetween: spaceBetween,
                                style: TextStyle(
                                  fontSize: availableWidth < 400 ? 15 : 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                          contentPadding: const EdgeInsets.all(0),
                          otpFieldStyle: OtpFieldStyle(
                            backgroundColor: Theme.of(context).inputDecorationTheme.fillColor ?? 
                                (Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFF2C2C2C) 
                                    : const Color.fromRGBO(245, 245, 245, 1.0)),
                            borderColor: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF3A3A3A) 
                                : const Color.fromRGBO(229, 231, 235, 1.0),
                            enabledBorderColor: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF3A3A3A) 
                                : const Color.fromRGBO(229, 231, 235, 1.0),
                            focusBorderColor: Theme.of(context).brightness == Brightness.dark 
                                ? Theme.of(context).colorScheme.primary 
                                : const Color.fromRGBO(229, 231, 235, 1.0),
                            disabledBorderColor: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF3A3A3A) 
                                : const Color.fromRGBO(229, 231, 235, 1.0),
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
                            );
                          },
                        ),
                        SizedBox(height: spacingXLarge),
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: Text.rich(
                              TextSpan(
                                text: "Didn't get your code? ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.grey[400] 
                                      : Colors.black54,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Resend',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacingLarge),
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
