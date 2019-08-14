import 'package:github_app_flutter/common/event.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';

/// 状态编码
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

    CommonUtils.showToast(handleErrorFunction(code, message));
    eventBus.fire(HttpErrorEvent(code, message));
    return message;
  }

  ///网络错误提醒
  static handleErrorFunction(int code, message) {
    switch (code) {
      case NETWORK_ERROR:
        return '网络错误';
      case NETWORK_TIMEOUT:
        return '网络请求超时';
      case NETWORK_JSON_EXCEPTION:
        return '数据解析错误';
      case 401:
        return '[401错误可能: 未授权 \\ 授权登录失败 \\ 登录过期]';
      case 403:
        return '403权限错误';
      case 404:
        return '404错误';
      default:
        return '未知错误 $message';
    }
  }
}