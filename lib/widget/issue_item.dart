import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/time_utils.dart';
import 'package:github_app_flutter/model/Issue.dart';

/// issue相关item
/// Create by zyf
/// Date: 2019/8/2
class IssueItem extends StatelessWidget {
  final IssueItemViewModel issueItemModel;

  final GestureTapCallback onPressed;

  final GestureTapCallback onLongPress;

  IssueItem(
    this.issueItemModel, {
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(12),
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
                              style: Theme.of(context).textTheme.body1.copyWith(
                                fontSize: 14,
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
                          ),
                        ],
                      ),
                      Container(height: 8),
                      MarkdownBody(data: issueItemModel.issueComment,
                      onTapLink: (String source){
                        CommonUtils.launchUrl(context, source);
                      },),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 54),
          child: Divider(
            height: 1.0,
            color: Theme.of(context).dividerColor,
          ),
        )
      ],
    );
  }
}

class IssueItemViewModel {
  String actionTime = "---";
  String actionUser = "---";
  String actionUserPic = "";
  String issueComment = "---";
  String commentCount = "---";
  String state = "---";
  String issueTag = "---";
  String number = "---";
  String id = "";

  IssueItemViewModel();

  IssueItemViewModel.fromMap(Issue issueMap, {needTitle = true}) {
    String fullName = CommonUtils.getFullName(issueMap.repoUrl);
    actionTime = getTimeAgoStr(issueMap.createdAt);
    actionUser = issueMap.user.login;
    actionUserPic = issueMap.user.avatarUrl ?? "";
    if (needTitle) {
      issueComment = fullName + "- " + issueMap.title;
      commentCount = issueMap.commentNum.toString();
      state = issueMap.state;
      issueTag = "#" + issueMap.number.toString();
      number = issueMap.number.toString();
    } else {
      issueComment = issueMap.body ?? "";
      id = issueMap.id.toString();
    }
  }
}
