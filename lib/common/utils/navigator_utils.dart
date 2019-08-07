import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github_app_flutter/page/code_detail_web_page.dart';
import 'package:github_app_flutter/page/common_list_page.dart';
import 'package:github_app_flutter/page/issue_detail_page.dart';
import 'package:github_app_flutter/page/person_page.dart';
import 'package:github_app_flutter/page/photo_view_page.dart';
import 'package:github_app_flutter/page/push_detail_page.dart';
import 'package:github_app_flutter/page/repository_detail_page.dart';
import 'package:github_app_flutter/page/web_view_page.dart';

/// 导航栏
/// Create by zyf
/// Date: 2019/7/13

class NavigatorUtils {
  ///替换
  static pushReplaceNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  ///切换无参数页面
  static pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  ///公共打开方式
  static navigatorRouter(BuildContext context, Widget widget) {
    return Navigator.push(context,
        CupertinoPageRoute(builder: (context) => pageContainer(widget)));
  }

  ///Page页面的容器，做一次通用自定义
  static Widget pageContainer(Widget widget) {
    return MediaQuery(
      data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
          .copyWith(textScaleFactor: 1),
      child: widget,
    );
  }

  ///通用列表
  static gotoCommonList(
      BuildContext context, String title, String showType, String dataType,
      {String username, String reposName}) {
    navigatorRouter(
      context,
      CommonListPage(
        title,
        showType,
        dataType,
        username: username,
        reposName: reposName,
      ),
    );
  }

  ///图片预览
  static gotoPhotoPage(BuildContext context, String url) {
    navigatorRouter(context, PhotoViewPage(url));
  }

  ///文件代码详情Web
  static gotoCodeDetailPageWeb(BuildContext context,
      {String title,
      String username,
      String reposName,
      String path,
      String data,
      String branch,
      String htmlUrl}) {
    navigatorRouter(
      context,
      CodeDetailWebPage(
        title: title,
        username: username,
        reposName: reposName,
        path: path,
        data: data,
        branch: branch,
        htmlUrl: htmlUrl,
      ),
    );
  }

  ///issue详情
  static goIssueDetail(
      BuildContext context, String userName, String reposName, String num,
      {bool needRightLocalIcon = false}) {
    return navigatorRouter(
      context,
      IssueDetailPage(
        userName,
        reposName,
        num,
        needHomeIcon: needRightLocalIcon,
      ),
    );
  }

  ///提交详情
  static goPushDetailPage(BuildContext context, String username,
      String reposName, String sha, bool needHomeIcon) {
    return navigatorRouter(
      context,
      PushDetailPage(
        username,
        reposName,
        sha,
        needHomeIcon: needHomeIcon,
      ),
    );
  }

  ///仓库详情
  static goReposDetail(
      BuildContext context, String username, String reposName) {
    return navigatorRouter(context, RepositoryDetailPage(username, reposName));
  }

  ///用户详情
  static goPersonPage(BuildContext context, String username) {
    navigatorRouter(context, PersonPage(username));
  }

  static launchWebView(BuildContext context, String title, String url) {
    if (url.startsWith("http")) {
      navigatorRouter(context, WebViewPage(url, title));
    } else {
      navigatorRouter(
          context,
          WebViewPage(
              Uri.dataFromString(url,
                      mimeType: 'text/html',
                      encoding: Encoding.getByName("utf-8"))
                  .toString(),
              title));
    }
  }
}
