
/// 地址数据
/// Create by zyf
/// Date: 2019/7/23
class Address {
  static const String host = "https://api.github.com/";
  static const String hostWeb = "https://github.com/";
  static const String graphicHost = 'https://ghchart.rshah.org/';
  static const String updateUrl = 'https://www.pgyer.com/vj2B';

  ///获取授权 post
  static getAuthorization() {
    return "${host}authorizations";
  }

  ///我的用户信息 get
  static getMyUserInfo() {
    return "${host}user";
  }

  ///获取用户信息 get
  static getUserInfo(username) {
    return "${host}users/$username";
  }

  ///获取用户的star get
  static userStar(userName, sort) {
    sort ??= 'updated';
    return "${host}users/$userName/starred?sort=$sort";
  }
}