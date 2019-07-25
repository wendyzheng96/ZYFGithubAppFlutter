import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
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
      List<TrendingRepoModel> dbList = await provider.getRepos(languageTypeDb, since);
      if (dbList == null || dbList.length == 0) {
        return await next();
      }
      DataResult dataResult = DataResult(dbList, true, next: next);
      return dataResult;
    }
    return await next();
  }
}
