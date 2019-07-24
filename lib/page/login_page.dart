import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/user_dao.dart';
import 'package:github_app_flutter/common/local/local_storage.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
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

  bool _isObscure = true;

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
    return StoreBuilder<ZYFState>(
      builder: (context, store) {
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
                        loginButton(store),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget loginUserInput() => Container(
        padding: EdgeInsets.fromLTRB(35, 0, 50, 5),
        child: TextField(
          controller: userController,
          decoration: InputDecoration(
            hintText: '请输入用户名',
            icon: Icon(
              Icons.person,
              color: Color(ZColors.primaryValue),
              size: 20,
            ),
          ),
          onChanged: (String value) {
            _username = value;
          },
        ),
      );

  Widget loginPwdInput() => Container(
        padding: EdgeInsets.fromLTRB(35, 10, 50, 5),
        child: TextField(
          controller: pwdController,
          decoration: InputDecoration(
              hintText: '请输入密码',
              icon: Icon(
                Icons.lock,
                color: Color(ZColors.primaryValue),
                size: 20,
              ),
              suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Color(ZColors.primaryValue),
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  })),
          obscureText: _isObscure,
          onChanged: (String value) {
            _password = value;
          },
        ),
      );

  Widget loginButton(store) {
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
            if (_username == null || _username.isEmpty) {
              CommonUtils.showToast('用户名不能为空');
              return;
            }
            if (_password == null || _password.isEmpty) {
              CommonUtils.showToast('密码不能为空');
              return;
            }
            CommonUtils.showLoadingDialog(context);
            UserDao.login(_username.trim(), _password.trim(), store)
                .then((res) {
              Navigator.pop(context);
              if (res != null && res.result) {
                Future.delayed(const Duration(seconds: 1), () {
                  NavigatorUtils.pushReplaceNamed(context, HomePage.sName);
                  return true;
                });
              }
            });
          }),
    );
  }
}
