import 'package:bloc/bloc.dart';
import 'package:facility/app/cubit/app_state.dart';
import 'package:flutter/material.dart';

/// App-wide cubit scaffold you can extend for future features.
class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void setUser(String? userId) => emit(state.copyWith(userId: userId));

  void setReady(bool ready) => emit(state.copyWith(isReady: ready, errorMessage: null));

  void setError(String? message) => emit(state.copyWith(errorMessage: message));

  void toggleTheme() {
    // Cycle through: system -> light -> dark -> system
    final newMode = switch (state.themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    emit(state.copyWith(themeMode: newMode));
  }

  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));

  void setTheme(bool isDark) => emit(state.copyWith(
    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
  ));

  void reset() => emit(const AppState());
}

