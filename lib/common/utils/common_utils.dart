import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';

/// 通用工具方法
/// Create by zyf
/// Date: 2019/7/16
class CommonUtils {
  static String getUserChartUrl(String username) {
    return Address.graphicHost +
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

  static Future<Null> showLoadingDialog(BuildContext context) {
    return NavigatorUtils.showAppDialog(
        context: context,
        builder: (BuildContext context) {
          return Material(
            color: Colors.transparent,
            child: WillPopScope(
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: SpinKitCircle(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          '加载中...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              onWillPop: () => Future.value(false),
            ),
          );
        });
  }
}
