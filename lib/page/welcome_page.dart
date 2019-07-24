import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/dao/user_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/page/home_page.dart';
import 'package:github_app_flutter/page/login_page.dart';
import 'package:redux/redux.dart';

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

    ///防止多次进入
    Store<ZYFState> store = StoreProvider.of(context);
    new Future.delayed(const Duration(seconds: 2, milliseconds: 500), () {
      UserDao.initUserInfo(store).then((res) {
        if (res != null && res.result) {
          NavigatorUtils.pushReplaceNamed(context, HomePage.sName);
        } else {
          NavigatorUtils.pushReplaceNamed(context, LoginPage.sName);
        }
      });
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
        color: Colors.white,
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
                Text(
                  'Github Flutter',
                  style: TextStyle(
                    color: Color(ZColors.primaryValue),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
