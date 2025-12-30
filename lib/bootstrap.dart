import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:facility/api.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Initialize Supabase with session persistence
  try {
    await Supabase.initialize(
      url: ApiConfig.supabaseUrl,
      anonKey: ApiConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
    log('Supabase initialized successfully', name: 'Bootstrap');
    
    // Log current session status
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      log('✅ Session restored on bootstrap - User ID: ${session.user.id}', name: 'Bootstrap');
    } else {
      log('ℹ️ No session found on bootstrap', name: 'Bootstrap');
    }
  } catch (e) {
    log('Failed to initialize Supabase: $e', name: 'Bootstrap');
  }

  runApp(await builder());
}
