import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth_token.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    AuthToken? authToken,
    String? error,
  }) = _AuthState;
}
