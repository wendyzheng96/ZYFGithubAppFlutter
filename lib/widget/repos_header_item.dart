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

  @override
  void didUpdateWidget(ReposHeaderItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(Duration(seconds: 0), () {
      ///tag所在Container
      RenderBox renderBox2 =
          layoutTopicContainerKey.currentContext?.findRenderObject();

      ///最后面的一个tag
      RenderBox renderBox3 =
          layoutLastTopicKey.currentContext?.findRenderObject();

      double overflow = ((renderBox3?.localToGlobal(Offset.zero)?.dy ?? 0) -
              (renderBox2?.localToGlobal(Offset.zero)?.dy ?? 0)) -
          (layoutLastTopicKey.currentContext?.size?.height ?? 0);

      var newSize = layoutKey.currentContext.size.height +
          ((overflow > 0) ? overflow : 10);
      if (widgetHeight != newSize && newSize > 0) {
        widgetHeight = newSize;
        widget?.layoutListener
            ?.call(Size(layoutKey.currentContext.size.width, widgetHeight));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: layoutKey,
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Theme.of(context).primaryColorDark,
        margin: EdgeInsets.all(10),
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
              ///透明黑色遮罩
              decoration: BoxDecoration(
                color: Color(0xA0000000),
              ),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      RawMaterialButton(
                        constraints: BoxConstraints(minWidth: 0, minHeight: 0),
                        padding: EdgeInsets.all(0.0),
                        child: Text(
                          widget.reposHeaderViewModel.ownerName,
                          style: TextStyle(
                            color: Color(ZColors.primaryLightValue),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {},
                      ),
                      Text(
                        ' / ',
                        style: ZStyles.largeTextWhiteBold,
                      ),
                      Expanded(
                          child: Text(
                        widget.reposHeaderViewModel.repositoryName,
                        style: ZStyles.largeTextWhiteBold,
                      )),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ///仓库语言
                      Text(widget.reposHeaderViewModel.repositoryType ?? "--",
                          style: ZStyles.smallSubLightText),
                      Container(width: 10, height: 1.0),

                      ///仓库大小
                      Text(widget.reposHeaderViewModel.repositorySize ?? "--",
                          style: ZStyles.smallSubLightText),
                      Container(width: 10, height: 1.0),

                      ///仓库协议
                      Expanded(
                        child: Text(widget.reposHeaderViewModel.license ?? "--",
                            style: ZStyles.smallSubLightText),
                      )
                    ],
                  ),
                  Container(
                      child: new Text(
                        widget.reposHeaderViewModel.repositoryDes ?? "---",
                        style: ZStyles.smallSubLightText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      margin: new EdgeInsets.only(top: 6.0, bottom: 2.0),
                      alignment: Alignment.topLeft),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 5, 2),
                    alignment: Alignment.topRight,
                    child: RawMaterialButton(
                      onPressed: () {},
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      constraints:
                          const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                      child: Text(
                        _getInfoText(context),
                        style: TextStyle(
                            fontSize: ZStyles.smallTextSize,
                            color: Color(
                                widget.reposHeaderViewModel.repositoryIsFork
                                    ? ZColors.primaryLightValue
                                    : ZColors.subLightTextColor)),
                      ),
                    ),
                  ),
                  Divider(
                    color: Color(ZColors.subTextColor),
                  ),
                  _getBottomItemList(),
                  _renderTopicGroup(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///仓库创建和提交状态信息
  _getInfoText(BuildContext context) {
    String createStr = widget.reposHeaderViewModel.repositoryIsFork
        ? 'fork at ${widget.reposHeaderViewModel.repositoryParentName}\n'
        : '创建于 ${widget.reposHeaderViewModel.createdAt}\n';

    String updateStr = '最后提交于 ${widget.reposHeaderViewModel.pushAt}';
    return createStr +
        ((widget.reposHeaderViewModel.pushAt != null) ? updateStr : '');
  }

  Widget _getBottomItemList() => Row(
        children: <Widget>[
          _getBottomItem(Icons.star, widget.reposHeaderViewModel.repositoryStar,
              () {
            NavigatorUtils.gotoCommonList(context,
                widget.reposHeaderViewModel.repositoryName, "user", "repo_star",
                username: widget.reposHeaderViewModel.ownerName,
                reposName: widget.reposHeaderViewModel.repositoryName);
          }),
          _verticalDivider(),
          _getBottomItem(
              Icons.share, widget.reposHeaderViewModel.repositoryFork, () {
            NavigatorUtils.gotoCommonList(
                context,
                widget.reposHeaderViewModel.repositoryName,
                "repository",
                "repo_fork",
                username: widget.reposHeaderViewModel.ownerName,
                reposName: widget.reposHeaderViewModel.repositoryName);
          }),
          _verticalDivider(),
          _getBottomItem(
              Icons.visibility, widget.reposHeaderViewModel.repositoryWatch,
              () {
            NavigatorUtils.gotoCommonList(
                context,
                widget.reposHeaderViewModel.repositoryName,
                "user",
                "repo_watcher",
                username: widget.reposHeaderViewModel.ownerName,
                reposName: widget.reposHeaderViewModel.repositoryName);
          }),
          _verticalDivider(),
          _getBottomItem(Icons.error_outline,
              widget.reposHeaderViewModel.repositoryIssue, () {}),
        ],
      );

  ///垂直分割线
  _verticalDivider() => Container(
      width: 0.5, height: 20.0, color: Color(ZColors.subLightTextColor));

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
          iconSize: 14.0,
          padding: 2.0,
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
            username: item, reposName: "");
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
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Wrap(
        spacing: 10.0,
        runSpacing: 5.0,
        children: list,
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
  String createdAt = "";
  String pushAt = "";
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
    this.ownerPic = map.owner.avatarUrl;
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
    this.createdAt = getTimeAgoStr(map.createdAt);
    this.pushAt = getTimeAgoStr(map.pushedAt);
  }
}
