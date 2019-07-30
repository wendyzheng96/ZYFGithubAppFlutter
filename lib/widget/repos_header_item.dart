import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/common/utils/time_utils.dart';
import 'package:github_app_flutter/model/Repository.dart';
import 'package:github_app_flutter/widget/icon_text.dart';

/// 仓库详情信息头控件
/// Create by zyf
/// Date: 2019/7/29
class ReposHeaderItem extends StatefulWidget {
  final ReposHeaderViewModel reposHeaderViewModel;

  final ValueChanged<Size> layoutListener;

  ReposHeaderItem(this.reposHeaderViewModel, {this.layoutListener}) : super();

  @override
  _ReposHeaderItemState createState() => _ReposHeaderItemState();
}

class _ReposHeaderItemState extends State<ReposHeaderItem> {
  final GlobalKey layoutKey = new GlobalKey();
  final GlobalKey layoutTopicContainerKey = new GlobalKey();
  final GlobalKey layoutLastTopicKey = new GlobalKey();

  double widgetHeight = 0;

  ///底部仓库状态信息，比如star数量等
  _getBottomItem(IconData icon, String text, onPressed) {
    return Expanded(
        child: Center(
      child: RawMaterialButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(vertical: 10),
        constraints: const BoxConstraints(minHeight: 0.0, minWidth: 0.0),
        child: IconText(
          text,
          icon,
          ZStyles.smallSubLightText,
          iconColor: Color(ZColors.subLightTextColor),
          iconSize: 15.0,
          padding: 3.0,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        onPressed: onPressed,
      ),
    ));
  }

  _renderTopicItem(BuildContext context, String item, int index) {
    return RawMaterialButton(
      key: index == widget.reposHeaderViewModel.topics.length - 1
          ? layoutLastTopicKey
          : null,
      constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.all(0.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white30,
        ),
        child: Text(
          item,
          style: ZStyles.smallSubLightText,
        ),
      ),
      onPressed: () {
        NavigatorUtils.gotoCommonList(context, item, "repository", "topics",
            userName: item, reposName: "");
      },
    );
  }

  ///话题组控件
  _renderTopicGroup(BuildContext context) {
    if (widget.reposHeaderViewModel.topics == null ||
        widget.reposHeaderViewModel.topics.length == 0) {
      return Container();
    }
    List<Widget> list = new List();
    for (int i = 0; i < widget.reposHeaderViewModel.topics.length; i++) {
      var item = widget.reposHeaderViewModel.topics[i];
      list.add(_renderTopicItem(context, item, i));
    }
    return Container(
      key: layoutTopicContainerKey,
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(top: 5.0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 5.0,
        children: list,
      ),
    );
  }

  ///仓库创建和提交状态信息
  _getInfoText(BuildContext context) {
    String createStr = widget.reposHeaderViewModel.repositoryIsFork
        ? 'fork at ${widget.reposHeaderViewModel.repositoryParentName}\n'
        : 'create at ${widget.reposHeaderViewModel.created_at}\n';

    String updateStr = 'last commit at ${widget.reposHeaderViewModel.push_at}';
    return createStr +
        ((widget.reposHeaderViewModel.push_at != null) ? updateStr : '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              spreadRadius: 4,
              color: Color.fromARGB(20, 0, 0, 0),
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              _getBottomItem(
                  Icons.star, widget.reposHeaderViewModel.repositoryStar, () {
                NavigatorUtils.gotoCommonList(
                    context,
                    widget.reposHeaderViewModel.repositoryName,
                    "user",
                    "repo_star",
                    userName: widget.reposHeaderViewModel.ownerName,
                    reposName: widget.reposHeaderViewModel.repositoryName);
              }),
              _getBottomItem(
                  Icons.share, widget.reposHeaderViewModel.repositoryFork, () {
                NavigatorUtils.gotoCommonList(
                    context,
                    widget.reposHeaderViewModel.repositoryName,
                    "repository",
                    "repo_fork",
                    userName: widget.reposHeaderViewModel.ownerName,
                    reposName: widget.reposHeaderViewModel.repositoryName);
              }),
              _getBottomItem(Icons.remove_red_eye,
                  widget.reposHeaderViewModel.repositoryWatch, () {
                NavigatorUtils.gotoCommonList(
                    context,
                    widget.reposHeaderViewModel.repositoryName,
                    "user",
                    "repo_watcher",
                    userName: widget.reposHeaderViewModel.ownerName,
                    reposName: widget.reposHeaderViewModel.repositoryName);
              }),
              _getBottomItem(Icons.error_outline,
                  widget.reposHeaderViewModel.repositoryIssue, () {}),
            ],
          ),
          _renderTopicGroup(context),
        ],
      ),
    );
  }
}

class ReposHeaderViewModel {
  String ownerName = '---';
  String ownerPic;
  String repositoryName = "---";
  String repositorySize = "---";
  String repositoryStar = "---";
  String repositoryFork = "---";
  String repositoryWatch = "---";
  String repositoryIssue = "---";
  String repositoryIssueClose = "";
  String repositoryIssueAll = "";
  String repositoryType = "---";
  String repositoryDes = "---";
  String repositoryLastActivity = "";
  String repositoryParentName = "";
  String repositoryParentUser = "";
  String created_at = "";
  String push_at = "";
  String license = "";
  List<String> topics;
  int allIssueCount = 0;
  int openIssuesCount = 0;
  bool repositoryStared = false;
  bool repositoryForked = false;
  bool repositoryWatched = false;
  bool repositoryIsFork = false;

  ReposHeaderViewModel();

  ReposHeaderViewModel.fromHttpMap(ownerName, reposName, Repository map) {
    this.ownerName = ownerName;
    if (map == null || map.owner == null) {
      return;
    }
    this.ownerPic = map.owner.avatar_url;
    this.repositoryName = reposName;
    this.allIssueCount = map.allIssueCount;
    this.topics = map.topics;
    this.openIssuesCount = map.openIssuesCount;
    this.repositoryStar =
        map.watchersCount != null ? map.watchersCount.toString() : "";
    this.repositoryFork =
        map.forksCount != null ? map.forksCount.toString() : "";
    this.repositoryWatch =
        map.subscribersCount != null ? map.subscribersCount.toString() : "";
    this.repositoryIssue =
        map.openIssuesCount != null ? map.openIssuesCount.toString() : "";
    //this.repositoryIssueClose = map.closedIssuesCount != null ? map.closed_issues_count.toString() : "";
    //this.repositoryIssueAll = map.all_issues_count != null ? map.all_issues_count.toString() : "";
    this.repositorySize =
        ((map.size / 1024.0)).toString().substring(0, 3) + "M";
    this.repositoryType = map.language;
    this.repositoryDes = map.description;
    this.repositoryIsFork = map.fork;
    this.license = map.license != null ? map.license.name : "";
    this.repositoryParentName = map.parent != null ? map.parent.fullName : null;
    this.repositoryParentUser =
        map.parent != null ? map.parent.owner.login : null;
    this.created_at = getTimeAgoStr(map.createdAt);
    this.push_at = getTimeAgoStr(map.pushedAt);
  }
}
