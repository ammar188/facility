import 'dart:developer';

import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/widgets/phone_input_field.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:facility/screens/otpVerify.dart';
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

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool firstNameError = false;
  bool lastNameError = false;
  bool emailError = false;
  bool phoneError = false;
  bool passwordError = false;
  bool confirmPasswordError = false;
  final AuthHooks _authHooks = AuthHooks();

  Future<void> _handleRegister() async {
    final messenger = ScaffoldMessenger.of(context);
    final phone = _phoneController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = '$firstName $lastName'.trim();
    
    try {
      messenger.showSnackBar(const SnackBar(content: Text('Sending OTP...')));
      log('📝 Register button clicked', name: 'CreateAccount');
      log('  Phone: $phone', name: 'CreateAccount');
      log('  Full Name: $fullName', name: 'CreateAccount');
      print('[CreateAccount] Register button clicked for phone: $phone, fullName: $fullName');
      
      log('📤 Calling useRegister hook (OTP-based):', name: 'CreateAccount');
      log('  Phone: "$phone"', name: 'CreateAccount');
      log('  Full Name: "$fullName"', name: 'CreateAccount');
      print('[CreateAccount] Calling useRegister hook...');
      
      // Get email if provided
      final email = _emailController.text.trim();
      
      // Call useRegister with phone, fullName, and email (OTP-based registration)
      final result = await _authHooks.useRegister(
        phone: phone,
        fullName: fullName,
        email: email.isNotEmpty ? email : null,
      );
      
      log('📥 useRegister result received:', name: 'CreateAccount');
      log('  Success: ${result['success']}', name: 'CreateAccount');
      log('  Message: ${result['message']}', name: 'CreateAccount');
      print('[CreateAccount] useRegister success: ${result['success']} - ${result['message']}');
      
      log('✅ OTP sent successfully', name: 'CreateAccount');
      print('[CreateAccount] ✅ OTP sent successfully, showing SnackBar');
      messenger.hideCurrentSnackBar();

      // Show success then navigate to OTP screen
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('OTP sent to $phone'),
            duration: const Duration(seconds: 2),
          ),
        );
        // Navigate after a brief pause so the SnackBar is visible
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<OtpVerify>(
              builder: (_) => OtpVerify(phone: phone),
            ),
          );
        }
      }
    } catch (e) {
      log('❌ Registration error: $e', name: 'CreateAccount', error: e);
      messenger.hideCurrentSnackBar();
      // For OTP-based phone registration, just show the Supabase error message (no email wording)
      String errorMessage = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AuthException: ', '')
          .replaceAll('GotrueException: ', '')
          .split('\n')
          .first
          .trim();
      if (errorMessage.isEmpty) {
        errorMessage = 'Registration failed. Please try again.';
      }
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final phoneText = _phoneController.text.trim();
    
    // Phone is REQUIRED: check it has at least some digits (after removing formatting)
    final phoneDigits = phoneText.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final isValidPhone = phoneDigits.length >= 10; // At least 10 digits
    
    // For OTP-based registration we only NEED:
    // - firstName, lastName, phone, agreeToTerms
    // Email, password fields are optional at this step.
    setState(() {
      firstNameError = _firstNameController.text.trim().isEmpty;
      lastNameError = _lastNameController.text.trim().isEmpty;
      emailError = false; // ignore email for registration
      phoneError = !isValidPhone;
      passwordError = false;
      confirmPasswordError = false;
    });

    final hasErrors = firstNameError ||
        lastNameError ||
        phoneError ||
        !agreeToTerms;
    
    log('🔍 Validation check (OTP registration):', name: 'CreateAccount');
    log('  firstNameError: $firstNameError', name: 'CreateAccount');
    log('  lastNameError: $lastNameError', name: 'CreateAccount');
    log('  phoneError: $phoneError (phone: "$phoneText", digits: "$phoneDigits")', name: 'CreateAccount');
    log('  agreeToTerms: $agreeToTerms', name: 'CreateAccount');
    log('  hasErrors: $hasErrors', name: 'CreateAccount');

    return !hasErrors;
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
                            'Create Your Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(24, 24, 27, 1.0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildLabeledField(
                                        'First Name',
                                        controller: _firstNameController,
                                        hasError: firstNameError,
                                        onChanged: (_) => setState(() => firstNameError = false),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildLabeledField(
                                        'Last Name',
                                        controller: _lastNameController,
                                        hasError: lastNameError,
                                        onChanged: (_) => setState(() => lastNameError = false),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildLabeledField(
                                  'Email',
                                  controller: _emailController,
                                  hasError: emailError,
                                  onChanged: (_) => setState(() => emailError = false),
                                ),
                                const SizedBox(height: 16),
                                PhoneInputField(
                                  hintText: '',
                                  flagAssetPath: 'assets/images/flag.png',
                                  controller: _phoneController,
                                  hasError: phoneError,
                                  onChanged: (_) => setState(() => phoneError = false),
                                ),
                                const SizedBox(height: 16),
                                _buildLabeledField(
                                  'New Password',
                                  controller: _passwordController,
                                  obscure: true,
                                  hasError: passwordError,
                                  onChanged: (_) => setState(() => passwordError = false),
                                ),
                                const SizedBox(height: 16),
                                _buildLabeledField(
                                  'Confirm Password',
                                  controller: _confirmPasswordController,
                                  obscure: true,
                                  hasError: confirmPasswordError,
                                  onChanged: (_) => setState(() => confirmPasswordError = false),
                                ),
                                const SizedBox(height: 20),
                                const SizedBox(height: 20),
                                PrimaryButton(
                                  label: 'Create Account',
                                  onPressed: () {
                                    log('🔘 Create Account button clicked', name: 'CreateAccount');
                                    log('  First Name: "${_firstNameController.text.trim()}"', name: 'CreateAccount');
                                    log('  Last Name: "${_lastNameController.text.trim()}"', name: 'CreateAccount');
                                    log('  Email: "${_emailController.text.trim()}"', name: 'CreateAccount');
                                    log('  Phone: "${_phoneController.text.trim()}"', name: 'CreateAccount');
                                    log('  Password length: ${_passwordController.text.trim().length}', name: 'CreateAccount');
                                    log('  Confirm Password length: ${_confirmPasswordController.text.trim().length}', name: 'CreateAccount');
                                    log('  Agree to Terms: $agreeToTerms', name: 'CreateAccount');
                                    
                                    if (_validate()) {
                                      log('✅ Validation passed, calling _handleRegister', name: 'CreateAccount');
                                      _handleRegister();
                                    } else {
                                      log('❌ Validation failed', name: 'CreateAccount');
                                      log('  firstNameError: $firstNameError', name: 'CreateAccount');
                                      log('  lastNameError: $lastNameError', name: 'CreateAccount');
                                      log('  emailError: $emailError', name: 'CreateAccount');
                                      log('  phoneError: $phoneError', name: 'CreateAccount');
                                      log('  passwordError: $passwordError', name: 'CreateAccount');
                                      log('  confirmPasswordError: $confirmPasswordError', name: 'CreateAccount');
                                      log('  agreeToTerms: $agreeToTerms', name: 'CreateAccount');
                                      
                                      // Show specific validation errors
                                      String errorMsg = 'Please fix the following:\n';
                                      if (firstNameError) errorMsg += '• First name is required\n';
                                      if (lastNameError) errorMsg += '• Last name is required\n';
                                      if (emailError) errorMsg += '• Valid email is required\n';
                                      if (phoneError) errorMsg += '• Phone number is required\n';
                                      if (passwordError) errorMsg += '• Password is required\n';
                                      if (confirmPasswordError) errorMsg += '• Passwords do not match\n';
                                      if (!agreeToTerms) errorMsg += '• Please agree to Terms & Conditions\n';
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg.trim()),
                                          duration: const Duration(seconds: 4),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
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

  Widget _buildLabeledField(
    String label, {
    bool obscure = false,
    TextEditingController? controller,
    bool hasError = false,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: label.toLowerCase().contains('email') 
              ? TextInputType.emailAddress 
              : TextInputType.text,
          textInputAction: label.toLowerCase().contains('password') 
              ? TextInputAction.done 
              : TextInputAction.next,
          autocorrect: false,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: const Color.fromRGBO(248, 248, 248, 1.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: hasError ? const BorderSide(color: Colors.red) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: hasError ? const BorderSide(color: Colors.red) : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: hasError ? const BorderSide(color: Colors.red) : BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: onChanged,
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
