
import 'package:github_app_flutter/common/config/config.dart';

/// 地址数据
/// Create by zyf
/// Date: 2019/7/23
class Address {
  static const String host = "https://api.github.com/";
  static const String hostWeb = "https://github.com/";
  static const String graphicHost = 'https://ghchart.rshah.org/';
  static const String updateUrl = 'https://www.pgyer.com/vj2B';

  ///获取授权 post
  static getAuthorization() {
    return "${host}authorizations";
  }

  ///我的用户信息 get
  static getMyUserInfo() {
    return "${host}user";
  }

  ///获取用户信息 get
  static getUserInfo(username) {
    return "${host}users/$username";
  }

  ///获取用户的star get
  static userStar(username, sort) {
    sort ??= 'updated';
    return "${host}users/$username/starred?sort=$sort";
  }

  ///用户相关的事件信息 get
  static getEvent(username) {
    return "${host}users/$username/events";
  }

  ///用户收到的事件信息 get
  static getEventReceived(userName) {
    return "${host}users/$userName/received_events";
  }

  ///趋势 get
  static trending(since, languageType) {
    if (languageType != null) {
      return "https://github.com/trending/$languageType?since=$since";
    }
    return "https://github.com/trending?since=$since";
  }

  ///关注仓库 put
  static resolveStarRepos(reposOwner, repos) {
    return "${host}user/starred/$reposOwner/$repos";
  }

  ///订阅仓库 put
  static resolveWatcherRepos(reposOwner, repos) {
    return "${host}user/subscriptions/$reposOwner/$repos";
  }

  ///create fork post
  static createFork(reposOwner, reposName) {
    return "${host}repos/$reposOwner/$reposName/forks";
  }

  ///branch get
  static getBranches(reposOwner, reposName) {
    return "${host}repos/$reposOwner/$reposName/branches";
  }

  ///处理分页参数
  static getPageParams(tab, page, [pageSize = Config.PAGE_SIZE]) {
    if (page != null) {
      if (pageSize != null) {
        return "${tab}page=$page&per_page=$pageSize";
      } else {
        return "${tab}page=$page";
      }
    } else {
      return "";
    }
  }
}