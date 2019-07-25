import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/page/home_page.dart';
import 'package:github_app_flutter/page/login_page.dart';
import 'package:github_app_flutter/page/welcome_page.dart';
import 'package:redux/redux.dart';

void main() {
  runZoned(() {
    runApp(MyApp());
  }, onError: (Object obj, StackTrace stack) {
    print(obj);
    print(stack);
  });
}

class MyApp extends StatelessWidget {

  /// 创建Store，引用 ZYFState 中的 appReducer 实现 Reducer 方法
  /// initialState 初始化 State
  final store = Store<ZYFState>(
    appReducer,

    ///初始化数据
    initialState: ZYFState(userInfo: User.empty()),
  );


  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: StoreBuilder<ZYFState>(builder: (context, store){
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
      })
    );
  }
}
