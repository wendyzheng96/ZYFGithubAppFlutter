import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/model/TrendingRepoModel.dart';

/// 仓库item
/// Create by zyf
/// Date: 2019/7/18
class ReposItem extends StatelessWidget {
  final ReposViewModel reposViewModel;

  final VoidCallback onPressed;

  ReposItem(this.reposViewModel, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 1.0, color: Theme.of(context).dividerColor)),
            color: Colors.white,
          ),
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: NetworkImage(reposViewModel.ownerPic),
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            reposViewModel.repositoryName,
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
                                  reposViewModel.ownerName,
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
                          backgroundColor:
                              CommonUtils.getLanguageColor(reposViewModel.repositoryType),
                          radius: 6,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                              reposViewModel.repositoryType,
                              style: TextStyle(
                                  color: Color(0xff586069), fontSize: 14)),
                        )
                      ],
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 12, bottom: 16),
                  child: Text(
                    reposViewModel.repositoryDes,
                    style: TextStyle(
                        color: Color(ZColors.textPrimaryValue),
                        fontSize: 14,
                        height: 1.2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.star_border,
                            color: Color(ZColors.textSecondaryValue),
                            size: 16,
                          ),
                          Padding(padding: EdgeInsets.only(left: 2)),
                          Text(
                            reposViewModel.repositoryStar,
                            style: ZStyles.minTextSecondary,
                          )
                        ],
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.share,
                            color: Color(ZColors.textSecondaryValue),
                            size: 16,
                          ),
                          Padding(padding: EdgeInsets.only(left: 2)),
                          Text(
                            reposViewModel.repositoryFork,
                            style: ZStyles.minTextSecondary,
                          )
                        ],
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(
                            Icons.star,
                            color: Color(ZColors.textSecondaryValue),
                            size: 16,
                          ),
                          Padding(padding: EdgeInsets.only(left: 4)),
                          Text(
                            reposViewModel.repositoryWatch,
                            style: ZStyles.minTextSecondary,
                          )
                        ],
                      ),
                      flex: 2,
                    ),
                  ],
                )
              ],
            ),
          )),
      onTap: onPressed,
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

  ReposViewModel();

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
  }
}
