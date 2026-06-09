import 'package:dio/dio.dart';

import 'base_interceptor.dart';

class HttpInterceptor extends BaseHttpInterceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Content-Type'] =  Headers.jsonContentType;
    // options.headers['Authorization'] = 'Bearer ${oauthToken.accessToken ?? ''}';
    super.onRequest(options, handler);
 
  }
}
