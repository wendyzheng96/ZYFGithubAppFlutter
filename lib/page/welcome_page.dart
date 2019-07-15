import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/page/login_page.dart';

/// 启动页
/// Create by zyf
/// Date: 2019/7/13
class WelcomePage extends StatefulWidget {
  static const String sName = '/';

  @override
  WelcomePageState createState() => WelcomePageState();
}

class WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  AnimationController controller;
  CurvedAnimation curve;
  bool hadInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (hadInit) {
      return;
    }
    hadInit = true;

    new Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      NavigatorUtils.pushReplaceNamed(context, LoginPage.sName);
      return true;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    curve = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(ZColors.white),
        child: Center(
          child: FadeTransition(
            opacity: curve,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  child: Image.asset('static/images/pic_github.png'),
                ),
                Text('Github Flutter', style: Constant.largeLargeText,)
              ],
            ),
          ),
        )
    );
  }
}
