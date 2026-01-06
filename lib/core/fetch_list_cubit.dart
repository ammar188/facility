import 'package:flutter_bloc/flutter_bloc.dart';

enum ListStateEnum {
  initial,
  loading,
  success,
  failure,
}

// Generic cubit for fetching lists of items
class FetchListCubit<T> extends Cubit<(List<T>, ListStateEnum)> {
  FetchListCubit() : super(([], ListStateEnum.initial));
  
  Future<void> fetchData({String? key}) async {
    // TODO: Implement with actual data fetching logic
    emit(([], ListStateEnum.loading));
    // Simulate loading
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(([], ListStateEnum.success));
  }
}

