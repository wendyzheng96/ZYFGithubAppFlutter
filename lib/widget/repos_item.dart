import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
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
            border: Border(bottom: BorderSide(
                width: 1.0, color: Theme.of(context).dividerColor
            )),
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
                                    Icon(Icons.group, color: Color(ZColors.textHintValue),size: 14,),
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
                          backgroundColor: _getLanguageColor(reposViewModel.repositoryType),
                          radius: 6,
                        ),
                        Padding(padding: EdgeInsets.only(left: 3)),
                        Text(reposViewModel.repositoryType,
                            style: TextStyle(
                                color: Color(0xff586069), fontSize: 14))
                      ],
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 12, bottom: 12),
                  child: Text(
                    reposViewModel.repositoryDes,
                    style: TextStyle(
                        color: Color(ZColors.textPrimaryValue),
                        fontSize: 14,
                        height: 1.2
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.visibility,
                            color: Color(ZColors.textSecondaryValue),
                            size: 18,
                          ),
                          Padding(padding: EdgeInsets.only(left: 4)),
                          Text(
                            reposViewModel.repositoryWatch,
                            style: ZStyles.minTextSecondary,
                          )
                        ],
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.star_border,
                            color: Color(ZColors.textSecondaryValue),
                            size: 18,
                          ),
                          Padding(padding: EdgeInsets.only(left: 4)),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.share,
                            color: Color(ZColors.textSecondaryValue),
                            size: 18,
                          ),
                          Padding(padding: EdgeInsets.only(left: 4)),
                          Text(
                            reposViewModel.repositoryFork,
                            style: ZStyles.minTextSecondary,
                          )
                        ],
                      ),
                      flex: 1,
                    )
                  ],
                )
              ],
            ),
          )),
      onTap: onPressed,
    );
  }

  Color _getLanguageColor(String type){
    switch(type){
      case 'Assembly':
        return Color(0xff586069);
      case 'C':
        return Color(0xff555555);
      case 'C#':
        return Color(0xff178600);
      case 'C++':
        return Color(0xfff34b7d);
      case 'Clojure':
        return Color(0xffdb5855);
      case 'CSS':
        return Color(0xff563d7c);
      case 'CoffeeScript':
        return Color(0xff244776);
      case 'Dart':
        return Color(0xff00b4ab);
      case 'Go':
        return Color(0xfd00add8);
      case 'Haskell':
        return Color(0xff5e5086);
      case 'HTML':
        return Color(0xffe34c26);
      case 'Java':
        return Color(0xffb07219);
      case 'JavaScript':
        return Color(0xfff1e05a);
      case 'Jupyter Notebook':
        return Color(0xffda5b0b);
      case 'Kotlin':
        return Color(0xfff18e33);
      case 'Lua':
        return Color(0xff000080);
      case 'Makefile':
        return Color(0xff427819);
      case 'Objective-C':
        return Color(0xff438eff);
      case 'Perl':
        return Color(0xff0298c3);
      case 'PHP':
        return Color(0xff4f5d95);
      case 'Python':
        return Color(0xff3572a5);
      case 'Ruby':
        return Color(0xff701514);
      case 'Rust':
        return Color(0xffdea584);
      case 'Scala':
        return Color(0xffc22d40);
      case 'Shell':
        return Color(0xff89e051);
      case 'Swift':
        return Color(0xffffac45);
      case 'TypeScript':
        return Color(0xff2b7489);
      case 'Vim script':
        return Color(0xff199f4b);
      case 'Vue':
        return Color(0xff2c3e50);
      default:
        return Colors.transparent;
    }
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
    repositoryName = model.reposName;
    repositoryType = model.language;
    repositoryDes = model.description;
    repositoryStar = model.starCount;
    repositoryFork = model.forkCount;
    repositoryWatch = model.meta;
  }
}
