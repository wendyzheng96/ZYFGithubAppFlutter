import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/user_dao.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/base_person_state.dart';
import 'package:github_app_flutter/widget/common_option_widget.dart';

/// 用户详情
/// Create by zyf
/// Date: 2019/8/6
class PersonPage extends StatefulWidget {
  final String username;

  PersonPage(this.username);

  @override
  _PersonPageState createState() => _PersonPageState(username);
}

class _PersonPageState extends BasePersonState<PersonPage> {
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  final OptionControl optionControl = OptionControl();

  final String username;

  User userInfo = User.empty();

  _PersonPageState(this.username);

  List<String> list = ['1','2','3'];

  @override
  String getUsername() {
    return username;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(username),
        actions: <Widget>[
          CommonOptionWidget(optionControl),
        ],
      ),
      body: sliverBuilder(context, userInfo),
    );
  }

  @override
  Future refreshData() async {
    var res = await UserDao.getUserInfo(username, needDb: true);
    if (res != null && res.result) {
      setState(() {
        userInfo = res.data;
        optionControl.url = res.data.htmlUrl;
      });
    }
  }
}
