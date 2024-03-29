import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/dao/user_dao.dart';
import 'package:github_app_flutter/common/redux/user_redux.dart';
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

class _MinePageState extends BasePersonState<MinePage> {
  @override
  String getUsername() {
    if (_getStore()?.state?.userInfo == null) {
      return null;
    }
    return _getStore()?.state?.userInfo?.login;
  }

  @override
  String getUserType() {
    if (_getStore()?.state?.userInfo == null) {
      return null;
    }
    return _getStore()?.state?.userInfo?.type;
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
          return Scaffold(
            body: sliverBuilder(context, userInfo),
          );
        },
      ),
    );
  }

  @override
  Future<Null> onRefresh() async {
    var res = await UserDao.getUserInfo(null);
    if (res != null && res.result) {
      _getStore().dispatch(UpdateUserAction(res.data));
    }
    page = 1;
    await getData();
  }
}
