import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/model/UserOrg.dart';

/// 用户item
/// Create by zyf
/// Date: 2019/8/5
class UserItem extends StatelessWidget {
  final UserItemModel userItemModel;

  final VoidCallback onPressed;

  UserItem(this.userItemModel, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RawMaterialButton(
          onPressed: onPressed,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(ZColors.imgColor),
                  backgroundImage: NetworkImage(userItemModel.userPic),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      userItemModel.userName,
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}

class UserItemModel {
  String userPic;
  String userName;

  UserItemModel.fromMap(User user) {
    userName = user.login;
    userPic = user.avatarUrl ?? "";
  }

  UserItemModel.fromOrgMap(UserOrg org) {
    userName = org.login;
    userPic = org.avatarUrl ?? "";
  }
}
