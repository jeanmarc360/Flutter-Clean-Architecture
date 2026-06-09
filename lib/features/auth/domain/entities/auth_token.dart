class AuthToken {
  final String idToken;
  final String accessToken;
  final String refreshToken;
  final String refreshTokenExpireTime;
  final String accessTokenExpireTime;

  const AuthToken({
    required this.idToken,
    required this.accessToken,
    required this.refreshToken,
    required this.refreshTokenExpireTime,
    required this.accessTokenExpireTime,
  });
}
