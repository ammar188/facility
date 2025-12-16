import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.message,
  });

  final ProfileStatus status;
  final String? message;

  ProfileState copyWith({
    ProfileStatus? status,
    String? message,
  }) {
    return ProfileState(
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}

