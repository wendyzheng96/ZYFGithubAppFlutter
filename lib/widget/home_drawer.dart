import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/issue_dao.dart';
import 'package:github_app_flutter/common/local/local_storage.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/dialog_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/page/login_page.dart';
import 'package:github_app_flutter/page/user_profile_page.dart';
import 'package:github_app_flutter/widget/icon_text.dart';

/// 主页drawer
/// Create by zyf
/// Date: 2019/7/19
class HomeDrawer extends StatefulWidget {
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer>
    with AutomaticKeepAliveClientMixin {
  final Color iconColor = Color(ZColors.textMenuValue);
  final Color tvColor = Color(ZColors.textSecondaryValue);

  ///当前是否处于夜间模式，true：是，false：否
  bool isNight = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initParams();
  }

  void initParams() async {
    isNight = await LocalStorage.get(Config.IS_NIGHT_THEME) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      child: StoreBuilder<ZYFState>(
        builder: (context, store) {
          User user = store.state.userInfo;
          return Drawer(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(),
                      children: <Widget>[
                        _drawerHeader(user, context),
                        _renderItem(Icons.feedback, '问题反馈', () {
                          _feedback(user);
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
                  _drawerBottom(context, store),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //drawer头部用户信息
  Widget _drawerHeader(User user, BuildContext context) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('static/images/bg_drawer.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
          margin: EdgeInsets.zero,
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
        ),
      );

  //drawer底部按钮
  Widget _drawerBottom(BuildContext context, store) => Row(
        children: <Widget>[
          Expanded(
            child: RawMaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.fromLTRB(16, 12, 12, 12),
              onPressed: () {
                DialogUtils.showNormalDialog(context, '确认退出登录？', (bool) {
                  if (bool) {
                    NavigatorUtils.pushReplaceNamed(context, LoginPage.sName);
                  }
                });
              },
              child: IconText(
                '退出',
                Icons.power_settings_new,
                TextStyle(fontSize: 14),
                iconColor: iconColor,
                iconSize: 22,
                padding: 8,
              ),
            ),
          ),
          Expanded(
            child: RawMaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.fromLTRB(16, 12, 12, 12),
              onPressed: () {
                _switchNightOrDay(store);
              },
              child: IconText(
                isNight ? '日间' : '夜间',
                isNight ? Icons.wb_sunny : Icons.brightness_2,
                Theme.of(context).textTheme.body1,
                iconColor: iconColor,
                iconSize: 22,
                padding: 8,
              ),
            ),
          ),
        ],
      );

  _renderItem(IconData iconData, String title, VoidCallback onPressed) {
    return ListTile(
      leading: Icon(
        iconData,
        color: iconColor,
        size: 22,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.body2,
      ),
      contentPadding: EdgeInsets.only(left: 30),
      onTap: onPressed,
    );
  }

  ///问题反馈
  _feedback(User user) {
    String content = '';
    DialogUtils.showEditDialog(context, '问题反馈', null, (contentValue) {
      content = contentValue;
    }, onPressed: () {
      if (content == null || content.isEmpty) {
        CommonUtils.showToast('请输入内容');
        return;
      }
      DialogUtils.showLoadingDialog(context);
      IssueDao.createIssue(user.login, 'ZYFGithubAppFlutter',
          {"title": '问题反馈', "body": content}).then((res) {
        if (res.result) {
          CommonUtils.showToast('反馈成功');
        }
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }, needTitle: false, contentController: TextEditingController());
  }

  ///显示切换主题弹框
  _showThemeDialog(context, store) {
    List<Color> list = CommonUtils.getThemeListColor();
    DialogUtils.showColorDialog(context, list, (index) {
      CommonUtils.pushTheme(store, index);
      LocalStorage.save(Config.THEME_COLOR, index);
      if (isNight) {
        setState(() {
          isNight = false;
        });
        LocalStorage.save(Config.IS_NIGHT_THEME, false);
      }
    });
  }

  ///显示关于APP弹框
  _showAPPAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'GithubFlutter',
      applicationVersion: '1.0',
      applicationIcon:
          Image.asset('static/images/ic_github.png', width: 44, height: 44),
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: '源代码地址：',
            style: TextStyle(
              color: Color(ZColors.textPrimaryValue),
              fontSize: 16.0,
            ),
            children: <TextSpan>[
              TextSpan(
                text: ' 点击跳转链接',
                style: TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    CommonUtils.launchOutURL(
                        "https://github.com/wendyzheng96/ZYFGithubAppFlutter",
                        context);
                  },
              ),
            ],
          ),
        )
      ],
    );
  }

  ///切换夜间和日间模式
  _switchNightOrDay(store) async {
    isNight = await LocalStorage.get(Config.IS_NIGHT_THEME) ?? false;
    setState(() {
      isNight = !isNight;
    });
    CommonUtils.switchNightOrDayTheme(store, isNight);
    await LocalStorage.save(Config.IS_NIGHT_THEME, isNight);
  }
}
