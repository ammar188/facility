import 'dart:developer';

import 'package:facility/error_boundary.dart';
import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/dashboard/dashboard_screen.dart';
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
      
      // Navigate to dashboard after a brief delay
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<DashboardScreen>(
            builder: (_) => const DashboardScreen(),
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
        Text(label, style: TextStyle(
          fontSize: 12, 
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[400] 
              : Colors.black54,
        )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
                          'Set New Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: headingFontSize,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        SizedBox(height: spacingMedium),
                        Text(
                          'Enter your current and new password',
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
                              _buildPasswordField(
                                label: 'Current Password',
                                controller: _currentPasswordController,
                                hasError: currentPasswordError,
                                onChanged: () => setState(() => currentPasswordError = false),
                              ),
                              SizedBox(height: spacingLarge),
                              _buildPasswordField(
                                label: 'New Password',
                                controller: _newPasswordController,
                                hasError: newPasswordError,
                                onChanged: () => setState(() => newPasswordError = false),
                              ),
                              SizedBox(height: spacingXLarge),
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

