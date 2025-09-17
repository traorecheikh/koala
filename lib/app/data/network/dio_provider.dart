import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioProvider {
  static final Dio _dio = Dio();

  static Dio get instance {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(responseBody: true));
    }
    return _dio;
  }
}
