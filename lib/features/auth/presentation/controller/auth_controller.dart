import 'package:flutter_provider/features/auth/domain/usecases/login_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../state/auth_state.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await ref.read(loginUseCaseProvider).login(email, password);

    if (result.isSuccess) {
      state = state.copyWith(isLoading: false, authToken: result.data);
    } else {
      state = state.copyWith(isLoading: false, error: result.error?.message);
    }
  }

  void logout() {
    state = const AuthState();
  }
}
