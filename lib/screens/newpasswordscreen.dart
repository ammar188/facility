import 'dart:developer';

import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/homeScreen.dart';
import 'package:facility/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool currentPasswordError = false;
  bool newPasswordError = false;
  final AuthHooks _authHooks = AuthHooks();

  Future<void> _handleResetPassword() async {
    final messenger = ScaffoldMessenger.of(context);
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    
    // Validate fields
    if (currentPassword.isEmpty) {
      setState(() {
        currentPasswordError = true;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter your current password')),
      );
      return;
    }
    
    if (newPassword.isEmpty || newPassword.length < 6) {
      setState(() {
        newPasswordError = true;
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('New password must be at least 6 characters')),
      );
      return;
    }
    
    try {
      messenger.showSnackBar(const SnackBar(content: Text('Updating password...')));
      log('🔑 Reset password button clicked', name: 'NewPasswordScreen');
      
      // After OTP verification in forgot password flow, user is authenticated
      // So we can directly set the new password using useSetPassword
      // Note: Current password field is kept for UI consistency, but not used in this flow
      final result = await _authHooks.useSetPassword(password: newPassword);
      
      log('✅ Password updated successfully: ${result['success']}', name: 'NewPasswordScreen');
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to home screen after a brief delay
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<HomeScreen>(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    } catch (e) {
      log('❌ Reset password error: $e', name: 'NewPasswordScreen', error: e);
      messenger.hideCurrentSnackBar();
      String errorMessage = e.toString()
          .replaceAll('Exception: ', '')
          .replaceAll('AuthException: ', '')
          .replaceAll('GotrueException: ', '')
          .split('\n')
          .first
          .trim();
      if (errorMessage.isEmpty) {
        errorMessage = 'Failed to update password. Please try again.';
      }
      messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool hasError,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
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
          onChanged: (_) => onChanged(),
        ),
      ],
    );
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
                          'Set New Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color.fromRGBO(24, 24, 27, 1.0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your current and new password',
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
                              _buildPasswordField(
                                label: 'Current Password',
                                controller: _currentPasswordController,
                                hasError: currentPasswordError,
                                onChanged: () => setState(() => currentPasswordError = false),
                              ),
                              const SizedBox(height: 16),
                              _buildPasswordField(
                                label: 'New Password',
                                controller: _newPasswordController,
                                hasError: newPasswordError,
                                onChanged: () => setState(() => newPasswordError = false),
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Update Password',
                                onPressed: _handleResetPassword,
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

