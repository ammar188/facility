import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:facility/app/profile/profile_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client,
        super(const ProfileState());

  final SupabaseClient _supabase;

  Future<void> saveProfile({
    required String userId,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading, message: null));
    try {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      emit(state.copyWith(status: ProfileStatus.success));
    } catch (e, st) {
      log('Profile save error: $e', name: 'ProfileCubit', error: e, stackTrace: st);
      emit(state.copyWith(
        status: ProfileStatus.error,
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}

