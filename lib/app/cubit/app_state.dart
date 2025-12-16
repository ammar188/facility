import 'package:flutter/foundation.dart';

@immutable
class AppState {
  const AppState({
    this.userId,
    this.isReady = true,
    this.errorMessage,
  });

  final String? userId;
  final bool isReady;
  final String? errorMessage;

  AppState copyWith({
    String? userId,
    bool? isReady,
    String? errorMessage,
  }) {
    return AppState(
      userId: userId ?? this.userId,
      isReady: isReady ?? this.isReady,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState &&
        other.userId == userId &&
        other.isReady == isReady &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(userId, isReady, errorMessage);
}

