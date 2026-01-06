import 'dart:developer';

import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/auth/otpVerify.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Responsive values
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
    final cardMaxWidth = isMobile ? screenWidth * 0.95 : (isTablet ? 500.0 : 600.0);
    final logoSize = isMobile ? 50.0 : (isTablet ? 60.0 : 65.0);
    final headingFontSize = isMobile ? 20.0 : (isTablet ? 22.0 : 24.0);
    final subheadingFontSize = isMobile ? 13.0 : (isTablet ? 14.0 : 15.0);
    final cardPadding = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);
    final spacingSmall = isMobile ? 2.0 : 4.0;
    final spacingMedium = isMobile ? 8.0 : 12.0;
    final spacingLarge = isMobile ? 16.0 : 20.0;
    final spacingXLarge = isMobile ? 20.0 : 24.0;
    
    return Scaffold(
      body: ErrorBoundary(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: double.infinity,
          height: double.infinity,
          child: Align(
            alignment: Alignment.topCenter,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: 0.0, 
                  horizontal: isMobile ? 8.0 : horizontalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: spacingLarge),
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: logoSize,
                          width: logoSize,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        SizedBox(height: spacingSmall),
                        Text(
                          'Forgot Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: headingFontSize,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: spacingMedium),
                        Text(
                          'Enter your phone number to receive OTP',
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
                    SizedBox(height: spacingLarge),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: cardMaxWidth),
                      child: Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
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
                              SizedBox(height: spacingXLarge),
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

