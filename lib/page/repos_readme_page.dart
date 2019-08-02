import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/page/repository_detail_page.dart';

/// 仓库Readme介绍
/// Create by zyf
/// Date: 2019/7/27
class ReposReadmePage extends StatefulWidget {
  ///用户名
  final String username;

  ///仓库名
  final String reposName;

  ReposReadmePage(this.username, this.reposName);

  @override
  _ReposReadmePageState createState() => _ReposReadmePageState();
}

class _ReposReadmePageState extends State<ReposReadmePage>
    with AutomaticKeepAliveClientMixin {
  bool isShow = false;

  String markdownData;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    isShow = true;
    super.initState();
    refreshReadme();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget widget = (markdownData == null)
        ? emptyWidget()
        : SingleChildScrollView(
            padding: EdgeInsets.all(14),
            child: MarkdownBody(
              data: _getMarkDownData(markdownData),
              onTapLink: (String source) {
                CommonUtils.launchOutURL(source, context);
              },
            ),
          );
    return widget;
  }

  @override
  void dispose() {
    isShow = false;
    super.dispose();
  }

  Widget emptyWidget() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      SpinKitCircle(
        color: Theme.of(context).primaryColor,
        size: 30,
      ),
      Container(
        padding: EdgeInsets.only(left: 10),
        child: Text(
          '努力加载中...',
          style: TextStyle(
            color: Color(ZColors.textSecondaryValue),
            fontSize: 14,
          ),
        ),
      )
    ],
  );

  refreshReadme() {
    ReposDao.getReposReadme(widget.username, widget.reposName,
        ReposDetailModel.of(context).currentBranch)
        .then((res) {
      if (res != null && res.result) {
        if (isShow) {
          setState(() {
            markdownData = res.data;
          });
          return res.next?.call();
        } else {
          Future.value(null);
        }
      }
    }).then((res) {
      if (res != null && res.result) {
        if (isShow) {
          setState(() {
            markdownData = res.data;
          });
        }
      }
    });
  }

  _getMarkDownData(String markdownData) {
    ///优化图片显示
    RegExp exp = new RegExp(r'!\[.*\]\((.+)\)');
    RegExp expImg = new RegExp("<img.*?(?:>|\/>)");
    RegExp expSrc = new RegExp("src=[\'\"]?([^\'\"]*)[\'\"]?");

    String mdDataCode = markdownData;
    try {
      Iterable<Match> tags = exp.allMatches(markdownData);
      if (tags != null && tags.length > 0) {
        for (Match m in tags) {
          String imageMatch = m.group(0);
          if (imageMatch != null && !imageMatch.contains(".svg")) {
            String match = imageMatch.replaceAll("\)", "?raw=true)");
            if (!match.contains(".svg") && match.contains("http")) {
              ///增加点击
              String src = match
                  .replaceAll(new RegExp(r'!\[.*\]\('), "")
                  .replaceAll(")", "");
              String actionMatch = "[$match]($src)";
              match = actionMatch;
            } else {
              match = "";
            }
            mdDataCode = mdDataCode.replaceAll(m.group(0), match);
          }
        }
      }

      ///优化img标签的src资源
      tags = expImg.allMatches(markdownData);
      if (tags != null && tags.length > 0) {
        for (Match m in tags) {
          String imageTag = m.group(0);
          String match = imageTag;
          if (imageTag != null) {
            Iterable<Match> srcTags = expSrc.allMatches(imageTag);
            for (Match srcMatch in srcTags) {
              String srcString = srcMatch.group(0);
              if (srcString != null && srcString.contains("http")) {
                String newSrc = srcString.substring(
                    srcString.indexOf("http"), srcString.length - 1) +
                    "?raw=true";

                ///增加点击
                match = "[![]($newSrc)]($newSrc)";
              }
            }
          }
          mdDataCode = mdDataCode.replaceAll(imageTag, match);
        }
      }
    } catch(e) {
      print(e.toString());
    }
    return mdDataCode;
  }
}
