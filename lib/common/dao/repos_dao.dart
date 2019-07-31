import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:github_app_flutter/common/ab/provider/read_history_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_commits_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_detail_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_event_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_readme_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/trend_repository_db_provider.dart';
import 'package:github_app_flutter/common/dao/dao_result.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/net/api.dart';
import 'package:github_app_flutter/common/utils/trend_utils.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/RepoCommit.dart';
import 'package:github_app_flutter/model/Repository.dart';
import 'package:github_app_flutter/model/TrendingRepoModel.dart';

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
      bool needDb = true}) async {
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
        saveHistoryDao(
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
        List<RepoCommit> list = new List();
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

  /// 保存阅读历史
  static saveHistoryDao(String fullName, DateTime dateTime, String data) {
    ReadHistoryDbProvider provider = ReadHistoryDbProvider();
    provider.insert(fullName, dateTime, data);
  }
}
