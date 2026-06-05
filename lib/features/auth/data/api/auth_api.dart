import 'package:dio/dio.dart';
import 'package:flutter_provider/core/network/dio_provider.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user_model.dart';

part 'auth_api.g.dart';

@riverpod
AuthApi authApi(Ref ref) {
  return AuthApi(ref.watch(dioProvider));
}

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio) = _AuthApi;

  @POST('/login')
  Future<UserModel> login(@Body() Map<String, dynamic> body);
}
