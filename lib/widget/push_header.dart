import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/time_utils.dart';
import 'package:github_app_flutter/model/PushCommit.dart';
import 'package:github_app_flutter/widget/icon_text.dart';

/// 提交详情头部
/// Create by zyf
/// Date: 2019/8/5
class PushHeader extends StatelessWidget {
  final PushHeaderModel headerModel;

  PushHeader(this.headerModel);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          ///背景头像
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://hbimg.huabanimg.com/96b3ad9260aa2b218393382cb22e0ecbcd1477ea29c20-o3nQgY_fw658'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xA0000000),
            ),
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: NetworkImage(headerModel.actionUserPic),
                ),
                Padding(padding: EdgeInsets.only(left: 10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              headerModel.actionUser,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            headerModel.pushTime,
                            style: ZStyles.smallerTextWhite70,
                          )
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 6, bottom: 10),
                        child: Row(
                          children: <Widget>[
                            _getIconItem(Icons.edit, headerModel.editCount),
                            Container(
                              width: 12,
                            ),
                            _getIconItem(Icons.add_box, headerModel.addCount),
                            Container(
                              width: 12,
                            ),
                            _getIconItem(Icons.indeterminate_check_box,
                                headerModel.deleteCount),
                          ],
                        ),
                      ),
                      Text(
                        headerModel.pushDes,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xd5FFFFFF),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 头部变化数量图标
  _getIconItem(IconData icon, String text) {
    return IconText(
      text,
      icon,
      ZStyles.smallSubLightText,
      iconColor: Color(ZColors.subLightTextColor),
      iconSize: 14,
      padding: 1,
    );
  }
}

class PushHeaderModel {
  String actionUser = "---";
  String actionUserPic = "---";
  String pushDes = "---";
  String pushTime = "---";
  String editCount = "---";
  String addCount = "---";
  String deleteCount = "---";
  String htmlUrl = ZConstant.app_default_share_url;

  PushHeaderModel();

  PushHeaderModel.forMap(PushCommit pushMap) {
    String name = "---";
    String pic = "---";
    if (pushMap.committer != null) {
      name = pushMap.committer.login;
    } else if (pushMap.commit != null && pushMap.commit.author != null) {
      name = pushMap.commit.author.name;
    }
    if (pushMap.committer != null && pushMap.committer.avatarUrl != null) {
      pic = pushMap.committer.avatarUrl;
    }
    actionUser = name;
    actionUserPic = pic;
    pushDes = "Push at " + pushMap.commit.message;
    pushTime = getTimeAgoStr(pushMap.commit.committer.date);
    editCount = pushMap.files.length.toString() + "";
    addCount = pushMap.stats.additions.toString() + "";
    deleteCount = pushMap.stats.deletions.toString() + "";
    htmlUrl = pushMap.htmlUrl;
  }
}
