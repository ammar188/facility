import 'dart:developer';

import 'package:facility/app/auth/auth.dart';
import 'package:facility/app/profile/profile.dart';
import 'package:facility/l10n/l10n.dart';
import 'package:facility/screens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) {
              try {
                final supabaseClient = Supabase.instance.client;
                log('App: Creating AuthCubit with Supabase client', name: 'App');
                return AuthCubit(supabaseClient: supabaseClient);
              } catch (e) {
                log('App: Failed to get Supabase client, using noop storage: $e', name: 'App');
                return AuthCubit();
              }
            },
          ),
          BlocProvider<ProfileCubit>(
            create: (_) => ProfileCubit(),
          ),
        ],
        child: const LoginScreen(),
      ),
    );
  }
}
