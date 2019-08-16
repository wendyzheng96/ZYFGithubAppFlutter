import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:github_app_flutter/common/ab/provider/user_followed_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/user_follower_db_provider.dart';
import 'package:github_app_flutter/common/ab/provider/user_info_db_provider.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/dao_result.dart';
import 'package:github_app_flutter/common/local/local_storage.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/net/api.dart';
import 'package:github_app_flutter/common/redux/user_redux.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/model/Notification.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:redux/redux.dart';

/// 用户相关
/// Create by zyf
/// Date: 2019/7/23
class UserDao {
  ///登录
  static Future<DataResult> login(userName, password, store) async {
    String type = userName + ":" + password;
    var bytes = utf8.encode(type);
    var base64Str = base64.encode(bytes);
    if (Config.DEBUG) {
      print("base64Str login " + base64Str);
    }
    await LocalStorage.save(Config.USERNAME, userName);
    await LocalStorage.save(Config.USER_BASIC_CODE, base64Str);

    Map requestParams = {
      "scopes": ['user', 'repo', 'gist', 'notifications'],
      "note": "admin_script",
      "client_id": NetConfig.CLIENT_ID,
      "client_secret": NetConfig.CLIENT_SECRET
    };
    httpManager.clearAuthorization();

    var res = await httpManager.netFetch(Address.getAuthorization(),
        json.encode(requestParams), null, Options(method: "post"));
    var resultData;
    if (res != null && res.result) {
      await LocalStorage.save(Config.PWD, password);
      var resultData = await getUserInfo(null);
      if (Config.DEBUG) {
        print("user result " + resultData.result.toString());
        print(resultData.data);
        print(res.data.toString());
      }
      store.dispatch(UpdateUserAction(resultData.data));
    }
    return DataResult(resultData, res.result);
  }

  ///初始化用户信息
  static Future<DataResult> initUserInfo(Store store) async {
    var token = await LocalStorage.get(Config.TOKEN);
    var res = await getUserInfoLocal();
    if (res != null && res.result && token != null) {
      store.dispatch(UpdateUserAction(res.data));
    }

    bool isNight = await LocalStorage.get(Config.IS_NIGHT_THEME) ?? false;
    CommonUtils.switchNightOrDayTheme(store, isNight);
    return DataResult(res.data, (res.result && (token != null)));
  }

  ///获取本地登录用户信息
  static Future<DataResult> getUserInfoLocal() async {
    var userText = await LocalStorage.get(Config.USER_INFO);
    if (userText != null) {
      var userMap = json.decode(userText);
      User user = User.fromJson(userMap);
      return DataResult(user, true);
    } else
      return DataResult(null, false);
  }

  //获取用户详细信息
  static Future<DataResult> getUserInfo(username, {needDb = false}) async {
    UserInfoDbProvider provider = UserInfoDbProvider();
    next() async {
      var res;
      if (username == null) {
        res = await httpManager.netFetch(
            Address.getMyUserInfo(), null, null, null);
      } else {
        res = await httpManager.netFetch(
            Address.getUserInfo(username), null, null, null);
      }
      if (res != null && res.result) {
        String starred = "---";
        if (res.data["type"] != "organization") {
          var countRes = await getUserStaredCountNet(res.data["login"]);
          if (countRes.result) {
            starred = countRes.data;
          }
        }
        User user = User.fromJson(res.data);
        user.starred = starred;
        if (username == null) {
          LocalStorage.save(Config.USER_INFO, json.encode(user.toJson()));
        } else {
          if (needDb) {
            provider.insert(username, json.encode(user.toJson()));
          }
        }
        return DataResult(user, true);
      } else {
        return DataResult(res.data, false);
      }
    }

    if (needDb) {
      User user = await provider.getUserInfo(username);
      if (user == null) {
        return await next();
      }
      DataResult dataResult = DataResult(user, true, next: next);
      return dataResult;
    }
    return await next();
  }

  //获取star数目
  static Future<DataResult> getUserStaredCountNet(username) async {
    String url = Address.userStar(username, null) + "&per_page=1";
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result && res.headers != null) {
      try {
        List<String> link = res.headers['link'];
        if (link != null) {
          int indexStart = link[0].lastIndexOf("page=") + 5;
          int indexEnd = link[0].lastIndexOf(">");
          if (indexStart >= 0 && indexEnd >= 0) {
            String count = link[0].substring(indexStart, indexEnd);
            return DataResult(count, true);
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return DataResult(null, false);
  }

  /// 获取用户关注列表
  static getFollowedList(username, page, {needDb = false}) async {
    UserFollowedDbProvider provider = new UserFollowedDbProvider();
    next() async {
      String url =
          Address.getUserFollowed(username) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<User> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(new User.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(username, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.getFollowedList(username);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 获取用户粉丝列表
  static getFollowerList(username, page, {needDb = false}) async {
    UserFollowerDbProvider provider = UserFollowerDbProvider();

    next() async {
      String url =
          Address.getUserFollower(username) + Address.getPageParams("?", page);
      var res = await httpManager.netFetch(url, null, null, null);
      if (res != null && res.result) {
        List<User> list = new List();
        var data = res.data;
        if (data == null || data.length == 0) {
          return DataResult(list, true);
        }
        for (int i = 0; i < data.length; i++) {
          list.add(User.fromJson(data[i]));
        }
        if (needDb) {
          provider.insert(username, json.encode(data));
        }
        return DataResult(list, true);
      } else {
        return DataResult(null, false);
      }
    }

    if (needDb) {
      List<User> list = await provider.getFollowerList(username);
      if (list == null) {
        return await next();
      }
      DataResult dataResult = DataResult(list, true, next: next);
      return dataResult;
    }
    return await next();
  }

  /// 组织成员
  static getMemberDao(username, page) async {
    String url = Address.getMember(username) + Address.getPageParams("?", page);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<User> list = new List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return DataResult(list, true);
      }
      for (int i = 0; i < data.length; i++) {
        list.add(new User.fromJson(data[i]));
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  ///获取用户相关通知
  static getNotify(bool all, bool participating, page) async {
    String tag = (!all && !participating) ? '?' : '&';
    String url = Address.getNotification(all, participating) +
        Address.getPageParams(tag, page);
    var res = await httpManager.netFetch(url, null, null, null);
    if (res != null && res.result) {
      List<Notification> list = List();
      var data = res.data;
      if (data == null || data.length == 0) {
        return DataResult(list, true);
      }
      for (int i = 0; i < data.length; i++) {
        list.add(Notification.fromJson(data[i]));
      }
      return DataResult(list, true);
    } else {
      return DataResult(null, false);
    }
  }

  /// 设置单个通知已读
  static setNotificationAsRead(id) async {
    String url = Address.setNotificationAsRead(id);
    var res = await httpManager
        .netFetch(url, null, null, Options(method: "PATCH"), noTip: true);
    return res;
  }

  /// 设置所有通知已读
  static setAllNotificationAsRead() async {
    String url = Address.setAllNotificationAsRead();
    var res = await httpManager.netFetch(
        url, null, null, Options(method: "PUT", contentType: ContentType.text));
    return DataResult(res.data, res.result);
  }

  ///清除用户信息
  static clearAll(Store store) async {
    httpManager.clearAuthorization();
    LocalStorage.remove(Config.USER_INFO);
    store.dispatch(UpdateUserAction(User.empty()));
  }
}
