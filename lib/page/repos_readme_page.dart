import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// 仓库Readme介绍
/// Create by zyf
/// Date: 2019/7/27
class ReposReadmePage extends StatefulWidget {
  ///用户名
  final String username;

  ///仓库名
  final String reposName;

  ReposReadmePage(this.username, this.reposName);

  @override
  _ReposReadmePageState createState() => _ReposReadmePageState();
}

class _ReposReadmePageState extends State<ReposReadmePage>
    with AutomaticKeepAliveClientMixin {
  bool isShow = false;

  String markdownData;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    isShow = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget widget = (markdownData == null)
        ? Center(
            child: Container(
              width: 200,
              height: 200,
              padding: EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: SpinKitCircle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      '加载中...',
                      style: TextStyle(
                        color: Color(ZColors.textSecondaryValue),
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
    return widget;
  }

  @override
  void dispose() {
    isShow = false;
    super.dispose();
  }
}
