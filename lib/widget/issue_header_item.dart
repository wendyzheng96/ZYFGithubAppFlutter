import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/time_utils.dart';
import 'package:github_app_flutter/model/Issue.dart';
import 'package:github_app_flutter/widget/icon_text.dart';

/// issue详情头部控件
/// Create by zyf
/// Date: 2019/8/2
class IssueHeaderItem extends StatelessWidget {
  final IssueHeaderViewModel issueItemModel;

  final VoidCallback onPressed;

  IssueHeaderItem(this.issueItemModel, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    Color labelColor;
    if(issueItemModel.state == 'open') {
      labelColor = Colors.green;
    } else if(issueItemModel.state == 'closed'){
      labelColor = Colors.redAccent;
    } else {
      labelColor = Colors.grey;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.all(12),
          onPressed: onPressed,
          child: Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(ZColors.imgColor),
                  backgroundImage: NetworkImage(issueItemModel.actionUserPic),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                issueItemModel.actionUser,
                                style: TextStyle(
                                  color: Color(ZColors.primaryDarkValue),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              issueItemModel.actionTime,
                              style: TextStyle(
                                color: Color(ZColors.textHintValue),
                                fontSize: 12,
                              ),
                            )
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 4, bottom: 6),
                          child: Row(
                            children: <Widget>[
                              getStateLabel(labelColor),
                              Text(
                                issueItemModel.issueTag,
                                style: ZStyles.minTextSecondary,
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: IconText(
                                  issueItemModel.commentCount,
                                  Icons.message,
                                  ZStyles.minTextHint,
                                  iconColor: Color(ZColors.textHintValue),
                                  iconSize: 14,
                                  padding: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                        Text(
                          issueItemModel.issueComment,
                          style: ZStyles.normalTextPrimary,
                        ),
                        Container(height: 8),
                        MarkdownBody(
                          data: issueItemModel.issueDesHtml,
                          onTapLink: (source){
                            CommonUtils.launchUrl(context, source);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(),
      ],
    );
  }

  ///状态：open or close
  Widget getStateLabel(Color color) => Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 12,
              color: Colors.white,
            ),
            Container(
              width: 1,
            ),
            Text(
              issueItemModel.state,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      );
}

class IssueHeaderViewModel {
  String actionTime = "---";
  String actionUser = "---";
  String actionUserPic = "";

  String closedBy = "";
  bool locked = false;
  String issueComment = "---";
  String issueDesHtml = "---";
  String commentCount = "---";
  String state = "---";
  String issueDes = "---";
  String issueTag = "---";

  IssueHeaderViewModel();

  IssueHeaderViewModel.fromMap(Issue issueMap) {
    actionTime = getTimeAgoStr(issueMap.createdAt);
    actionUser = issueMap.user.login;
    actionUserPic = issueMap.user.avatarUrl ?? "";
    closedBy = issueMap.closeBy != null ? issueMap.closeBy.login : "";
    locked = issueMap.locked;
    issueComment = issueMap.title;
    issueDesHtml = issueMap.bodyHtml != null
        ? issueMap.bodyHtml
        : (issueMap.body != null) ? issueMap.body : "";
    commentCount = issueMap.commentNum.toString() + "";
    state = issueMap.state;
    issueDes = issueMap.body != null ? ": \n" + issueMap.body : '';
    issueTag = "#" + issueMap.number.toString();
  }
}
