import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 导航栏
/// Create by zyf
/// Date: 2019/7/13

class NavigatorUtils {
  ///替换
  static pushReplaceNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///公共打开方式
  static navigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context,
        new CupertinoPageRoute(builder: (context) => pageContainer(widget)));
  }

  ///Page页面的容器，做一次通用自定义
  static Widget pageContainer(Widget widget) {
    return MediaQuery(
      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
          .copyWith(textScaleFactor: 1),
      child: widget,
    );
  }

  ///弹出dialog
  static Future<T> showAppDialog<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder builder,
  }) {
    return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(
              data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
              child: SafeArea(child: builder(context)));
        });
  }
}
