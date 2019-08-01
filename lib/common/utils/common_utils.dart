import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// 通用工具方法
/// Create by zyf
/// Date: 2019/7/16
class CommonUtils {
  ///获取用户头像地址
  static String getUserChartUrl(String username) {
    return Address.graphicHost +
        ZColors.primaryValueString.replaceAll("#", "") +
        "/" +
        username;
  }

  ///toast提示
  static void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIos: 1,
      backgroundColor: Color(0x99000000),
    );
  }

  static launchOutURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: "url异常 : $url");
    }
  }

  static copy(String data, BuildContext context) {
    Clipboard.setData(new ClipboardData(text: data));
    Fluttertoast.showToast(msg: '已经复制到粘贴板');
  }

  ///显示加载中进度框
  static Future<Null> showLoadingDialog(BuildContext context) {
    return NavigatorUtils.showAppDialog(
        context: context,
        builder: (BuildContext context) {
          return Material(
            color: Colors.transparent,
            child: WillPopScope(
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: SpinKitCircle(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          '加载中...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              onWillPop: () => Future.value(false),
            ),
          );
        });
  }

  static const IMAGE_END = [".png", ".jpg", ".jpeg", ".gif", ".svg"];

  static isImageEnd(path) {
    bool image = false;
    for (String item in IMAGE_END) {
      if (path.indexOf(item) + item.length == path.length) {
        image = true;
      }
    }
    return image;
  }

  static Color getLanguageColor(String type) {
    switch (type) {
      case 'Assembly':
        return Color(0xff586069);
      case 'C':
        return Color(0xff555555);
      case 'C#':
        return Color(0xff178600);
      case 'C++':
        return Color(0xfff34b7d);
      case 'Clojure':
        return Color(0xffdb5855);
      case 'CSS':
        return Color(0xff563d7c);
      case 'CoffeeScript':
        return Color(0xff244776);
      case 'Dart':
        return Color(0xff00b4ab);
      case 'Elixir':
        return Color(0xff6e4a7e);
      case 'Go':
        return Color(0xfd00add8);
      case 'Haskell':
        return Color(0xff5e5086);
      case 'HTML':
        return Color(0xffe34c26);
      case 'Java':
        return Color(0xffb07219);
      case 'JavaScript':
        return Color(0xfff1e05a);
      case 'Jupyter Notebook':
        return Color(0xffda5b0b);
      case 'Kotlin':
        return Color(0xfff18e33);
      case 'Lua':
        return Color(0xff000080);
      case 'Makefile':
        return Color(0xff427819);
      case 'Objective-C':
        return Color(0xff438eff);
      case 'Perl':
        return Color(0xff0298c3);
      case 'PHP':
        return Color(0xff4f5d95);
      case 'Python':
        return Color(0xff3572a5);
      case 'Ruby':
        return Color(0xff701514);
      case 'Rust':
        return Color(0xffdea584);
      case 'Scala':
        return Color(0xffc22d40);
      case 'Shell':
        return Color(0xff89e051);
      case 'Swift':
        return Color(0xffffac45);
      case 'TypeScript':
        return Color(0xff2b7489);
      case 'Vim script':
        return Color(0xff199f4b);
      case 'Vue':
        return Color(0xff2c3e50);
      default:
        return Colors.transparent;
    }
  }

}

