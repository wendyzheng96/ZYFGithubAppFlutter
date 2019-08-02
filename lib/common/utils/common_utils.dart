import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/style/style.dart';
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

  ///跳转外部链接
  static launchOutURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: "url异常 : $url");
    }
  }

  ///复制文字
  static copy(String data, BuildContext context) {
    Clipboard.setData(new ClipboardData(text: data));
    Fluttertoast.showToast(msg: '已经复制到粘贴板');
  }

  static const IMAGE_END = [".png", ".jpg", ".jpeg", ".gif", ".svg"];

  ///判断是否是图片格式
  static isImageEnd(path) {
    bool image = false;
    for (String item in IMAGE_END) {
      if (path.indexOf(item) + item.length == path.length) {
        image = true;
      }
    }
    return image;
  }

  ///获取全名
  static getFullName(String repositoryUrl) {
    if (repositoryUrl != null &&
        repositoryUrl.substring(repositoryUrl.length - 1) == "/") {
      repositoryUrl = repositoryUrl.substring(0, repositoryUrl.length - 1);
    }
    String fullName = '';
    if (repositoryUrl != null) {
      List<String> splitUrl = repositoryUrl.split("/");
      if (splitUrl.length > 2) {
        fullName =
            splitUrl[splitUrl.length - 2] + "/" + splitUrl[splitUrl.length - 1];
      }
    }
    return fullName;
  }

  ///获取语言对应颜色
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

