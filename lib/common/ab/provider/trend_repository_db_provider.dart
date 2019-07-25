import 'package:flutter/foundation.dart';
import 'package:github_app_flutter/common/ab/sql_provider.dart';
import 'package:github_app_flutter/common/utils/code_utils.dart';
import 'package:github_app_flutter/model/TrendingRepoModel.dart';
import 'package:sqflite/sqflite.dart';

/// 趋势表
/// Create by zyf
/// Date: 2019/7/25
class TrendRepositoryDbProvider extends BaseDbProvider {
  final String name = 'TrendRepository';

  final String columnId = "_id";
  final String columnLanguageType = 'languageType';
  final String columnSince = 'since';
  final String columnData = "data";

  int id;
  String languageType;
  String since;
  String data;

  TrendRepositoryDbProvider();

  Map<String, dynamic> toMap(
      String languageType, String since, String eventMapString) {
    Map<String, dynamic> map = {
      columnLanguageType: languageType,
      columnSince: since,
      columnData: eventMapString
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  TrendRepositoryDbProvider.fromMap(Map map) {
    id = map[columnId];
    languageType = map[columnLanguageType];
    since = map[columnSince];
    data = map[columnData];
  }

  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
        '''
        $columnLanguageType text not null,
        $columnSince text not null,
        $columnData text not null)
      ''';
  }

  @override
  tableName() {
    return name;
  }

  ///插入到数据库
  Future insert(String language, String since, String eventMapString) async {
    Database db = await getDataBase();

    ///清空后再插入，因为只保存第一页面
    db.execute("delete from $name");
    return await db.insert(name, toMap(language, since, eventMapString));
  }

  ///获取事件数据
  Future<List<TrendingRepoModel>> getRepos(String language, String since) async {
    Database db = await getDataBase();
    List<Map> maps = await db.query(name,
      columns: [columnId, columnLanguageType, columnSince, columnData],
      where: "$columnLanguageType = ? and $columnSince = ?",
      whereArgs: [language, since],
    );
    List<TrendingRepoModel> list = List();
    if (maps.length > 0) {
      TrendRepositoryDbProvider provider =
          TrendRepositoryDbProvider.fromMap(maps.first);

      ///使用 compute 的 Isolate 优化 json decode
      List<dynamic> eventMap =
          await compute(CodeUtils.decodeListResult, provider.data);

      if (eventMap.length > 0) {
        for (var item in eventMap) {
          list.add(TrendingRepoModel.fromJson(item));
        }
      }
    }
    return list;
  }
}
