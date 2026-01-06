import 'dart:developer';

import 'package:facility/app/auth/auth.dart';
import 'package:facility/app/cubit/app_cubit.dart';
import 'package:facility/app/cubit/app_state.dart';
import 'package:facility/app/routes/app_routes.dart';
import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/auth/forgetpassScreen.dart';
import 'package:facility/screens/auth/otpVerify.dart';
import 'package:facility/widgets/phone_input_field.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        context.go(AppRoutes.home.path);
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

  bool _validateCreateAccount() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _createPhoneController.text.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final newPass = _newPassController.text.trim();
    final confirmPass = _confirmPassController.text.trim();
    
    setState(() {
      firstNameError = firstName.isEmpty;
      lastNameError = lastName.isEmpty;
      emailError = email.isEmpty || !email.contains('@');
      createPhoneError = phone.length < 10;
      newPassError = newPass.isEmpty;
      confirmPassError = confirmPass.isEmpty || newPass != confirmPass;
    });
    
    return !(firstNameError || lastNameError || emailError || createPhoneError || newPassError || confirmPassError);
  }

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    // Responsive values
    final cardMaxWidth = isMobile ? screenWidth * 0.95 : (isTablet ? 500.0 : 600.0);
    final logoSize = isMobile ? 50.0 : (isTablet ? 59.0 : 65.0);
    final headingFontSize = isMobile ? 20.0 : (isTablet ? 22.0 : 24.0);
    final cardPadding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final spacingSmall = isMobile ? 4.0 : 6.0;
    final spacingMedium = isMobile ? 8.0 : 12.0;
    final spacingLarge = isMobile ? 16.0 : 20.0;
    
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
            color: Theme.of(context).scaffoldBackgroundColor,
            width: double.infinity,
            // height: double.infinity,
            child: Align(
              alignment: Alignment.topCenter,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    top: 0, 
                    bottom: 2.0, 
                    left: isMobile ? 8.0 : 2.0, 
                    right: isMobile ? 8.0 : 2.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Theme toggle button
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: isMobile ? 12.0 : 20.0, 
                            top: 0.0,
                          ),
                          child: BlocBuilder<AppCubit, AppState>(
                            builder: (context, state) {
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              IconData icon;
                              String tooltip;
                              
                              switch (state.themeMode) {
                                case ThemeMode.system:
                                  icon = isDark ? Icons.brightness_auto : Icons.brightness_auto;
                                  tooltip = 'Following System (${isDark ? "Dark" : "Light"})';
                                  break;
                                case ThemeMode.light:
                                  icon = Icons.light_mode;
                                  tooltip = 'Light Mode';
                                  break;
                                case ThemeMode.dark:
                                  icon = Icons.dark_mode;
                                  tooltip = 'Dark Mode';
                                  break;
                              }
                              
                              return IconButton(
                                icon: Icon(
                                  icon,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                onPressed: () {
                                  context.read<AppCubit>().toggleTheme();
                                },
                                tooltip: tooltip,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: spacingSmall),
                      // Logo and Heading - outside the white card
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                          SizedBox(height: spacingMedium),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              _isExpanded ? 'Create Your Account' : 'Log In Your Account',
                              key: ValueKey(_isExpanded),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: headingFontSize, 
                                fontWeight: FontWeight.w600, 
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          SizedBox(height: spacingMedium),
                        ],
                      ),
                      SizedBox(height: spacingLarge),
                      // Card with input fields
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cardMaxWidth),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? const Color(0xFF3A3A3A) 
                                  : const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: cardPadding, 
                              right: cardPadding, 
                              top: cardPadding, 
                              bottom: cardPadding,
                            ),
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
                                        SizedBox(height: spacingLarge),

                                        // Email
                                        _buildLabeledField(
                                          'Email',
                                          controller: _emailController,
                                          hasError: emailError,
                                          onChanged: (v) => setState(() => emailError = false),
                                        ),
                                        SizedBox(height: spacingLarge),
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
                                      SizedBox(height: spacingLarge),
                                      Text('Password', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color)),
                                      SizedBox(height: spacingSmall),
                                      _HoverablePasswordInput(
                                        controller: _loginPassController,
                                        hasError: loginPassError,
                                        onChanged: (_) => setState(() => loginPassError = false),
                                      ),
                                    ],
                                  ),
                                  secondChild: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: spacingLarge),
                                      _buildLabeledField(
                                        'New Password',
                                        obscure: true,
                                        controller: _newPassController,
                                        hasError: newPassError,
                                        onChanged: (_) => setState(() => newPassError = false),
                                      ),
                                      SizedBox(height: spacingLarge),
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
                                        SizedBox(height: spacingLarge),
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
                                  firstChild: SizedBox(height: spacingMedium),
                                  secondChild: SizedBox(height: spacingSmall),
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
                                      child: Text(
                                        'Forget Password',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.grey[400] 
                                              : const Color(0xFF70737D),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                  secondChild: const SizedBox.shrink(),
                                ),

                                SizedBox(height: spacingMedium),
                                PrimaryButton(
                                  label: _isExpanded ? 'Create Account' : 'Sign In',
                                  onPressed: () {
                                    if (_isExpanded) {
                                      // Validate fields and show red borders on empty fields
                                      // Do NOT navigate - just validate
                                      if (_validateCreateAccount()) {
                                        // All fields are valid - you can handle registration here if needed
                                        // For now, just show success message
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('All fields are valid!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        // Validation failed - red borders are already shown
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please fill in all required fields'),
                                            backgroundColor: Colors.red,
                                        ),
                                      );
                                      }
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
                                      SizedBox(height: spacingSmall),
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 0.75,
                                            child: Checkbox(
                                              value: remember,
                                              onChanged: (value) => setState(() => remember = value ?? false),
                                              visualDensity: VisualDensity.compact,
                                              side: BorderSide(
                                                color: Theme.of(context).brightness == Brightness.dark 
                                                    ? Colors.grey[600]! 
                                                    : Colors.grey.shade400, 
                                                width: 1.2,
                                              ),
                                              activeColor: Theme.of(context).brightness == Brightness.dark 
                                                  ? Colors.grey[700]! 
                                                  : Colors.grey.shade300, // light gray fill
                                              checkColor: Theme.of(context).brightness == Brightness.dark 
                                                  ? Colors.white 
                                                  : Colors.black, // black tick
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                          Text('Remember me', style: TextStyle(fontSize: 12, color: Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.grey[400] 
                                              : const Color(0xFF70737D))),
                                        ],
                                      ),
                                    ],
                                  ),
                                  secondChild: Column(
                                    children: [
                                      SizedBox(height: spacingSmall),
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 0.75,
                                            child: Checkbox(
                                            value: agreeToTerms,
                                            onChanged: (value) => setState(() => agreeToTerms = value ?? false),
                                            side: BorderSide(color: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.grey[600]! 
                                                : const Color.fromARGB(255, 196, 185, 185)),
                                            activeColor: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.grey[700]! 
                                                : Colors.grey.shade300, // light gray fill
                                            checkColor: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.white 
                                                : Colors.black, // black tick
                                              visualDensity: VisualDensity.compact,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'I agree to the ',
                                                style: TextStyle(
                                                  color: Theme.of(context).brightness == Brightness.dark 
                                                      ? Colors.grey[400] 
                                                      : Colors.black54, 
                                                  fontWeight: FontWeight.w300,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: 'Terms & Conditions',
                                                    style: TextStyle(
                                                      color: Theme.of(context).brightness == Brightness.dark 
                                                          ? Colors.white 
                                                          : Colors.black87, 
                                                      fontWeight: FontWeight.w600,
                                                    ),
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
                                SizedBox(height: spacingMedium),
                                Row(
                                  children: [
                                    Expanded(child: Divider(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.grey[700]! 
                                          : Colors.grey.shade300, 
                                      height: 1,
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        'or', 
                                        style: TextStyle(
                                          fontSize: 11, 
                                          color: Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.grey[400] 
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(
                                      color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.grey[700]! 
                                          : Colors.grey.shade300, 
                                      height: 1,
                                    )),
                                  ],
                                ),
                                SizedBox(height: spacingMedium),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _socialButton(
                                        onPressed: () {},
                                        label: 'Google',
                                        assetPath: 'assets/images/Google.png',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _socialButton(
                                        onPressed: () {},
                                        label: 'Facebook',
                                        assetPath: 'assets/images/Facebook.png',
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: spacingLarge),
                                Center(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        _isExpanded ? 'Already have an account? ' : 'Don\'t have an account? ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _toggleExpansion,
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                        child: Text(
                                          _isExpanded ? 'Sign In' : 'Create New Account',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                            decoration: TextDecoration.underline,
                                            fontWeight: FontWeight.bold,
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
    return _HoverableInputField(
      label: label,
      obscure: obscure,
      controller: controller,
      hasError: hasError,
      onChanged: onChanged,
    );
  }

  Widget _socialButton({
    required VoidCallback onPressed,
    required String label,
    required String assetPath,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: isDark 
            ? Theme.of(context).cardColor 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isDark 
              ? const Color(0xFF3A3A3A) 
              : const Color(0xFFF7F7F7)),
        ),
        foregroundColor: isDark 
            ? Colors.white 
            : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      onPressed: onPressed,
      icon: Image.asset(
        assetPath,
        height: 18,
        filterQuality: FilterQuality.high,
      ),
      label: Text(
        'Continue with $label',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _HoverableInputField extends StatefulWidget {
  const _HoverableInputField({
    required this.label,
    this.obscure = false,
    this.controller,
    this.hasError = false,
    this.onChanged,
  });

  final String label;
  final bool obscure;
  final TextEditingController? controller;
  final bool hasError;
  final ValueChanged<String>? onChanged;

  @override
  State<_HoverableInputField> createState() => _HoverableInputFieldState();
}

class _HoverableInputFieldState extends State<_HoverableInputField> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).inputDecorationTheme.fillColor;
    final hoverColor = isDark 
        ? const Color(0xFF2A2A2A) 
        : const Color(0xFFF0F0F0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label, 
          style: TextStyle(
            fontSize: 12, 
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 6),
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: _isHovered ? hoverColor : baseColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.hasError 
                    ? Colors.red 
                    : (isDark 
                        ? const Color(0xFF3A3A3A) 
                        : const Color(0xFFE5E7EB)),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    obscureText: widget.obscure,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: widget.onChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HoverablePasswordInput extends StatefulWidget {
  const _HoverablePasswordInput({
    required this.controller,
    required this.hasError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool hasError;
  final ValueChanged<String> onChanged;

  @override
  State<_HoverablePasswordInput> createState() => _HoverablePasswordInputState();
}

class _HoverablePasswordInputState extends State<_HoverablePasswordInput> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = Theme.of(context).inputDecorationTheme.fillColor;
    final hoverColor = isDark 
        ? const Color(0xFF2A2A2A) 
        : const Color(0xFFF0F0F0);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: _isHovered ? hoverColor : baseColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.hasError 
                ? Colors.red 
                : (isDark 
                    ? const Color(0xFF3A3A3A) 
                    : const Color(0xFFE5E7EB)),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.0,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  isCollapsed: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                obscureText: true,
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
