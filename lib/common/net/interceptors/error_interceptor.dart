import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:github_app_flutter/common/net/code.dart';
import 'package:github_app_flutter/common/net/result_data.dart';

/// 错误拦截
/// Create by zyf
/// Date: 2019/7/24
class ErrorInterceptors extends InterceptorsWrapper {
  final Dio _dio;

  ErrorInterceptors(this._dio);

  @override
  onRequest(RequestOptions options) async {
    ///没有网络
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return _dio.resolve(ResultData(
          Code.errorHandleFunction(Code.NETWORK_ERROR, "", false),
          false,
          Code.NETWORK_ERROR));
    }
    return options;
  }
}
