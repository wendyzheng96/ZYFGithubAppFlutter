import 'dart:convert';

import 'package:github_app_flutter/common/ab/provider/user_event_db_provider.dart';
import 'package:github_app_flutter/common/dao/dao_result.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/net/api.dart';
import 'package:github_app_flutter/model/event.dart';

/// 事件相关
/// Create by zyf
/// Date: 2019/7/24
class EventDao {
  static Future<DataResult> getEventDao(String username, {page = 0, bool needDb = false}) async {
    UserEventDbProvider provider = UserEventDbProvider();
    next() async {
      String url =
          Address.getEvent(username) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if(res != null && res.result){
        List<Event> list = List();
        var data = res.data;
        if(data == null || data.length == 0){
          return DataResult(list, true);
        }
        if(needDb){
          provider.insert(username, json.encode(data));
        }
        for(int i = 0; i< data.length;i++){
          list.add(Event.fromJson(data[i]));
        }
        return DataResult(list, true);
      } else {
        return null;
      }
    }

    if(needDb){
      List<Event> dbList = await provider.getEvents(username);
      if(dbList == null || dbList.length == 0){
        return await next();
      }
      DataResult dataResult = DataResult(dbList, true, next: next);
      return dataResult;
    }
    return await next();
  }
}
