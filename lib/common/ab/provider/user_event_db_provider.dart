import 'package:flutter/foundation.dart';
import 'package:github_app_flutter/common/ab/sql_provider.dart';
import 'package:github_app_flutter/common/utils/code_utils.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:sqflite/sqflite.dart';

/// 用户动态表
/// Create by zyf
/// Date: 2019/7/24
class UserEventDbProvider extends BaseDbProvider {

  final String name = 'UserEvent';

  final String columnId = '_id';
  final String columnUsername = 'username';
  final String columnData = 'data';

  int id;
  String username;
  String data;

  UserEventDbProvider();

  Map<String, dynamic> toMap(String username, String data) {
    Map<String, dynamic> map = {columnUsername: username, columnData: data};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  UserEventDbProvider.fromMap(Map map) {
    id = map[columnId];
    username = map[columnUsername];
    data = map[columnData];
  }

  @override
  tableSqlString() {
    return tableBaseString(name, columnId) +
        '''
        $columnUsername text not null,
        $columnData text not null)
        ''';
  }

  @override
  tableName() {
    return name;
  }

  Future _getProvider(Database db, String username) async {
    List<Map<String, dynamic>> maps = await db.query(name,
        columns: [columnId, columnUsername, columnData],
        where: "$columnUsername = ?",
        whereArgs: [username]);
    if (maps.length > 0) {
      UserEventDbProvider provider = UserEventDbProvider.fromMap(maps.first);
      return provider;
    }
    return null;
  }

  ///插入到数据库
  Future insert(String username, String eventMapString) async {
    Database db = await getDataBase();
    var provider = await _getProvider(db, username);
    if (provider != null) {
      await db
          .delete(name, where: "$columnUsername = ?", whereArgs: [username]);
    }
    return await db.insert(name, toMap(username, eventMapString));
  }

  ///从数据库中获取用户信息
  Future<List<Event>> getEvents(String username) async {
    Database db = await getDataBase();
    var provider = await _getProvider(db, username);
    if (provider != null) {
      List<Event> list = List();

      ///使用 compute 的 Isolate 优化 json decode
      List<dynamic> eventMap =
        await compute(CodeUtils.decodeListResult, provider.data as String);

      if(eventMap.length>0){
        for(var item in eventMap){
          list.add(Event.fromJson(item));
        }
      }
      return list;
    }
    return null;
  }

}