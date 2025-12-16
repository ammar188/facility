import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:facility/app/auth/auth_repository.dart';
import 'package:facility/app/auth/auth_state.dart';
import 'package:facility/app/auth/token_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthCubit extends Cubit<AppAuthState> {
  AuthCubit({
    AuthRepository? repository,
    TokenStorage? storage,
    SupabaseClient? supabaseClient,
  })  : _repository = repository ?? 
            AuthRepository(
              supabaseClient: supabaseClient ?? Supabase.instance.client,
            ),
        _storage = storage ??
            (supabaseClient != null
                ? TokenStorage(supabaseClient)
                : const TokenStorage.noop()),
        super(const AppAuthState());

  final AuthRepository _repository;
  final TokenStorage _storage;

  Future<void> login(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: AppAuthStatus.loading, message: null));
    try {
      log('AuthCubit: Starting login with payload: $payload', name: 'AuthCubit');
      final res = await _repository.login(payload);
      log('AuthCubit: Login response received', name: 'AuthCubit');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      await _storage.saveTokens(
        data['accessToken'] as String?,
        data['refreshToken'] as String?,
      );
      emit(state.copyWith(status: AppAuthStatus.success, userId: data['user']?['id'] as String?));
    } catch (e, stackTrace) {
      log('AuthCubit: Login error: $e', name: 'AuthCubit', error: e, stackTrace: stackTrace);
      String errorMessage = 'Login failed';
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid phone/email or password';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please verify your email first';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      emit(state.copyWith(status: AppAuthStatus.error, message: errorMessage));
    }
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AppAuthStatus.loading, message: null));
    try {
      await _repository.logout();
      await _storage.clearTokens();
      emit(const AppAuthState(status: AppAuthStatus.success, userId: null));
    } catch (e) {
      emit(state.copyWith(status: AppAuthStatus.error, message: e.toString()));
    }
  }

  Future<void> register(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: AppAuthStatus.loading, message: null));
    try {
      log('AuthCubit: Starting register with payload: $payload', name: 'AuthCubit');
      final res = await _repository.register(payload);
      log('AuthCubit: Register response received', name: 'AuthCubit');
      log('AuthCubit: Register response data: $res', name: 'AuthCubit');
      final userId = (res['data']?['user'] as Map?)?['id'] as String?;
      emit(state.copyWith(status: AppAuthStatus.success, userId: userId));
    } catch (e, stackTrace) {
      log('AuthCubit: Register error: $e', name: 'AuthCubit', error: e, stackTrace: stackTrace);
      
      // The error message from AuthRepository should already be user-friendly
      String errorMessage = 'Registration failed';
      final errorStr = e.toString();
      
      // Use the error message as-is if it's already formatted
      if (errorStr.contains('Exception: ')) {
        errorMessage = errorStr.replaceAll('Exception: ', '');
      } else {
        errorMessage = errorStr;
      }
      
      // Clean up any remaining technical details
      errorMessage = errorMessage
          .replaceAll('AuthException: ', '')
          .replaceAll('GotrueException: ', '')
          .split('\n')
          .first
          .trim();
      
      log('AuthCubit: Register error message: $errorMessage', name: 'AuthCubit');
      emit(state.copyWith(status: AppAuthStatus.error, message: errorMessage));
    }
  }

  Future<void> verifyRegistration(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: AppAuthStatus.loading, message: null));
    try {
      final res = await _repository.verifyRegistration(payload);
      final data = res['data'] as Map<String, dynamic>? ?? {};
      await _storage.saveTokens(
        data['accessToken'] as String?,
        data['refreshToken'] as String?,
      );
      emit(state.copyWith(status: AppAuthStatus.success, userId: data['user']?['id'] as String?));
    } catch (e) {
      emit(state.copyWith(status: AppAuthStatus.error, message: e.toString()));
    }
  }

  Future<void> forgotPassword(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: AppAuthStatus.loading, message: null));
    try {
      await _repository.forgotPassword(payload);
      emit(state.copyWith(status: AppAuthStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AppAuthStatus.error, message: e.toString()));
    }
  }

  Future<void> resetPassword(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: AppAuthStatus.loading, message: null));
    try {
      final res = await _repository.resetPassword(payload);
      final data = res['data'] as Map<String, dynamic>? ?? {};
      await _storage.saveTokens(
        data['accessToken'] as String?,
        data['refreshToken'] as String?,
      );
      emit(state.copyWith(status: AppAuthStatus.success, userId: data['user']?['id'] as String?));
    } catch (e) {
      emit(state.copyWith(status: AppAuthStatus.error, message: e.toString()));
    }
  }
}

