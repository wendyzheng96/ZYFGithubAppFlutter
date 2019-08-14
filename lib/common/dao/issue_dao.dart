import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:github_app_flutter/common/ab/provider/issue_comment_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/issue_detail_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/repos_issue_db_provider.dart';
import 'package:github_app_flutter/common/dao/dao_result.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/net/api.dart';
import 'package:github_app_flutter/model/Issue.dart';

/// issue相关
/// Create by zyf
/// Date: 2019/8/1
class IssueDao {
  /// 获取仓库issue
  /// @param page
  /// @param userName
  /// @param repository
  /// @param state issue状态
  /// @param sort 排序类型 created updated等
  /// @param direction 正序或者倒序
  static Future<DataResult> getReposIssues(username, repository, state,
      {sort, direction, page = 0, needDb = false}) async {
    String fullName = username + "/" + repository;
    String dbState = state ?? "*";
    ReposIssueDbProvider provider = new ReposIssueDbProvider();

    next() async {
      String url =
          Address.getReposIssue(username, repository, state, sort, direction) +
              Address.getPageParams("&", page);
      var res = await httpManager.netFetch(
          url,
          null,
          {
            "Accept":
                'application/vnd.github.html,application/vnd.github.VERSION.raw'
          },
          null);
      if (res != null && res.result) {
        List<Issue> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Issue.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(fullName, dbState, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Issue> list = await provider.getIssues(fullName, dbState);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 搜索仓库issue
  /// @param q 搜索关键字
  /// @param name 用户名
  /// @param reposName 仓库名
  /// @param page
  /// @param state 问题状态，all open closed
  static Future<DataResult> searchReposIssue(q, name, reposName, state,
      {page = 1}) async {
    String qu;
    if (state == null || state == 'all') {
      qu = q + "+repo%3A$name%2F$reposName";
    } else {
      qu = q + "+repo%3A$name%2F$reposName+state%3A$state";
    }
    String url =
        Address.reposIssueSearch(qu) + Address.getPageParams("&", page);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<Issue> list = new List();
      var data = res.data["items"];
      if (data == null || data.length == 0) {
        return DataResult(list, true);
      }
      for (int i = 0; i < data.length; i++) {
        list.add(Issue.fromJson(data[i]));
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// issue的详请
  static Future<DataResult> getIssueDetail(username, repository, number,
      {needDb = false}) async {
    String fullName = username + "/" + repository;
    IssueDetailDbProvider provider = IssueDetailDbProvider();

    next() async {
      String url = Address.getIssueInfo(username, repository, number);
      var res = await httpManager.netFetch(
          url, null, {"Accept": 'application/vnd.github.VERSION.raw'}, null);
      if (res != null && res.result) {
        if (needDb) {
          provider.insert(fullName, number, json.encode(res.data));
        }
        return DataResult(Issue.fromJson(res.data), true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      Issue issue = await provider.getIssueDetail(fullName, number);
      if (issue == null) {
        return await next();
      }
      DataResult dataResult = DataResult(issue, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// issue评论列表
  static getIssueComments(username, repository, number,
      {page: 0, needDb = false}) async {
    String fullName = username + "/" + repository;
    IssueCommentDbProvider provider = new IssueCommentDbProvider();

    next() async {
      String url = Address.getIssueComment(username, repository, number) +
          Address.getPageParams("?", page);
      var res = await httpManager.netFetch(
          url, null, {"Accept": 'application/vnd.github.VERSION.raw'}, null);
      if (res != null && res.result) {
        List<Issue> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        if (needDb) {
          provider.insert(fullName, number, json.encode(res.data));
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Issue.fromJson(data[i]));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Issue> list = await provider.getData(fullName, number);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  ///创建issue
  static createIssue(username, reposName, issue) async {
    String url = Address.createIssue(username, reposName);
    var res = await httpManager.netFetch(
        url,
        issue,
        {"Accept": 'application/vnd.github.VERSION.full+json'},
        Options(method: 'POST'));
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// 回复issue
  static addIssueComment(username, reposName, number, comment) async {
    String url = Address.addIssueComment(username, reposName, number);
    var res = await httpManager.netFetch(
        url,
        {"body": comment},
        {"Accept": 'application/vnd.github.VERSION.full+json'},
        Options(method: 'POST'));
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// 编辑issue
  static editIssue(username, reposName, number, issue) async {
    String url = Address.editIssue(username, reposName, number);
    var res = await httpManager.netFetch(
        url,
        issue,
        {"Accept": 'application/vnd.github.VERSION.full+json'},
        Options(method: 'PATCH'));
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// 锁定issue
  static lockIssue(username, reposName, number, locked) async {
    String url = Address.lockIssue(username, reposName, number);
    var res = await httpManager.netFetch(
        url,
        null,
        {"Accept": 'application/vnd.github.VERSION.full+json'},
        Options(
            method: locked ? "DELETE" : 'PUT', contentType: ContentType.text),
        noTip: true);
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// 编辑issue回复
  static editComment(username, reposName, number, commentId, comment) async {
    String url = Address.editComment(username, reposName, commentId);
    var res = await httpManager.netFetch(
        url,
        comment,
        {"Accept": 'application/vnd.github.VERSION.full+json'},
        new Options(method: 'PATCH'));
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// 删除issue回复
  static deleteComment(username, reposName, number, commentId) async {
    String url = Address.editComment(username, reposName, commentId);
    var res = await httpManager
        .netFetch(url, null, null, new Options(method: 'DELETE'), noTip: true);
    if (res != null && res.result) {
      return DataResult(res.data, true);
    } else {
      return DataResult(null, false);
    }
  }
}
