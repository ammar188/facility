import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:facility/api.dart';
import 'package:facility/app/auth/auth.dart';
import 'package:facility/app/cubit/app_cubit.dart';
import 'package:facility/app/profile/profile.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

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

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: ApiConfig.supabaseUrl,
      anonKey: ApiConfig.supabaseAnonKey,
    );
    log('Supabase initialized successfully', name: 'Bootstrap');
  } catch (e) {
    log('Failed to initialize Supabase: $e', name: 'Bootstrap');
  }

  // Wrap the app with BlocProviders
  final appWidget = await builder();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(
          create: (_) => AppCubit(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) {
            try {
              final supabaseClient = Supabase.instance.client;
              log('Bootstrap: Creating AuthCubit with Supabase client', name: 'Bootstrap');
              return AuthCubit(supabaseClient: supabaseClient);
            } catch (e) {
              log('Bootstrap: Failed to get Supabase client, using noop storage: $e', name: 'Bootstrap');
              return AuthCubit();
            }
          },
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(),
        ),
      ],
      child: appWidget,
    ),
  );
}
