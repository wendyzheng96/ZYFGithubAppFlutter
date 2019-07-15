import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/page/home_page.dart';
import 'package:github_app_flutter/page/login_page.dart';
import 'package:github_app_flutter/page/welcome_page.dart';

void main() {
  runZoned(() {
    runApp(MyApp());
  }, onError: (Object obj, StackTrace stack) {
    print(obj);
    print(stack);
  });

//  // 透明状态栏
//  if (Platform.isAndroid) {
//    SystemUiOverlayStyle systemUiOverlayStyle =
//    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
//    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
//  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GithubFlutter',
      theme: ThemeData(
        primaryColor: Color(ZColors.primaryValue),
        primarySwatch: ZColors.primarySwatch,
      ),
      routes: {
        WelcomePage.sName: (context) => WelcomePage(),
        HomePage.sName: (context) => NavigatorUtils.pageContainer(HomePage()),
        LoginPage.sName: (context) => LoginPage(),
      },
    );
  }
}
