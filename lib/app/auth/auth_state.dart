import 'package:equatable/equatable.dart';

enum AppAuthStatus { initial, loading, success, error }

class AppAuthState extends Equatable {
  const AppAuthState({
    this.status = AppAuthStatus.initial,
    this.message,
    this.userId,
  });

  final AppAuthStatus status;
  final String? message;
  final String? userId;

  AppAuthState copyWith({
    AppAuthStatus? status,
    String? message,
    String? userId,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      message: message,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [status, message, userId];
}

