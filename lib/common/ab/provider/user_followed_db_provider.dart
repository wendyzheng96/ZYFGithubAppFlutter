import 'package:flutter/foundation.dart';
import 'package:github_app_flutter/common/ab/sql_provider.dart';
import 'package:github_app_flutter/common/utils/code_utils.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:sqflite/sqflite.dart';

/// 用户关注表
/// Create by zyf
/// Date: 2019/8/5
class UserFollowedDbProvider extends BaseDbProvider {
  final String name = 'UserFollowed';

  final String columnId = "_id";
  final String columnUsername = "username";
  final String columnData = "data";

  int id;
  String username;
  String data;

  UserFollowedDbProvider();

  Map<String, dynamic> toMap(String userName, String data) {
    Map<String, dynamic> map = {columnUsername: userName, columnData: data};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  UserFollowedDbProvider.fromMap(Map map) {
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

  Future _getProvider(Database db, String userName) async {
    List<Map<String, dynamic>> maps = await db.query(
      name,
      columns: [columnId, columnUsername, columnData],
      where: "$columnUsername = ?",
      whereArgs: [userName],
    );
    if (maps.length > 0) {
      UserFollowedDbProvider provider =
          UserFollowedDbProvider.fromMap(maps.first);
      return provider;
    }
    return null;
  }

  ///插入到数据库
  Future insert(String userName, String dataMapString) async {
    Database db = await getDataBase();
    var provider = await _getProvider(db, userName);
    if (provider != null) {
      await db.delete(
        name,
        where: "$columnUsername = ?",
        whereArgs: [userName],
      );
    }
    return await db.insert(name, toMap(userName, dataMapString));
  }

  ///获取关注人列表
  Future<List<User>> getFollowedList(String userName) async {
    Database db = await getDataBase();

    UserFollowedDbProvider provider = await _getProvider(db, userName);
    if (provider != null) {
      List<User> list = List();

      ///使用 compute 的 Isolate 优化 json decode
      List<dynamic> eventMap =
          await compute(CodeUtils.decodeListResult, provider.data);

      if (eventMap.length > 0) {
        for (var item in eventMap) {
          list.add(User.fromJson(item));
        }
      }
      return list;
    }
    return null;
  }
}
