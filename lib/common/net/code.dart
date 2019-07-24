

import 'package:github_app_flutter/common/event.dart';

/// 编码
/// Create by zyf
/// Date: 2019/7/23
class Code{
  ///网络错误
  static const NETWORK_ERROR = -1;

  ///网络超时
  static const NETWORK_TIMEOUT = -2;

  ///网络返回数据错误
  static const NETWORK_JSON_EXCEPTION = -3;

  ///成功
  static const SUCCESS = 200;

  static errorHandleFunction(code, message, noTip){
    if(noTip){
      return message;
    }
    eventBus.fire(HttpErrorEvent(code, message));
    return message;
  }
}