import 'package:flutter_provider/core/error/result.dart';
import '../entities/auth_token.dart';

abstract class AuthRepository {
  Future<Result<AuthToken>> login(String email, String password);
}
