import 'package:facility/error_boundary.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';

class OtpVerify extends StatefulWidget {
  const OtpVerify({super.key});

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final OtpFieldController _otpController = OtpFieldController();
  String _currentOtp = '';

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
                          onPressed: _currentOtp.length == 6 ? () {
                            // Handle OTP verification here
                            print('OTP entered: $_currentOtp');
                          } : () {},
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
