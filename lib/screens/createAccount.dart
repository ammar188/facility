import 'package:facility/error_boundary.dart';
import 'package:facility/screens/otpVerify.dart';
import 'package:facility/widgets/phone_input_field.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:flutter/material.dart';
// using default TextStyle to avoid web asset loading issues

class LogintoYourAccount extends StatefulWidget {
  const LogintoYourAccount({super.key});

  @override
  State<LogintoYourAccount> createState() => _LogintoYourAccountState();
}

class _LogintoYourAccountState extends State<LogintoYourAccount> {
  bool agreeToTerms = false;
  bool rememberMe = false;

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
                // Add padding so the logo/heading aren't pinned to the top on tall forms
                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  const SizedBox(height: 20),
                  // Logo and Heading - outside the white card
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 160,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Create Your Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color.fromRGBO(24, 24, 27, 1.0)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0),

                  // Card with input fields
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Names
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLabeledField('First Name'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildLabeledField('Last Name'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildLabeledField('Email'),
                            const SizedBox(height: 16),

                            // Phone
                            const PhoneInputField(
                              hintText: '',
                              flagAssetPath: 'assets/images/flag.png',
                            ),
                            const SizedBox(height: 16),

                            // Passwords
                            _buildLabeledField('New Password', obscure: true),
                            const SizedBox(height: 16),
                            _buildLabeledField('Confirm Password', obscure: true),
                            const SizedBox(height: 20),

                        

                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Create Account',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<OtpVerify>(
                                    builder: (_) => const OtpVerify(),
                                  ),
                                );
                              },
                            ),
    
     const SizedBox(height: 4),

                          
                            Row(
                              children: [
                                Checkbox(
                                  value: agreeToTerms,
                                  onChanged: (value) => setState(() => agreeToTerms = value ?? false),
                                  side: const BorderSide(color: Color.fromARGB(255, 196, 185, 185)),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: const TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w300),
                                      children: [
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                             const SizedBox(height: 16),
                            
                              // Divider with 'or'
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text('or', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _socialButton(
                                    onPressed: () {},
                                    label: 'Google',
                                    assetPath: 'assets/images/google.png',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _socialButton(
                                    onPressed: () {},
                                    label: 'Facebook',
                                    assetPath: 'assets/images/facebook.png',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text('Already have an account? '),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
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
      ),
    );
  }

  static Widget _buildLabeledField(String label, {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color.fromRGBO(248, 248, 248, 1.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _socialButton({
    required VoidCallback onPressed,
    required String label,
    required String assetPath,
  }) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFF7F7F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      onPressed: onPressed,
      icon: Image.asset(
        assetPath,
        height: 18,
        filterQuality: FilterQuality.high,
      ),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}