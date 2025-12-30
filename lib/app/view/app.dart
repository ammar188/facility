import 'dart:developer';

import 'package:facility/dashboard/dashboard.dart';
import 'package:facility/l10n/l10n.dart';
import 'package:facility/screens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _listenToAuthChanges();
  }

  /// Check if user is already authenticated on app start
  Future<void> _checkAuthState() async {
    try {
      // Wait a bit for Supabase to restore session from storage
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Try to get current session
      Session? session = Supabase.instance.client.auth.currentSession;
      
      // If no session, try to get user (which might trigger session restoration)
      if (session == null) {
        try {
          final userResponse = await Supabase.instance.client.auth.getUser();
          if (userResponse.user != null) {
            session = Supabase.instance.client.auth.currentSession;
          }
        } catch (_) {
          // Ignore errors, just means no user
        }
      }
      
      // Check if session exists and is not expired
      if (session != null) {
        final now = DateTime.now().toUtc();
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000).toUtc();
        
        if (now.isBefore(expiresAt)) {
          log('✅ Existing session found - User ID: ${session.user.id}', name: 'App');
          log('  Session expires at: $expiresAt', name: 'App');
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
        } else {
          log('⚠️ Session expired', name: 'App');
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
          });
        }
      } else {
        log('ℹ️ No valid session found', name: 'App');
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('❌ Error checking auth state: $e', name: 'App', error: e);
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  /// Listen to auth state changes (login/logout)
  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      log('🔄 Auth state changed: $event', name: 'App');

      if (event == AuthChangeEvent.signedIn && session != null) {
        log('✅ User signed in - User ID: ${session.user.id}', name: 'App');
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
        }
      } else if (event == AuthChangeEvent.signedOut) {
        log('🚪 User signed out', name: 'App');
        if (mounted) {
          setState(() {
            _isAuthenticated = false;
            _isLoading = false;
          });
        }
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        log('🔄 Token refreshed - User ID: ${session.user.id}', name: 'App');
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
          });
        }
      } else if (event == AuthChangeEvent.initialSession && session != null) {
        log('🔄 Initial session restored - User ID: ${session.user.id}', name: 'App');
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: Colors.blue[700]!),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardPage(),
      },
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isAuthenticated
              ? const DashboardPage()
              : const LoginScreen(),
    );
  }
}
