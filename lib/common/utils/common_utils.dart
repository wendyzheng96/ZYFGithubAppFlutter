import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/local/local_storage.dart';
import 'package:github_app_flutter/common/net/address.dart';
import 'package:github_app_flutter/common/redux/theme_redux.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:redux/redux.dart';

/// 通用工具方法
/// Create by zyf
/// Date: 2019/7/16
class CommonUtils {
  ///获取用户头像地址
  static String getUserChartUrl(String username, Color color) {
    String colorValue =
        color.value.toRadixString(16).padLeft(8, '0').substring(2);
    return Address.graphicHost + colorValue + "/" + username;
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

  ///复制文字
  static copy(String data, BuildContext context) {
    Clipboard.setData(new ClipboardData(text: data));
    showToast('已经复制到粘贴板');
  }

  ///跳转外部链接
  static launchOutURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToast("url异常 : $url");
    }
  }

  static launchUrl(context, String url) {
    if (url == null && url.length == 0) return;
    Uri parseUrl = Uri.parse(url);
    bool isImage = isImageEnd(parseUrl.toString());
    if (parseUrl.toString().endsWith("?raw=true")) {
      isImage = isImageEnd(parseUrl.toString().replaceAll("?raw=true", ""));
    }
    if (isImage) {
      NavigatorUtils.gotoPhotoPage(context, url);
      return;
    }

    if (parseUrl != null &&
        parseUrl.host == "github.com" &&
        parseUrl.path.length > 0) {
      List<String> pathNames = parseUrl.path.split("/");
      if (pathNames.length == 2) {
        //解析人
        String userName = pathNames[1];
        NavigatorUtils.goPersonPage(context, userName);
      } else if (pathNames.length >= 3) {
        String userName = pathNames[1];
        String repoName = pathNames[2];
        //解析仓库
        if (pathNames.length == 3) {
          NavigatorUtils.goReposDetail(context, userName, repoName);
        } else {
          NavigatorUtils.launchWebView(context, "", url);
        }
      }
    } else if (url != null && url.startsWith("http")) {
      NavigatorUtils.launchWebView(context, "", url);
    }
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

  static switchNightOrDayTheme(Store store, bool isToNight) async {
    int themeIndex = await LocalStorage.get(Config.THEME_COLOR) ?? 0;

    if (isToNight) {
      ///夜间模式
      ThemeData nightTheme = ThemeData(
        brightness: Brightness.dark,
        primarySwatch: getThemeListColor()[themeIndex],
      );
      store.dispatch(RefreshThemeDataAction(nightTheme));
    } else {
      ///日间模式
      CommonUtils.pushTheme(store, themeIndex);
    }
  }

  static pushTheme(Store store, int index) {
    List<Color> colors = getThemeListColor();
    ThemeData themeData = getThemeData(colors[index]);
    store.dispatch(RefreshThemeDataAction(themeData));
  }

  static getThemeData(Color color) {
    return ThemeData(primarySwatch: color, platform: TargetPlatform.android);
  }

  static List<Color> getThemeListColor() {
    MaterialColor blackTheme = MaterialColor(
      0xFF24292E,
      const <int, Color>{
        50: const Color(0xFF42464b),
        100: const Color(0xFF42464b),
        200: const Color(0xFF42464b),
        300: const Color(0xFF42464b),
        400: const Color(0xFF42464b),
        500: const Color(0xFF24292E),
        600: const Color(0xFF121917),
        700: const Color(0xFF121917),
        800: const Color(0xFF121917),
        900: const Color(0xFF121917),
      },
    );

    ///赤红
    MaterialColor crimson = MaterialColor(
      0xFFCA4549,
      const <int, Color>{
        50: Color(0xFFCA4549),
        100: const Color(0xFFCA4549),
        200: const Color(0xFFCA4549),
        300: const Color(0xFFCA4549),
        400: const Color(0xFFCA4549),
        500: const Color(0xFFCA4549),
        600: const Color(0xFFCA4549),
        700: const Color(0xFFCA4549),
        800: const Color(0xFFCA4549),
        900: const Color(0xFFCA4549),
      },
    );

    ///雀茶
    MaterialColor sparrowTea = MaterialColor(
      0xFFCA503E,
      const <int, Color>{
        50: Color(0xFFCA503E),
        100: const Color(0xFFCA503E),
        200: const Color(0xFFCA503E),
        300: const Color(0xFFCA503E),
        400: const Color(0xFFCA503E),
        500: const Color(0xFFCA503E),
        600: const Color(0xFFCA503E),
        700: const Color(0xFFCA503E),
        800: const Color(0xFFCA503E),
        900: const Color(0xFFCA503E),
      },
    );

    ///甚三红
    MaterialColor pink = MaterialColor(
      0xFFE77A79,
      const <int, Color>{
        50: Color(0xFFF3C2CA),
        100: const Color(0xFFF3C2CA),
        200: const Color(0xFFF3C2CA),
        300: const Color(0xFFF3C2CA),
        400: const Color(0xFFF3C2CA),
        500: const Color(0xFFE77A79),
        600: const Color(0xFFE77A79),
        700: const Color(0xFFE77A79),
        800: const Color(0xFFCA4549),
        900: const Color(0xFFCA4549),
      },
    );

    ///千草
    MaterialColor chigusa = MaterialColor(
      0xFF4290B3,
      const <int, Color>{
        50: Color(0xFF4290B3),
        100: const Color(0xFF4290B3),
        200: const Color(0xFF4290B3),
        300: const Color(0xFF4290B3),
        400: const Color(0xFF4290B3),
        500: const Color(0xFF4290B3),
        600: const Color(0xFF4290B3),
        700: const Color(0xFF4290B3),
        800: const Color(0xFF4290B3),
        900: const Color(0xFF4290B3),
      },
    );

    ///铜绿
    MaterialColor copperGreen = MaterialColor(
      0xFF549688,
      const <int, Color>{
        50: Color(0xFF549688),
        100: const Color(0xFF549688),
        200: const Color(0xFF549688),
        300: const Color(0xFF549688),
        400: const Color(0xFF549688),
        500: const Color(0xFF549688),
        600: const Color(0xFF549688),
        700: const Color(0xFF549688),
        800: const Color(0xFF549688),
        900: const Color(0xFF549688),
      },
    );

    List<Color> list = [
      ZColors.primarySwatch,
      chigusa,
      Colors.blueGrey,
      pink,
      sparrowTea,
      crimson,
      copperGreen,
      Colors.teal,
      blackTheme,
    ];
    return list;
  }
}
