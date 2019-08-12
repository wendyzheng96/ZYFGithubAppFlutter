import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/model/Repository.dart';
import 'package:github_app_flutter/model/TrendingRepoModel.dart';
import 'package:github_app_flutter/widget/icon_text.dart';

/// 仓库item
/// Create by zyf
/// Date: 2019/7/18
class ReposItem extends StatelessWidget {
  final ReposViewModel reposModel;

  final VoidCallback onPressed;

  ReposItem(this.reposModel, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1.0, color: Theme.of(context).dividerColor)),
          color: Theme.of(context).cardColor,
        ),
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(ZColors.imgColor),
                    backgroundImage: NetworkImage(reposModel.ownerPic),
                  ),
                  Expanded(
                      child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          reposModel.repositoryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(ZColors.primaryDarkValue),
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 4),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.group,
                                color: Color(ZColors.textHintValue),
                                size: 14,
                              ),
                              Padding(padding: EdgeInsets.only(left: 4)),
                              Text(
                                reposModel.ownerName,
                                style: TextStyle(
                                    color: Color(ZColors.textHintValue),
                                    fontSize: 13),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: CommonUtils.getLanguageColor(
                            reposModel.repositoryType),
                        radius: 6,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(reposModel.repositoryType,
                            style: TextStyle(
                                color: Color(0xff586069), fontSize: 14)),
                      )
                    ],
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 12, bottom: 16),
                child: (reposModel.repositoryDes == null ||
                        reposModel.repositoryDes.isEmpty)
                    ? null
                    : Text(
                        reposModel.repositoryDes,
                        style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: 14,
                            height: 1.2),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    reposModel.isTrend ? _getTrendBottom() : _getNormalBottom(),
              )
            ],
          ),
        ),
      ),
      onTap: onPressed,
    );
  }

  _getNormalBottom() => <Widget>[
        Expanded(
          child: _getIconText(Icons.star_border, reposModel.repositoryStar,
              isCenter: true),
          flex: 1,
        ),
        Expanded(
          child: _getIconText(Icons.share, reposModel.repositoryFork,
              isCenter: true),
          flex: 1,
        ),
        Expanded(
          child: _getIconText(Icons.error_outline, reposModel.repositoryWatch,
              isCenter: true),
          flex: 1,
        ),
      ];

  _getTrendBottom() => <Widget>[
        Expanded(
          child: _getIconText(Icons.star_border, reposModel.repositoryStar),
          flex: 1,
        ),
        Expanded(
          child: _getIconText(Icons.share, reposModel.repositoryFork),
          flex: 1,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              _getIconText(Icons.star, reposModel.repositoryWatch),
            ],
          ),
          flex: 2,
        ),
      ];

  _getIconText(IconData iconData, String text, {bool isCenter = false}) {
    return IconText(
      text,
      iconData,
      ZStyles.minTextSecondary,
      iconSize: 16,
      iconColor: Color(ZColors.textSecondaryValue),
      padding: 2,
      mainAxisAlignment:
          isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
    );
  }
}

class ReposViewModel {
  String ownerName;
  String ownerPic;
  String repositoryName;
  String repositoryType = "";
  String repositoryDes;
  String repositoryStar;
  String repositoryFork;
  String repositoryWatch;
  String hideWatchIcon;
  bool isTrend = false;

  ReposViewModel();

  ReposViewModel.fromMap(Repository data) {
    ownerName = data.owner.login;
    ownerPic = data.owner.avatarUrl;
    repositoryName = data.name;
    repositoryStar = data.watchersCount.toString();
    repositoryFork = data.forksCount.toString();
    repositoryWatch = data.openIssuesCount.toString();
    repositoryType = data.language ?? '';
    repositoryDes = data.description ?? '---';
  }

  ReposViewModel.fromTrendMap(TrendingRepoModel model) {
    ownerName = model.name;
    ownerPic = model.contributors.length > 0 ? model.contributors[0] : "";
    ownerPic = ownerPic.replaceAll('s=40', 's=80');
    repositoryName = model.reposName;
    repositoryType = model.language;
    repositoryDes = model.description;
    repositoryStar = model.starCount;
    repositoryFork = model.forkCount;
    repositoryWatch = model.meta;
    isTrend = true;
  }
}
