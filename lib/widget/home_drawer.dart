import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/page/login_page.dart';
import 'package:github_app_flutter/page/user_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// 主页drawer
/// Create by zyf
/// Date: 2019/7/19
class HomeDrawer extends StatelessWidget {
  final User user = User.factory(
      'https://hbimg.huabanimg.com/0d2a3fca3b1829736261fdf7db36d8001ecb0ea715f10c-3Dv8Bn_fw658',
      'wendyzheng96',
      'zhengyf@gmail');

  final Color color = Color(ZColors.textMenuValue);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(),
              children: <Widget>[
                _drawerHeader(user, context),
                ListTile(
                  leading: Icon(
                    Icons.feedback,
                    color: color,
                    size: 22,
                  ),
                  title: Text('问题反馈'),
                  onTap: () {
                    CommonUtils.showToast('问题反馈');
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.history,
                    color: color,
                    size: 22,
                  ),
                  title: Text('阅读历史'),
                  onTap: () {
                    CommonUtils.showToast('阅读历史');
                  },
                ),
                AboutListTile(
                  icon: Icon(
                    Icons.local_offer,
                    color: color,
                    size: 22,
                  ),
                  child: Text('关于'),
                  applicationName: 'GithubFlutter',
                  applicationVersion: '1.0',
                  applicationIcon: Image.asset(
                    'static/images/ic_github.png',
                    width: 44,
                    height: 44,
                  ),
                  aboutBoxChildren: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: '源代码地址：',
                        style: TextStyle(
                            color: Color(ZColors.textPrimaryValue),
                            fontSize: 16.0),
                        children: <TextSpan>[
                          TextSpan(
                              text: ' 点击跳转链接',
                              style: TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launch(
                                      "https://github.com/wendyzheng96/ZYFGithubAppFlutter");
                                }),
                        ],
                      ),
                    )
                  ],
                )
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
  }

  //drawer头部用户信息
  Widget _drawerHeader(User userInfo, BuildContext context) => UserAccountsDrawerHeader(
        accountName: Text(
          userInfo.name,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        accountEmail: Text(userInfo.email,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            )),
        currentAccountPicture: CircleAvatar(
          backgroundImage: NetworkImage(userInfo.avatar_url),
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
                    color: color,
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
                    color: color,
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
}
