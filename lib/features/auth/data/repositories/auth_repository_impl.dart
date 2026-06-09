import 'package:flutter_provider/core/error/result.dart';
import 'package:flutter_provider/core/network/safe_api_call.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl(this.remote, this.local);

  @override
  Future<Result<AuthToken>> login(String email, String password) =>
      safeApiCall(() async {
        final model = await remote.login(email, password);
        await local.saveToken(model);
        return model.toEntity();
      });
}
