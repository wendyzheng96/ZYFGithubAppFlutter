import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:image_picker/image_picker.dart';

/// 用户信息中心
/// Create by zyf
/// Date: 2019/7/22
class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {

  File _headImage;

  ///获取图片
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _headImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StoreBuilder<ZYFState>(
        builder: (context, store) {
          User user = store.state.userInfo;
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
                  _renderHead(user),
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
        },
      ),
    );
  }

  Widget _renderHead(User user) => Container(
        width: double.infinity,
        margin: EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: _headImage == null
                  ? NetworkImage(user.avatar_url)
                  : FileImage(_headImage),
            ),
            CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(70, 0, 0, 0),
            ),
            IconButton(
                icon: Icon(
                  Icons.photo_camera,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  getImage();
                })
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
                style: TextStyle(
                    color: Color(ZColors.textSecondaryValue), fontSize: 14),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Text(content ?? "---",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: Color(ZColors.textPrimaryValue), fontSize: 15)),
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
