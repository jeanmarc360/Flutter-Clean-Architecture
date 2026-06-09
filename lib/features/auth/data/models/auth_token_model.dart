import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/auth_token.dart';

part 'auth_token_model.g.dart';

@JsonSerializable()
@HiveType(typeId: 0)
class AuthTokenModel {
  @HiveField(0)
  final String idToken;
  @HiveField(1)
  final String accessToken;
  @HiveField(2)
  final String refreshToken;
  @HiveField(3)
  final String refreshTokenExpireTime;
  @HiveField(4)
  final String accessTokenExpireTime;

  const AuthTokenModel({
    required this.idToken,
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpireTime,
    required this.accessTokenExpireTime,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokenModelToJson(this);

  AuthToken toEntity() => AuthToken(
        idToken: idToken,
        accessToken: accessToken,
        refreshToken: refreshToken,
        refreshTokenExpireTime: refreshTokenExpireTime,
        accessTokenExpireTime: accessTokenExpireTime,
      );
}
