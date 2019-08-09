import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/local/local_storage.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/dialog_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/page/login_page.dart';
import 'package:github_app_flutter/page/user_profile_page.dart';

/// 主页drawer
/// Create by zyf
/// Date: 2019/7/19
class HomeDrawer extends StatelessWidget {
  final Color iconColor = Color(ZColors.textMenuValue);
  final Color tvColor = Color(ZColors.textSecondaryValue);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StoreBuilder<ZYFState>(
        builder: (context, store) {
          User user = store.state.userInfo;
          return Drawer(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(),
                    children: <Widget>[
                      _drawerHeader(user, context),
                      _renderItem(Icons.feedback, '问题反馈', () {
                        CommonUtils.showToast('问题反馈');
                      }),
                      _renderItem(Icons.history, '浏览历史', () {
                        NavigatorUtils.gotoCommonList(
                            context, "浏览历史", "repository", "history",
                            username: "", reposName: "");
                      }),
                      _renderItem(Icons.color_lens, '切换主题', () {
                        _showThemeDialog(context, store);
                      }),
                      _renderItem(Icons.local_offer, '关于', () {
                        _showAPPAboutDialog(context);
                      }),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                ),
                _drawerBottom(context),
              ],
            ),
          );
        },
      ),
    );
  }

  //drawer头部用户信息
  Widget _drawerHeader(User user, BuildContext context) =>
      UserAccountsDrawerHeader(
        accountName: Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        accountEmail: Text(user.email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            )),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Color(ZColors.imgColor),
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        onDetailsPressed: () {
          NavigatorUtils.navigatorRouter(context, UserProfilePage());
        },
      );

  //drawer底部按钮
  Widget _drawerBottom(BuildContext context) => Row(
        children: <Widget>[
          Expanded(
              child: GestureDetector(
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Icon(
                    Icons.power_settings_new,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                Text(
                  '退出',
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
            onTap: () {
              NavigatorUtils.pushReplaceNamed(context, LoginPage.sName);
            },
          )),
          Expanded(
              child: GestureDetector(
            child: Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Icon(
                    Icons.brightness_2,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                Text(
                  '夜间',
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
            onTap: () {
              CommonUtils.showToast('暂未实现夜间模式');
            },
          ))
        ],
      );

  Widget _renderItem(IconData iconData, String title, VoidCallback onPressed) =>
      ListTile(
        leading: Icon(
          iconData,
          color: iconColor,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: tvColor,
            fontSize: 15,
          ),
        ),
        contentPadding: EdgeInsets.only(left: 30),
        onTap: onPressed,
      );

  _showThemeDialog(context, store) {
    List<Color> list = CommonUtils.getThemeListColor();
    DialogUtils.showColorDialog(context, list, (index) {
      CommonUtils.pushTheme(store, index);
      LocalStorage.save(Config.THEME_COLOR, index);
    });
  }

  _showAPPAboutDialog(BuildContext context) {
    showAboutDialog(
        context: context,
        applicationName: 'GithubFlutter',
        applicationVersion: '1.0',
        applicationIcon: Image.asset(
          'static/images/ic_github.png',
          width: 44,
          height: 44,
        ),
        children: <Widget>[
          RichText(
            text: TextSpan(
              text: '源代码地址：',
              style: TextStyle(
                  color: Color(ZColors.textPrimaryValue), fontSize: 16.0),
              children: <TextSpan>[
                TextSpan(
                    text: ' 点击跳转链接',
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        CommonUtils.launchOutURL(
                            "https://github.com/wendyzheng96/ZYFGithubAppFlutter",
                            context);
                      }),
              ],
            ),
          )
        ]);
  }
}
