import 'package:github_app_flutter/common/ab/sql_provider.dart';
import 'package:sqflite/sqflite.dart';

/// 搜索历史表
/// Create by zyf
/// Date: 2019/8/8
class SearchHistoryDbProvider extends BaseDbProvider {
  final String name = 'SearchHistory';

  final String columnId = '_id';
  final String columnData = 'data';

  int id;
  String data;

  SearchHistoryDbProvider();

  Map<String, dynamic> toMap(String data) {
    Map<String, dynamic> map = {columnData: data};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  SearchHistoryDbProvider.fromMap(Map map) {
    id = map[columnId];
    data = map[columnData];
  }

  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
        '''
        $columnData text not null)
      ''';
  }

  @override
  tableName() {
    return name;
  }

  Future _getProvider(Database db) async {
    List<Map<String, dynamic>> maps = await db.query(
      name,
      columns: [columnId, columnData],
    );
    if (maps.length > 0) {
      SearchHistoryDbProvider provider =
          SearchHistoryDbProvider.fromMap(maps.first);
      return provider;
    }
    return null;
  }

  ///插入到数据库
  Future insert(String searchKey) async {
    Database db = await getDataBase();
    var provider = await _getProvider(db);
    if (provider != null) {
      await db.delete(name, where: "$columnData = ?", whereArgs: [searchKey]);
    }
    return await db.insert(name, toMap(searchKey));
  }

  ///获取搜索历史
  Future<List<String>> getSearchHistory() async {
    Database db = await getDataBase();
    List<Map<String, dynamic>> maps = await db.query(
      name,
      columns: [columnId, columnData],
    );

    List<String> list = new List();
    if (maps != null && maps.length > 0) {
      for (int i = maps.length - 1; i >= 0; i--) {
        list.add(maps[i][columnData]);
      }
    }
    return list;
  }

  Future deleteByKey(String searchKey) async{
    Database db = await getDataBase();
    await db.delete(name, where: "$columnData = ?", whereArgs: [searchKey]);
  }

  Future clearHistory() async {
    Database db = await getDataBase();
    ///清空历史数据
    db.execute("delete from $name");
  }
}
