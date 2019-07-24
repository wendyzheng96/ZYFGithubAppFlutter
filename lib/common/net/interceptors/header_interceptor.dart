import 'package:dio/dio.dart';

/// header拦截器
/// Create by zyf
/// Date: 2019/7/24
class HeaderInterceptors extends InterceptorsWrapper {

  @override
  onRequest(RequestOptions options) {
    ///超时
    options.connectTimeout = 15000;
    return options;
  }
}