import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:github_app_flutter/common/ab/provider/read_history_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_commits_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_detail_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_event_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_fork_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_readme_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_star_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_watcher_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/search_history_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/trend_repository_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/user_repos_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/user_stared_db_provider.dart';
import 'package:github_app_flutter/common/dao/dao_result.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/net/api.dart';
import 'package:github_app_flutter/common/utils/trend_utils.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/FileModel.dart';
import 'package:github_app_flutter/model/PushCommit.dart';
import 'package:github_app_flutter/model/RepoCommit.dart';
import 'package:github_app_flutter/model/Repository.dart';
import 'package:github_app_flutter/model/TrendingRepoModel.dart';
import 'package:github_app_flutter/model/User.dart';

/// 仓库数据相关
/// Create by zyf
/// Date: 2019/7/25
class ReposDao {
  /// 趋势数据
  /// @param page 分页，趋势数据其实没有分页
  /// @param since 数据时长， 本日，本周，本月
  /// @param languageType 语言
  static Future<DataResult> getTrendRepos(
      {String since = 'daily',
      String languageType,
      page = 0,
      bool needDb = false}) async {
    TrendRepositoryDbProvider provider = TrendRepositoryDbProvider();
    String languageTypeDb = languageType ?? "*";

    next() async {
      String url = Address.trending(since, languageType);
      var res = await httpManager.netFetch(
          url, null, null, Options(contentType: ContentType.text));
      if (res != null && res.result) {
        List<TrendingRepoModel> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        var repoList = TrendingUtils.htmlToRepo(data);
        if (needDb) {
          provider.insert(languageTypeDb, since, json.encode(repoList));
        }
        for (int i = 0; i < repoList.length; i++) {
          list.add(repoList[i]);
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<TrendingRepoModel> dbList =
          await provider.getRepos(languageTypeDb, since);
      if (dbList == null || dbList.length == 0) {
        return await next();
      }
      DataResult dataResult = DataResult(dbList, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 搜索仓库
  /// @param q 搜索关键字
  /// @param sort 分类排序，beat match、most star等
  /// @param order 倒序或者正序
  /// @param type 搜索类型，人或者仓库 null \ 'user',
  /// @param page
  /// @param pageSize
  static searchRepositoryDao(
      q, language, sort, order, type, page, pageSize) async {
    if (language != null) {
      q = q + "%2Blanguage%3A$language";
    }
    String url = Address.search(q, sort, order, type, page, pageSize);
    var res = await httpManager.netFetch(url, null, null, null);
    if (type == null) {
      if (res != null && res.result) {
        List<Repository> list = new List();
        var dataList = res.data["items"];
        if (dataList == null || dataList.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    } else {
      if (res != null && res.result) {
        List<User> list = new List();
        var data = res.data["items"];
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(User.fromJson(data[i]));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }
  }

  /// 仓库的详情数据
  static Future<DataResult> getReposDetail(username, reposName, branch,
      {needDb = true}) async {
    String fullName = username + "/" + reposName;
    ReposDetailDbProvider provider = new ReposDetailDbProvider();

    next() async {
      String url =
          Address.getReposDetail(username, reposName) + "?ref=" + branch;
      var res = await httpManager.netFetch(url, null,
          {"Accept": 'application/vnd.github.mercy-preview+json'}, null);
      if (res != null && res.result) {
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        Repository repository = Repository.fromJson(data);
        var issueResult =
            await ReposDao.getReposIssueStatus(username, reposName);
        if (issueResult != null && issueResult.result) {
          repository.allIssueCount = int.parse(issueResult.data);
        }
        if (needDb) {
          provider.insert(fullName, json.encode(repository.toJson()));
        }
        saveReadHistory(
            fullName, DateTime.now(), json.encode(repository.toJson()));
        return DataResult(repository, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      Repository repository = await provider.getReposDetail(fullName);
      if (repository == null) {
        return await next();
      }
      return DataResult(repository, true, next: next);
    }
    return await next();
  }

  /// 获取用户对当前仓库的star、watcher状态
  static getRepositoryStatus(String username, String reposName) async {
    String urlStar = Address.resolveStarRepos(username, reposName);
    String urlWatch = Address.resolveWatcherRepos(username, reposName);
    var resStar = await httpManager.netFetch(
        urlStar, null, null, Options(contentType: ContentType.text),
        noTip: true);
    var resWatch = await httpManager.netFetch(
        urlWatch, null, null, Options(contentType: ContentType.text),
        noTip: true);
    var data = {"star": resStar.result, "watch": resWatch.result};
    return DataResult(data, true);
  }

  /// 仓库活动事件
  static Future<DataResult> getReposEvents(userName, reposName,
      {page = 0, branch = "master", needDb = false}) async {
    String fullName = userName + "/" + reposName;
    ReposEventDbProvider provider = ReposEventDbProvider();

    next() async {
      String url = Address.getReposEvent(userName, reposName) +
          Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<Event> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Event.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Event> list = await provider.getEvents(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 获取仓库的提交列表
  static Future<DataResult> getReposCommits(userName, reposName,
      {page = 0, branch = "master", needDb = false}) async {
    String fullName = userName + "/" + reposName;

    ReposCommitsDbProvider provider = ReposCommitsDbProvider();

    next() async {
      String url = Address.getReposCommits(userName, reposName) +
          Address.getPageParams("?", page) +
          "&sha=" +
          branch;
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<RepoCommit> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(null, false);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(RepoCommit.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, branch, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<RepoCommit> list = await provider.getCommits(fullName, branch);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  static Future<DataResult> getReposCommitsInfo(
      username, reposName, sha) async {
    String url = Address.getReposCommitsInfo(username, reposName, sha);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      PushCommit pushCommit = PushCommit.fromJson(res.data);
      return DataResult(pushCommit, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// 获取仓库的文件列表
  static Future<DataResult> getReposFileDir(userName, reposName,
      {path = '', branch, text = false, isHtml = false}) async {
    String url = Address.reposDataDir(userName, reposName, path, branch);
    var res = await httpManager.netFetch(
      url,
      null,
      isHtml
          ? {"Accept": 'application/vnd.github.html'}
          : {"Accept": 'application/vnd.github.VERSION.raw'},
      new Options(contentType: text ? ContentType.text : ContentType.json),
    );
    if (res != null && res.result) {
      if (text) {
        return DataResult(res.data, true);
      }
      List<FileModel> list = List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return DataResult(null, false);
      }
      List<FileModel> dirs = [];
      List<FileModel> files = [];
      for (int i = 0; i < data.length; i++) {
        FileModel file = FileModel.fromJson(data[i]);
        if (file.type == 'file') {
          files.add(file);
        } else {
          dirs.add(file);
        }
      }
      list.addAll(dirs);
      list.addAll(files);
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  ///star仓库
  static Future<DataResult> doRepositoryStar(username, reposName, star) async {
    String url = Address.resolveStarRepos(username, reposName);
    var res = await httpManager.netFetch(
        url,
        null,
        null,
        Options(
            method: !star ? 'PUT' : 'DELETE', contentType: ContentType.text));
    return Future<DataResult>(() {
      return DataResult(null, res.result);
    });
  }

  ///watcher仓库
  static Future<DataResult> doRepositoryWatcher(
      username, reposName, watch) async {
    String url = Address.resolveWatcherRepos(username, reposName);
    var res = await httpManager.netFetch(
        url,
        null,
        null,
        Options(
            method: !watch ? 'PUT' : 'DELETE', contentType: ContentType.text));
    return Future<DataResult>(() {
      return DataResult(null, res.result);
    });
  }

  /// 创建仓库的fork分支
  static createForkDao(username, reposName) async {
    String url = Address.createFork(username, reposName);
    var res = await httpManager.netFetch(url, null, null,
        Options(method: "POST", contentType: ContentType.text));
    return new DataResult(null, res.result);
  }

  /// 获取当前仓库所有分支
  static getBranches(username, reposName) async {
    String url = Address.getBranches(username, reposName);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<String> list = List();
      var dataList = res.data;
      if (dataList == null || dataList.length == 0) {
        return DataResult(null, false);
      }
      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];
        list.add(data['name']);
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  ///获取仓库readme内容
  static Future<DataResult> getReposReadme(
      String username, String reposName, String branch,
      {bool needDb = true}) async {
    String fullName = username + "/" + reposName;
    ReposReadmeDbProvider provider = ReposReadmeDbProvider();

    next() async {
      String url = Address.readmeFile(fullName, branch);
      var res = await httpManager.netFetch(
          url,
          null,
          {"Accept": 'application/vnd.github.VERSION.raw'},
          Options(contentType: ContentType.text));
      if (res != null && res.result) {
        if (needDb) {
          provider.insert(fullName, branch, res.data);
        }
        return DataResult(res.data, true);
      }
      return DataResult(null, false);
    }

    if (needDb) {
      String readme = await provider.getReposReadme(fullName, branch);
      if (readme == null) {
        return next();
      }
      DataResult dataResult = DataResult(readme, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 获取issue总数
  static getReposIssueStatus(userName, repository) async {
    String url = Address.getReposIssue(userName, repository, null, null, null) +
        "&per_page=1";
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.headers != null) {
      try {
        List<String> link = res.headers['link'];
        if (link != null) {
          int indexStart = link[0].lastIndexOf("page=") + 5;
          int indexEnd = link[0].lastIndexOf(">");
          if (indexStart >= 0 && indexEnd >= 0) {
            String count = link[0].substring(indexStart, indexEnd);
            return DataResult(count, true);
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return DataResult(null, false);
  }

  /// 获取当前仓库所有star用户
  static getReposStar(username, reposName, page,
      {needDb = false}) async {
    String fullName = username + "/" + reposName;
    ReposStarDbProvider provider = ReposStarDbProvider();
    next() async {
      String url = Address.getReposStar(username, reposName) +
          Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<User> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(User.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(data));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.getList(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 获取当前仓库所有star用户
  static getReposWatcher(username, reposName, page,
      {needDb = false}) async {
    String fullName = username + "/" + reposName;
    ReposWatcherDbProvider provider = new ReposWatcherDbProvider();
    next() async {
      String url = Address.getReposWatcher(username, reposName) +
          Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<User> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(User.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(data));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.getList(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 获取仓库的fork分支
  static getReposForks(username, reposName, page,
      {needDb = false}) async {
    String fullName = username + "/" + reposName;
    ReposForkDbProvider provider = ReposForkDbProvider();
    next() async {
      String url = Address.getReposForks(username, reposName) +
          Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result && res.data.length > 0) {
        List<Repository> list = new List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(fullName, json.encode(dataList));
        }
        return new DataResult(list, true);
      } else {
        return new DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.getList(fullName);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = new DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 获取用户的仓库
  static getUserRepos(username, page, sort, {needDb = false}) async {
    UserReposDbProvider provider = UserReposDbProvider();
    next() async {
      String url =
          Address.userRepos(username, sort) + Address.getPageParams("&", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<Repository> list = new List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(username, json.encode(dataList));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.getRepos(username);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 获取用户所有star的仓库
  static getStarRepos(username, page, sort, {needDb = false}) async {
    UserStaredDbProvider provider = UserStaredDbProvider();
    next() async {
      String url =
          Address.userStar(username, sort) + Address.getPageParams("&", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<Repository> list = List();
        var dataList = res.data;
        if (dataList == null || dataList.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < dataList.length; i++) {
          var data = dataList[i];
          list.add(Repository.fromJson(data));
        }
        if (needDb) {
          provider.insert(username, json.encode(dataList));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Repository> list = await provider.getRepos(username);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 搜索话题
  static searchTopicRepos(searchTopic, {page = 0}) async {
    String url =
        Address.searchTopic(searchTopic) + Address.getPageParams("&", page);
    var res = await httpManager.netFetch(url, null, null, null);
    var data = (res.data != null && res.data["items"] != null)
        ? res.data["items"]
        : res.data;
    if (res != null && res.result && data != null && data.length > 0) {
      List<Repository> list = List();
      var dataList = data;
      if (dataList == null || dataList.length == 0) {
        return DataResult(list, true);
      }
      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];
        list.add(Repository.fromJson(data));
      }
      return new DataResult(list, true);
    } else {
      return new DataResult(null, false);
    }
  }

  /// 保存阅读历史
  static saveReadHistory(String fullName, DateTime dateTime, String data) {
    ReadHistoryDbProvider provider = ReadHistoryDbProvider();
    provider.insert(fullName, dateTime, data);
  }

  /// 获取阅读历史
  static getReadHistory(page) async {
    ReadHistoryDbProvider provider = ReadHistoryDbProvider();
    List<Repository> list = await provider.getHistoryData(page);
    if (list == null) {
      return DataResult(null, false);
    }
    return DataResult(list, true);
  }

  ///保存搜索历史
  static saveSearchKey(String keyword){
    SearchHistoryDbProvider provider = SearchHistoryDbProvider();
    provider.insert(keyword);
  }

  ///获取搜索历史
  static getSearchHistory() async {
    SearchHistoryDbProvider provider = SearchHistoryDbProvider();
    List<String> list = await provider.getSearchHistory();
    if(list == null){
      return DataResult(null, false);
    } else {
      return DataResult(list, true);
    }
  }

  ///删除搜索关键词
  static deleteSearchKey(String searchKey){
    SearchHistoryDbProvider provider = SearchHistoryDbProvider();
    provider.deleteByKey(searchKey);
  }

  ///清空搜索历史
  static clearSearchHistory(){
    SearchHistoryDbProvider provider = SearchHistoryDbProvider();
    provider.clearHistory();
  }

}
