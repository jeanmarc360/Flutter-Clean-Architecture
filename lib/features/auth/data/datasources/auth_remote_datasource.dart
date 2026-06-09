import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/auth_api.dart';
import '../models/auth_token_model.dart';

part 'auth_remote_datasource.g.dart';

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(ref.watch(authApiProvider));
}

class AuthRemoteDataSource {
  final AuthApi api;

  AuthRemoteDataSource(this.api);

  Future<AuthTokenModel> login(String email, String password) {
    return api.login({'email': email, 'password': password});
  }
}
