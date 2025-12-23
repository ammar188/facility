import 'dart:developer';

import 'package:facility/app/auth/auth.dart';
import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/createAccount.dart';
import 'package:facility/screens/forgetpassScreen.dart';
import 'package:facility/screens/otpVerify.dart';
import 'package:facility/screens/homeScreen.dart';
import 'package:facility/widgets/phone_input_field.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool remember = false;
  bool agreeToTerms = false;
  bool loginPhoneError = false;
  bool loginPassError = false;
  bool firstNameError = false;
  bool lastNameError = false;
  bool emailError = false;
  bool createPhoneError = false;
  bool newPassError = false;
  bool confirmPassError = false;
  bool _isExpanded = false; // false = login, true = create account
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _loginPhoneController = TextEditingController();
  final TextEditingController _loginPassController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _createPhoneController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
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
      
      // Navigate to home screen after successful password login
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<HomeScreen>(
            builder: (_) => const HomeScreen(),
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
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<OtpVerify>(
            builder: (_) => OtpVerify(phone: phone),
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _loginPhoneController.dispose();
    _loginPassController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _createPhoneController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _validateLogin() {
    final cleaned = _loginPhoneController.text.trim().replaceAll(RegExp(r'[\\s\\-\\(\\)+]'), '');
    setState(() {
      // allow variable length, require at least 10 digits
      loginPhoneError = cleaned.length < 10;
      loginPassError = _loginPassController.text.trim().isEmpty;
    });
    return !(loginPhoneError || loginPassError);
  }

  // _validateCreate no longer used; create flow navigates to dedicated screen

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    return Scaffold(
      body: BlocListener<AuthCubit, AppAuthState>(
        listener: (context, state) {
          messenger.hideCurrentSnackBar();
          if (state.status == AppAuthStatus.loading) {
            messenger.showSnackBar(const SnackBar(content: Text('Loading...')));
          } else if (state.status == AppAuthStatus.success) {
            messenger.showSnackBar(const SnackBar(content: Text('Success')));
            Navigator.of(context).push(
              MaterialPageRoute<OtpVerify>(
                builder: (_) => OtpVerify(phone: _createPhoneController.text.trim()),
              ),
            );
          } else if (state.status == AppAuthStatus.error) {
            messenger.showSnackBar(
              SnackBar(content: Text(state.message ?? 'Something went wrong')),
            );
          }
        },
        child: ErrorBoundary(
          child: Container(
            color: const Color.fromRGBO(248, 248, 248, 1.0),
            width: double.infinity,
            // height: double.infinity,
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
                      const SizedBox(height: 20),
                      // Logo and Heading - outside the white card
                      Column(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          const SizedBox(height: 0),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              _isExpanded ? 'Create Your Account' : 'Log In Your Account',
                              key: ValueKey(_isExpanded),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color.fromRGBO(24, 24, 27, 1.0)),
                            ),
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
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Create Account Fields (expandable)
                                SizeTransition(
                                  sizeFactor: _animation,
                                  axisAlignment: -1.0,
                                  child: ClipRect(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Names
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildLabeledField(
                                                'First Name',
                                                controller: _firstNameController,
                                                hasError: firstNameError,
                                                onChanged: (v) => setState(() => firstNameError = false),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildLabeledField(
                                                'Last Name',
                                                controller: _lastNameController,
                                                hasError: lastNameError,
                                                onChanged: (v) => setState(() => lastNameError = false),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),

                                        // Email
                                        _buildLabeledField(
                                          'Email',
                                          controller: _emailController,
                                          hasError: emailError,
                                          onChanged: (v) => setState(() => emailError = false),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),

                                // Phone (always visible)
                                PhoneInputField(
                                  hintText: '',
                                  flagAssetPath: 'assets/images/flag.png',
                                  controller: _isExpanded ? _createPhoneController : _loginPhoneController,
                                  hasError: _isExpanded ? createPhoneError : loginPhoneError,
                                  onChanged: (_) => setState(() {
                                    if (_isExpanded) {
                                      createPhoneError = false;
                                    } else {
                                      loginPhoneError = false;
                                    }
                                  }),
                                ),

                                // Password fields
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 500),
                                  crossFadeState: _isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 16),
                                      const Text('Password', style: TextStyle(fontSize: 12, color: Color.fromARGB(137, 0, 0, 0))),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: _loginPassController,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: '',
                                          filled: true,
                                          fillColor: const Color.fromRGBO(248, 248, 248, 1.0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: loginPassError ? const BorderSide(color: Colors.red) : BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: loginPassError ? const BorderSide(color: Colors.red) : BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: loginPassError ? const BorderSide(color: Colors.red) : BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        ),
                                        obscureText: true,
                                        onChanged: (_) => setState(() => loginPassError = false),
                                      ),
                                    ],
                                  ),
                                  secondChild: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(height: 16),
                                      _buildLabeledField(
                                        'New Password',
                                        obscure: true,
                                        controller: _newPassController,
                                        hasError: newPassError,
                                        onChanged: (_) => setState(() => newPassError = false),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildLabeledField(
                                        'Confirm Password',
                                        obscure: true,
                                        controller: _confirmPassController,
                                        hasError: confirmPassError,
                                        onChanged: (_) => setState(() => confirmPassError = false),
                                      ),
                                    ],
                                  ),
                                ),

                                // Create Account specific fields (expandable)
                                SizeTransition(
                                  sizeFactor: _animation,
                                  axisAlignment: -1.0,
                                  child: ClipRect(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),

                                // Forget Password / Terms (conditional)
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 500),
                                  crossFadeState: _isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: const SizedBox(height: 8),
                                  secondChild: const SizedBox(height: 4),
                                ),

                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 300),
                                  crossFadeState: _isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<ForgetPassScreen>(
                                            builder: (_) => const ForgetPassScreen(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                      child: const Text('Forget Password', style: TextStyle(fontSize: 11, color: Colors.grey, decoration: TextDecoration.underline)),
                                    ),
                                  ),
                                  secondChild: const SizedBox.shrink(),
                                ),

                                const SizedBox(height: 12),
                                PrimaryButton(
                                  label: _isExpanded ? 'Create Account' : 'Sign In',
                                  onPressed: () {
                                    if (_isExpanded) {
                                      // Navigate to dedicated Create Account screen which uses OTP-based phone registration
                                      Navigator.of(context).push(
                                        MaterialPageRoute<LogintoYourAccount>(
                                          builder: (_) => const LogintoYourAccount(),
                                        ),
                                      );
                                    } else {
                                      if (_validateLogin()) {
                                        _handleLogin();
                                      }
                                    }
                                  },
                                ),

                                // Remember me / Terms checkbox
                                AnimatedCrossFade(
                                  duration: const Duration(milliseconds: 500),
                                  crossFadeState: _isExpanded
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  firstChild: Column(
                                    children: [
                                      const SizedBox(height: 6),
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
                                    ],
                                  ),
                                  secondChild: Column(
                                    children: [
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
                                    ],
                                  ),
                                ),

                                // Divider with 'or' and Social buttons (always visible)
                                const SizedBox(height: 14),
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
                                const SizedBox(height: 15),
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

                                const SizedBox(height: 16),
                                Center(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        _isExpanded ? 'Already have an account? ' : 'Don\'t have an account? ',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      TextButton(
                                        onPressed: _toggleExpansion,
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                        child: Text(
                                          _isExpanded ? 'Sign In' : 'Create New Account',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black,
                                            decoration: TextDecoration.underline,
                                            fontWeight: _isExpanded ? FontWeight.normal : FontWeight.w600,
                                          ),
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
      ),
    );
  }

  Widget _buildLabeledField(String label,
      {bool obscure = false,
      TextEditingController? controller,
      bool hasError = false,
      ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
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
