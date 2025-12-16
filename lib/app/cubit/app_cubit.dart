import 'package:bloc/bloc.dart';
import 'package:facility/app/cubit/app_state.dart';

/// App-wide cubit scaffold you can extend for future features.
class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void setUser(String? userId) => emit(state.copyWith(userId: userId));

  void setReady(bool ready) => emit(state.copyWith(isReady: ready, errorMessage: null));

  void setError(String? message) => emit(state.copyWith(errorMessage: message));

  void reset() => emit(const AppState());
}

