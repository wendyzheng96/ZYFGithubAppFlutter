import 'package:shared_preferences/shared_preferences.dart';

/// SharePreferences本地存储
/// Create by zyf
/// Date: 2019/7/15
class LocalStorage {

  static save(String key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(value is int) {
      prefs.setInt(key, value);
    } else if(value is bool){
      prefs.setBool(key, value);
    } else {
      prefs.setString(key, value);
    }
  }

  static get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  static remove(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
