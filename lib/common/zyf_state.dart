//全局 redux store 的对象，保存state数据
import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/redux/user_redux.dart';
import 'package:github_app_flutter/model/User.dart';

class ZYFState {
  //用户信息
  User userInfo;

  //主题
  ThemeData themeData;

  //构造方法
  ZYFState({this.userInfo, this.themeData});
}

///创建 Reducer
///源码中 Reducer 是一个方法 typedef State Reducer<State>(State state, dynamic action);
///我们自定义了 appReducer 用于创建 store
ZYFState appReducer(ZYFState state, action) {
  return ZYFState(
    ///通过 UserReducer 将 GSYState 内的 userInfo 和 action 关联在一起
    userInfo: userReducer(state.userInfo, action),
  );
}

