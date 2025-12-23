import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserState {
  final Session? session;

  const UserState({this.session});

  UserState copyWith({Session? session}) {
    return UserState(session: session ?? this.session);
  }
}

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState()) {
    _loadSession();
  }

  void _loadSession() {
    final session = Supabase.instance.client.auth.currentSession;
    emit(state.copyWith(session: session));
  }
}

