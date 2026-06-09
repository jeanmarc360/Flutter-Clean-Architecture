// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthTokenModelAdapter extends TypeAdapter<AuthTokenModel> {
  @override
  final typeId = 0;

  @override
  AuthTokenModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthTokenModel(
      idToken: fields[0] as String,
      accessToken: fields[1] as String,
      refreshToken: fields[2] as String,
      refreshTokenExpireTime: fields[3] as String,
      accessTokenExpireTime: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AuthTokenModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.idToken)
      ..writeByte(1)
      ..write(obj.accessToken)
      ..writeByte(2)
      ..write(obj.refreshToken)
      ..writeByte(3)
      ..write(obj.refreshTokenExpireTime)
      ..writeByte(4)
      ..write(obj.accessTokenExpireTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthTokenModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthTokenModel _$AuthTokenModelFromJson(Map<String, dynamic> json) =>
    AuthTokenModel(
      idToken: json['idToken'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      refreshTokenExpireTime: json['refreshTokenExpireTime'] as String,
      accessTokenExpireTime: json['accessTokenExpireTime'] as String,
    );

Map<String, dynamic> _$AuthTokenModelToJson(AuthTokenModel instance) =>
    <String, dynamic>{
      'idToken': instance.idToken,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'refreshTokenExpireTime': instance.refreshTokenExpireTime,
      'accessTokenExpireTime': instance.accessTokenExpireTime,
    };
