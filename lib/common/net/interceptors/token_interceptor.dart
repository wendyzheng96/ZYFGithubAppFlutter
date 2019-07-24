import 'package:dio/dio.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/local/local_storage.dart';

/// Token 拦截器
/// Create by zyf
/// Date: 2019/7/23
class TokenInterceptors extends InterceptorsWrapper {
  String _token;

  @override
  onRequest(RequestOptions options) async {
    if(_token == null){
      var authorizationCode = await getAuthorization();
      if(authorizationCode != null) {
        _token = authorizationCode;
      }
    }
    options.headers["Authorization"] = _token;
    return options;
  }

  @override
  onResponse(Response response) async {
    try{
      var responseJson = response.data;
      if(response.statusCode == 201 && responseJson["token"]!=null) {
        _token= 'token ${responseJson["token"]}';
        await LocalStorage.save(Config.TOKEN, _token);
      }
    } catch(e){
      print(e);
    }
    return response;
  }

  getAuthorization() async {
    String token = await LocalStorage.get(Config.TOKEN);
    if(token == null) {
      String basic = await LocalStorage.get(Config.USER_BASIC_CODE);
      if(basic == null){
        print('请输入账号密码');
      } else {
        return 'Basic $basic';
      }
    } else {
      this._token = token;
      return token;
    }
  }

  clearAuthorization(){
    this._token = null;
    LocalStorage.remove(Config.TOKEN);
  }

}