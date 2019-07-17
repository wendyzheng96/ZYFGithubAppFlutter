import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// 通用工具方法
/// Create by zyf
/// Date: 2019/7/16
class CommonUtils {
  static String getUserChartUrl(String username) {
    return 'https://ghchart.rshah.org/' +
        ZColors.primaryValueString.replaceAll("#", "") +
        "/" +
        username;
  }

  static void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIos: 1,
      backgroundColor: Color(0x99000000),
    );
  }
}
