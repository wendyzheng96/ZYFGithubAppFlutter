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

  ///组织成员
  static getMember(username) {
    return "${host}orgs/$username/members";
  }

  ///获取用户的star get
  static userStar(username, sort) {
    sort ??= 'updated';
    return "${host}users/$username/starred?sort=$sort";
  }

  ///用户关注人列表 get
  static getUserFollowed(userName) {
    return "${host}users/$userName/following";
  }

  ///用户的粉丝列表 get
  static getUserFollower(userName) {
    return "${host}users/$userName/followers";
  }

  ///我的粉丝列表 get
  static getMyFollower() {
    return "${host}user/followers";
  }

  ///用户相关的事件信息 get
  static getEvent(username) {
    return "${host}users/$username/events";
  }

  ///用户收到的事件信息 get
  static getEventReceived(userName) {
    return "${host}users/$userName/received_events";
  }

  ///用户的仓库 get
  static userRepos(userName, sort) {
    sort ??= 'pushed';
    return "${host}users/$userName/repos?sort=$sort";
  }

  ///趋势 get
  static trending(since, languageType) {
    if (languageType != null) {
      return "https://github.com/trending/$languageType?since=$since";
    }
    return "https://github.com/trending?since=$since";
  }

  ///搜索 get
  static search(q, sort, order, type, page, [pageSize = Config.PAGE_SIZE]) {
    if (type == 'user') {
      return "${host}search/users?q=$q&page=$page&per_page=$pageSize";
    }
    sort ??= "best%20match";
    order ??= "desc";
    page ??= 1;
    pageSize ??= Config.PAGE_SIZE;
    return "${host}search/repositories?q=$q&sort=$sort&order=$order&page=$page&per_page=$pageSize";
  }

  ///搜索topic tag
  static searchTopic(topic) {
    return "${host}search/repositories?q=topic:$topic&sort=stars&order=desc";
  }

  ///仓库详情 get
  static getReposDetail(reposOwner, reposName) {
    return "${host}repos/$reposOwner/$reposName";
  }

  ///仓库活动 get
  static getReposEvent(reposOwner, reposName) {
    return "${host}networks/$reposOwner/$reposName/events";
  }

  ///仓库提交 get
  static getReposCommits(reposOwner, reposName) {
    return "${host}repos/$reposOwner/$reposName/commits";
  }

  ///仓库提交详情 get
  static getReposCommitsInfo(reposOwner, reposName, sha) {
    return "${host}repos/$reposOwner/$reposName/commits/$sha";
  }

  ///仓库路径下的内容 get
  static reposDataDir(reposOwner, repos, path, [branch = 'master']) {
    return "${host}repos/$reposOwner/$repos/contents/$path" +
        ((branch == null) ? "" : ("?ref=" + branch));
  }

  ///仓库Fork get
  static getReposForks(reposOwner, reposName) {
    return "${host}repos/$reposOwner/$reposName/forks";
  }

  ///仓库Star get
  static getReposStar(reposOwner, reposName) {
    return "${host}repos/$reposOwner/$reposName/stargazers";
  }

  ///仓库Watch get
  static getReposWatcher(reposOwner, reposName) {
    return "${host}repos/$reposOwner/$reposName/subscribers";
  }

  ///仓库Issue get
  static getReposIssue(reposOwner, reposName, state, sort, direction) {
    state ??= 'all';
    sort ??= 'created';
    direction ??= 'desc';
    return "${host}repos/$reposOwner/$reposName/issues?state=$state&sort=$sort&direction=$direction";
  }

  ///创建issue post
  static createIssue(reposOwner, reposName) {
    return "${host}repos/$reposOwner/$reposName/issues";
  }

  ///增加issue评论 post
  static addIssueComment(reposOwner, reposName, issueNumber) {
    return "${host}repos/$reposOwner/$reposName/issues/$issueNumber/comments";
  }

  ///编辑issue put
  static editIssue(reposOwner, reposName, issueNumber) {
    return "${host}repos/$reposOwner/$reposName/issues/$issueNumber";
  }

  ///锁定issue put
  static lockIssue(reposOwner, reposName, issueNumber) {
    return "${host}repos/$reposOwner/$reposName/issues/$issueNumber/lock";
  }

  ///编辑评论 patch, delete
  static editComment(reposOwner, reposName, commentId) {
    return "${host}repos/$reposOwner/$reposName/issues/comments/$commentId";
  }

  ///搜索issue
  static reposIssueSearch(q) {
    return "${host}search/issues?q=$q";
  }

  ///仓库Issue评论 get
  static getIssueComment(reposOwner, reposName, issueNumber) {
    return "${host}repos/$reposOwner/$reposName/issues/$issueNumber/comments";
  }

  ///仓库Issue get
  static getIssueInfo(reposOwner, reposName, issueNumber) {
    return "${host}repos/$reposOwner/$reposName/issues/$issueNumber";
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

  ///README 文件地址 get
  static readmeFile(reposNameFullName, curBranch) {
    return host +
        "repos/" +
        reposNameFullName +
        "/" +
        "readme" +
        ((curBranch == null) ? "" : ("?ref=" + curBranch));
  }

  ///通知 get
  static getNotification(all, participating) {
    if ((all == null && participating == null) ||
        (all == false && participating == false)) {
      return "${host}notifications";
    }
    all ??= false;
    participating ??= false;
    return "${host}notifications?all=$all&participating=$participating";
  }

  ///patch
  static setNotificationAsRead(threadId) {
    return "${host}notifications/threads/$threadId";
  }

  ///put
  static setAllNotificationAsRead() {
    return "${host}notifications";
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
