import 'package:github_app_flutter/common/ab/sql_provider.dart';
import 'package:sqflite/sqflite.dart';

/// 仓库readme文件表
/// Create by zyf
/// Date: 2019/7/29
class ReposReadmeDbProvider extends BaseDbProvider {
  final String name = 'ReposReadme';

  final String columnId = '_id';
  final String columnFullName = 'fullName';
  final String columnBranch = 'branch';
  final String columnData = 'data';

  int id;
  String fullName;
  String branch;
  String data;

  ReposReadmeDbProvider();

  Map<String, dynamic> toMap(String fullName, String branch, String data) {
    Map<String, dynamic> map = {
      columnFullName: fullName,
      columnBranch: branch,
      columnData: data
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  ReposReadmeDbProvider.fromMap(Map map) {
    id = map[columnId];
    fullName = map[columnFullName];
    branch = map[columnBranch];
    data = map[columnData];
  }

  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
        '''
        $columnFullName text not null,
        $columnBranch text not null,
        $columnData text not null)
      ''';
  }

  @override
  tableName() {
    return name;
  }

  Future _getProvider(Database db, String fullName, String branch) async {
    List<Map<String, dynamic>> maps = await db.query(name,
        columns: [columnId, columnFullName, columnBranch, columnData],
        where: "$columnFullName = ? and $columnBranch = ?",
        whereArgs: [fullName, branch]);
    if (maps.length > 0) {
      ReposReadmeDbProvider provider =
          ReposReadmeDbProvider.fromMap(maps.first);
      return provider;
    }
    return null;
  }

  ///插入到数据库
  Future insert(String fullName, String branch, String dataMapString) async {
    Database db = await getDataBase();
    var provider = await _getProvider(db, fullName, branch);
    if (provider != null) {
      await db.delete(name,
          where: "$columnFullName = ? and $columnBranch",
          whereArgs: [fullName, branch]);
    }
    return await db.insert(name, toMap(fullName, branch, dataMapString));
  }

  ///获取readme详情
  Future<String> getReposReadme(String fullName, String branch) async {
    Database db = await getDataBase();
    ReposReadmeDbProvider provider = await _getProvider(db, fullName, branch);
    if (provider != null){
      return provider.data;
    }
    return null;
  }
}
