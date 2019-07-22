import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/model/User.dart';

/// 用户信息中心
/// Create by zyf
/// Date: 2019/7/22
class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final User user = User.factory(
      'https://hbimg.huabanimg.com/0d2a3fca3b1829736261fdf7db36d8001ecb0ea715f10c-3Dv8Bn_fw658',
      'wendyzheng96',
      'zhengyf@gmail');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('个人信息'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _renderHead(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 10, 0, 16),
              child: Text(
                'INFO',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Divider(
              height: 1,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  _renderItem('用户名', user.name, () {}),
                  Divider(
                    height: 1,
                  ),
                  _renderItem('邮箱', user.email, () {}),
                  Divider(
                    height: 1,
                  ),
                  _renderItem('链接', user.blog, () {}),
                  Divider(
                    height: 1,
                  ),
                  _renderItem('公司', user.company, () {}),
                  Divider(
                    height: 1,
                  ),
                  _renderItem('位置', user.location, () {}),
                  Divider(
                    height: 1,
                  ),
                  _renderItem('简介', user.bio, () {}),
                  Divider(
                    height: 1,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _renderHead() => Container(
        width: double.infinity,
        margin: EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(user.avatar_url),
            ),
            CircleAvatar(
              radius: 45,
              backgroundColor: Color.fromARGB(80, 0, 0, 0),
            ),
            Icon(
              Icons.photo_camera,
              color: Colors.white,
              size: 30,
            )
          ],
        ),
      );

  Widget _renderItem(String title, String content, VoidCallback onPressed) =>
      GestureDetector(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(color: Color(ZColors.textSecondaryValue)),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(content ?? "---",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Color(ZColors.textPrimaryValue), fontSize: 16)),
              )),
              Icon(
                ZIcons.REPOS_ITEM_NEXT,
                size: 14,
                color: Color(ZColors.textHintValue),
              )
            ],
          ),
        ),
        onTap: onPressed,
      );
}
