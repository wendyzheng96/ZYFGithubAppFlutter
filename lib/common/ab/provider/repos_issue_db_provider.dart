import 'package:flutter/foundation.dart';
import 'package:github_app_flutter/common/ab/sql_provider.dart';
import 'package:github_app_flutter/common/utils/code_utils.dart';
import 'package:github_app_flutter/model/Issue.dart';
import 'package:sqflite/sqflite.dart';

/// 仓库issue表
/// Create by zyf
/// Date: 2019/8/1
class ReposIssueDbProvider extends BaseDbProvider {
  final String name = 'ReposIssue';

  final String columnId = '_id';
  final String columnFullName = 'fullName';
  final String columnState = 'state';
  final String columnData = 'data';

  int id;
  String fullName;
  String state;
  String data;

  ReposIssueDbProvider();

  Map<String, dynamic> toMap(String fullName, String state, String data) {
    Map<String, dynamic> map = {
      columnFullName: fullName,
      columnState: state,
      columnData: data,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  ReposIssueDbProvider.fromMap(Map map) {
    id = map[columnId];
    fullName = map[columnFullName];
    state = map[columnState];
    data = map[columnData];
  }

  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
        '''
        $columnFullName text not null,
        $columnState text not null,
        $columnData text not null)
        ''';
  }

  @override
  tableName() {
    return name;
  }

  Future _getProvider(Database db, String fullName, String state) async {
    List<Map<String, dynamic>> maps = await db.query(name,
        columns: [columnId, columnFullName, columnData],
        where: "$columnFullName = ? and $columnState = ?",
        whereArgs: [fullName, state]);
    if (maps.length > 0) {
      ReposIssueDbProvider provider = ReposIssueDbProvider.fromMap(maps.first);
      return provider;
    }
    return null;
  }

  ///插入到数据库
  Future insert(String fullName, String state, String dataMapString) async {
    Database db = await getDataBase();
    var provider = await _getProvider(db, fullName, state);
    if (provider != null) {
      await db.delete(
        name,
        where: "$columnFullName = ? and $columnState = ?",
        whereArgs: [fullName, state],
      );
    }
    return await db.insert(name, toMap(fullName, state, dataMapString));
  }

  ///获取issue列表
  Future<List<Issue>> getIssues(String fullName, String state) async {
    Database db = await getDataBase();
    ReposIssueDbProvider provider = await _getProvider(db, fullName, state);
    if (provider != null) {
      List<Issue> list = List();

      var eventMap = await compute(CodeUtils.decodeListResult, provider.data);
      if (eventMap.length > 0) {
        for (var item in eventMap) {
          list.add(Issue.fromJson(item));
        }
      }
      return list;
    }
    return null;
  }
}
