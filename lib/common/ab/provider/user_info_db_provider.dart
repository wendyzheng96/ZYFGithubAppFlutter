import 'package:flutter/foundation.dart';
import 'package:github_app_flutter/common/ab/sql_provider.dart';
import 'package:github_app_flutter/common/utils/code_utils.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:sqflite/sqflite.dart';

/// 用户信息表
/// Create by zyf
/// Date: 2019/7/23
class UserInfoDbProvider extends BaseDbProvider {
  final String name = 'UserInfo';

  final String columnId = '_id';
  final String columnUsername = 'username';
  final String columnData = 'data';

  int id;
  String username;
  String data;

  UserInfoDbProvider();

  UserInfoDbProvider.fromMap(Map map) {
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

  Future _getUserProvider(Database db, String username) async {
    List<Map<String, dynamic>> maps = await db.query(name,
        columns: [columnId, columnUsername, columnData],
        where: "$columnUsername = ?",
        whereArgs: [username]);
    if (maps.length > 0) {
      UserInfoDbProvider provider = UserInfoDbProvider.fromMap(maps.first);
      return provider;
    }
    return null;
  }

  ///插入到数据库
  Future insert(String username, String eventMapString) async {
    Database db = await getDataBase();
    var userProvider = await _getUserProvider(db, username);
    if (userProvider != null) {
      await db
          .delete(name, where: "$columnUsername = ?", whereArgs: [username]);
    }
    return db.insert(name, toMap(username, eventMapString));
  }

  ///从数据库中获取用户信息
  Future<User> getUserInfo(String username) async {
    Database db = await getDataBase();
    var userProvider = await _getUserProvider(db, username);
    if (userProvider != null) {
      ///使用 compute 的 Isolate 优化 json decode
      var mapData =
          await compute(CodeUtils.decodeMapResult, userProvider.data as String);
      return User.fromJson(mapData);
    }
    return null;
  }

  Map<String, dynamic> toMap(String username, String data) {
    Map<String, dynamic> map = {columnUsername: username, columnData: data};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}
