import 'package:dio/dio.dart';
import 'package:github_app_flutter/common/net/code.dart';
import 'package:github_app_flutter/common/net/result_data.dart';

/// response拦截器
/// Create by zyf
/// Date: 2019/7/24
class ResponseInterceptors extends InterceptorsWrapper {
  @override
  onResponse(Response response) {
    RequestOptions options = response.request;
    try {
      if (options.contentType != null &&
          options.contentType.primaryType == "text") {
        return ResultData(response.data, true, Code.SUCCESS);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ResultData(response.data, true, Code.SUCCESS,
            headers: response.headers);
      }
    } catch (e) {
      print(e.toString() + options.path);
      return ResultData(response.data, false, response.statusCode,
          headers: response.headers);
    }
  }
}
