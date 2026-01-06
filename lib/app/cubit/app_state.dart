import 'package:flutter/material.dart';

@immutable
class AppState {
  const AppState({
    this.userId,
    this.isReady = true,
    this.errorMessage,
    this.themeMode = ThemeMode.system,
  });

  final String? userId;
  final bool isReady;
  final String? errorMessage;
  final ThemeMode themeMode;

  bool get isDarkMode {
    // This will be determined by the system when themeMode is system
    return themeMode == ThemeMode.dark;
  }

  AppState copyWith({
    String? userId,
    bool? isReady,
    String? errorMessage,
    ThemeMode? themeMode,
  }) {
    return AppState(
      userId: userId ?? this.userId,
      isReady: isReady ?? this.isReady,
      errorMessage: errorMessage,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.userId == userId &&
        other.isReady == isReady &&
        other.errorMessage == errorMessage &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(userId, isReady, errorMessage, themeMode);
}


