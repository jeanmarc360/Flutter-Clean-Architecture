import 'package:flutter_provider/core/local/local_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/user_mapper.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(localDataSourceProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final LocalDataSource local;

  AuthRepositoryImpl(this.remote, this.local);

  @override
  Future<User> login(String email, String password) async {
    final model = await remote.login(email, password);
    await local.saveToken(model.token);
    return model.toEntity();
  }
}
