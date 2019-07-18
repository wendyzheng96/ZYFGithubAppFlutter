import 'package:flutter/material.dart';

/// 资源
/// Create by zyf
/// Date: 2019/7/13

///颜色
class ZColors {
  static const String primaryValueString = "#5098d4";
  static const String primaryLightValueString = "#9bcdf0";
  static const String primaryDarkValueString = "#437fb1";
  static const String miWhiteString = "#ececec";
  static const String actionBlueString = "#267aff";
  static const String webDraculaBackgroundColorString = "#282a36";

  static const int primaryValue = 0xff5098d4;
  static const int primaryLightValue = 0xFF9bcdf0;
  static const int primaryDarkValue = 0xFF437fb1;

  static const int textPrimaryValue = 0xff333333;
  static const int textSecondaryValue = 0xff586069;
  static const int textHintValue = 0xff999999;
  static const int textColorWhite = 0xFFFFFFFF;

  static const int lineColor = 0x55B0C4DE;
  static const int miWhite = 0xffececec;
  static const int subTextColor = 0xff959595;
  static const int subLightTextColor = 0xffc4c4c4;

  static const int mainBackgroundColor = miWhite;

  static const MaterialColor primarySwatch = const MaterialColor(
    primaryValue,
    const <int, Color>{
      50: const Color(primaryLightValue),
      100: const Color(primaryLightValue),
      200: const Color(primaryLightValue),
      300: const Color(primaryLightValue),
      400: const Color(primaryLightValue),
      500: const Color(primaryValue),
      600: const Color(primaryDarkValue),
      700: const Color(primaryDarkValue),
      800: const Color(primaryDarkValue),
      900: const Color(primaryDarkValue),
    },
  );
}

///文本样式
class ZStyles {

  static const String app_default_share_url = "https://github.com/wendyzheng96/ZYFGithubAppFlutter";

  static const lagerTextSize = 30.0;
  static const bigTextSize = 23.0;
  static const normalTextSize = 18.0;
  static const middleTextWhiteSize = 16.0;
  static const smallTextSize = 14.0;
  static const minTextSize = 12.0;

  static const minTextSecondary = TextStyle(
    color: Color(ZColors.textSecondaryValue),
    fontSize: minTextSize
  );

  static const minTextHint = TextStyle(
      color: Color(ZColors.textHintValue),
      fontSize: minTextSize
  );

  static const middleTextWhite = TextStyle(
    color: Color(ZColors.textColorWhite),
    fontSize: middleTextWhiteSize,
  );
}