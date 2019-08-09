import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/base_person_state.dart';
import 'package:redux/redux.dart';

/// 我的页面
/// Create by zyf
/// Date: 2019/7/15
class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends BasePersonState<MinePage>{

  @override
  String getUsername() {
    if (_getStore()?.state?.userInfo == null) {
      return null;
    }
    return _getStore()?.state?.userInfo?.login;
  }

  Store<ZYFState> _getStore() {
    return StoreProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      child: StoreBuilder<ZYFState>(
        builder: (context, store) {
          User userInfo = store.state.userInfo;
          return sliverBuilder(context, userInfo);
        },
      ),
    );
  }

}