import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BaseHttpInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('');
    debugPrint('╔═══════════════ REQUEST ════════════════════════');
    debugPrint('║ URL     : ${options.method} ${options.uri}');
    debugPrint('║ HEADERS : ${options.headers}');
    debugPrint('║ BODY    : ${options.data ?? 'none'}');
    debugPrint('╚════════════════════════════════════════════════');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('');
    debugPrint('╔═══════════════ RESPONSE ═══════════════════════');
    debugPrint('║ URL     : ${response.requestOptions.uri}');
    debugPrint('║ STATUS  : ${response.statusCode}');
    debugPrint('║ DATA    : ${response.data}');
    debugPrint('╚════════════════════════════════════════════════');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('');
    debugPrint('╔═══════════════ ERROR ══════════════════════════');
    debugPrint('║ URL     : ${err.requestOptions.uri}');
    debugPrint('║ STATUS  : ${err.response?.statusCode}');
    debugPrint('║ TYPE    : ${err.type}');
    debugPrint('║ MESSAGE : ${err.message}');
    debugPrint('║ BODY    : ${err.response?.data ?? 'none'}');
    debugPrint('╚════════════════════════════════════════════════');
    super.onError(err, handler);
  }
}
