import 'dart:convert';

import 'package:github_app_flutter/common/ab/provider/received_event_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/user_event_db_provider.dart';
import 'package:github_app_flutter/common/dao/dao_result.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/net/api.dart';
import 'package:github_app_flutter/model/Event.dart';

/// 事件相关
/// Create by zyf
/// Date: 2019/7/24
class EventDao {
  ///获取用户关注接收信息
  static Future<DataResult> getEventReceived(String username,
      {page = 1, bool needDb = false}) async {
    if (username == null) {
      return null;
    }
    ReceivedEventDbProvider provider = ReceivedEventDbProvider();

    next() async {
      String url =
          Address.getEventReceived(username) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<Event> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        if (needDb) {
          provider.insert(json.encode(data));
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Event.fromJson(data[i]));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Event> dbList = await provider.getEvents();
      if (dbList == null || dbList.length == 0) {
        return await next();
      }
      DataResult dataResult = DataResult(dbList, true, next: next);
      return dataResult;
    }
    return await next();
  }

  ///获取用户行为列表
  static Future<DataResult> getEventDao(String username,
      {page = 0, bool needDb = false}) async {
    UserEventDbProvider provider = UserEventDbProvider();
    next() async {
      String url =
          Address.getEvent(username) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<Event> list = List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        if (needDb) {
          provider.insert(username, json.encode(data));
        }
        for (int i = 0; i < data.length; i++) {
          list.add(Event.fromJson(data[i]));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<Event> dbList = await provider.getEvents(username);
      if (dbList == null || dbList.length == 0) {
        return await next();
      }
      DataResult dataResult = DataResult(dbList, true, next: next);
      return dataResult;
    }
    return await next();
  }
}
