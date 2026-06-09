import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/local/base_local_datasource.dart';
import '../models/auth_token_model.dart';

part 'auth_local_datasource.g.dart';

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) => AuthLocalDataSource();

class AuthLocalDataSource extends BaseLocalDatasource<AuthTokenModel> {
  static const boxName = 'auth_tokens';

  @override
  String get keyBox => boxName;

  @override
  bool get isSecure => true;

  Future<void> saveToken(AuthTokenModel model) => save(model);
  Future<AuthTokenModel?> getToken() async {
    AuthTokenModel? token = await super.get();
    return token;
  }

  Future<void> clearToken() => save(null);
}
