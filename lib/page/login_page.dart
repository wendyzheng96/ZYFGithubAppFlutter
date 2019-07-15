import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/local/local_storage.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/page/home_page.dart';

/// 登录页面
/// Create by zyf
/// Date: 2019/7/15
class LoginPage extends StatefulWidget {
  static const String sName = "login";

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _username = '';
  var _password = '';

  final TextEditingController userController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();

  _LoginPageState() : super();

  @override
  void initState() {
    super.initState();
    initParams();
  }

  void initParams() async {
    _username = await LocalStorage.get(Config.USERNAME);
    _password = await LocalStorage.get(Config.PWD);
    userController.value = TextEditingValue(text: _username ?? "");
    pwdController.value = TextEditingValue(text: _password ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Image.asset(
                  'static/images/img_wave.png',
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    loginTopImg(),
                    loginUserInput(),
                    loginPwdInput(),
                    loginButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginTopImg() {
    return Container(
      padding: EdgeInsets.only(top: 80, bottom: 40),
      child: Image.asset(
        'static/images/ic_github.png',
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget loginUserInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 50, 5),
      child: Stack(
        alignment: Alignment(1.0, 1.0),
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(15),
                child: Icon(
                  Icons.person,
                  color: Color(ZColors.primaryValue),
                  size: 20,
                ),
              ),
              Expanded(
                  child: TextField(
                controller: userController,
                decoration: InputDecoration(
                  hintText: '请输入用户名',
                ),
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget loginPwdInput() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 50, 0),
      child: new Stack(
        alignment: Alignment(1.0, 1.0),
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Icon(
                    Icons.lock,
                    color: Color(ZColors.primaryValue),
                    size: 20,
                  )),
              Expanded(
                  child: new TextField(
                controller: pwdController,
                decoration: new InputDecoration(hintText: "请输入密码"),
                obscureText: true,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget loginButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(45, 40, 45, 10),
      width: double.infinity,
      height: 44,
      child: RaisedButton(
          child: Text(
            '登录',
            style: TextStyle(fontSize: 16),
          ),
          color: Color(ZColors.primaryValue),
          highlightColor: Color(ZColors.primaryDarkValue),
          shape: StadiumBorder(),
          textColor: Colors.white,
          onPressed: () {
            NavigatorUtils.pushReplaceNamed(context, HomePage.sName);
          }),
    );
  }
}
