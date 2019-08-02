import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';

/// 弹框工具类
/// Create by zyf
/// Date: 2019/8/2
///显示加载中进度框
Future<Null> showLoadingDialog(BuildContext context) {
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
