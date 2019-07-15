//全局 redux store 的对象，保存state数据
import 'package:flutter/material.dart';
import 'package:github_app_flutter/model/User.dart';

class ZYFState {
  //用户信息
  User userInfo;

  //主题
  ThemeData themeData;

  //语言
  Locale locale;

  //当前手机平台默认语言
  Locale platformLocale;

  //构造方法
  ZYFState({this.userInfo, this.themeData, this.locale});
}

