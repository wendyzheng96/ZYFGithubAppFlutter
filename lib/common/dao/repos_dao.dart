import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:github_app_flutter/common/ab/provider/repos_readme_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/trend_repository_db_provider.dart';
import 'package:github_app_flutter/common/dao/dao_result.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/net/api.dart';
import 'package:github_app_flutter/common/utils/trend_utils.dart';
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
  static Future<DataResult> getReposReadme(String username, String reposName, String branch,
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
}
