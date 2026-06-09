import 'package:dio/dio.dart';
import 'package:flutter_provider/core/network/dio_provider.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_token_model.dart';

part 'auth_api.g.dart';

@riverpod
AuthApi authApi(Ref ref) {
  // TODO : use env variable for base url
  return AuthApi(ref.watch(dioProvider), baseUrl: 'https://your-api-base-url.com');
}
// @RestApi(baseUrl: 'https://...') — value hardcoded at compile time. The generator writes it directly to the .g.dart file. It cannot change at runtime.
@RestApi()
abstract class AuthApi {
  // factory AuthApi(Dio dio, {required String baseUrl}) = _AuthApi — value passed at runtime.
  // The generator creates a parameter in the constructor of _AuthApi, and the caller decides the value when instantiating the client.
  factory AuthApi(Dio dio, {required String baseUrl}) = _AuthApi;

  @POST('/login')
  Future<AuthTokenModel> login(@Body() Map<String, dynamic> body);
}
