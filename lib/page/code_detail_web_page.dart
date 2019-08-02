import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/html_utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 文件代码详情
/// Create by zyf
/// Date: 2019/7/31
class CodeDetailWebPage extends StatefulWidget {
  final String username;

  final String reposName;

  final String path;

  final String data;

  final String title;

  final String branch;

  final String htmlUrl;

  CodeDetailWebPage(
      {this.username,
      this.reposName,
      this.path,
      this.data,
      this.title,
      this.branch,
      this.htmlUrl});

  @override
  _CodeDetailWebPageState createState() => _CodeDetailWebPageState(data);
}

class _CodeDetailWebPageState extends State<CodeDetailWebPage> {
  bool _isLoadSuccess = true;

  String data;

  _CodeDetailWebPageState(this.data);

  @override
  void initState() {
    super.initState();
    if (data == null) {
      ReposDao.getReposFileDir(widget.username, widget.reposName,
              path: widget.path,
              branch: widget.branch,
              text: true,
              isHtml: true)
          .then((res) {
        if (res != null && res.result) {
          String content = HtmlUtils.resolveHtmlFile(res, "java");
          String url = Uri.dataFromString(content,
                  mimeType: 'text/html', encoding: Encoding.getByName("utf-8"))
              .toString();
          setState(() {
            this.data = url;
            _isLoadSuccess = true;
          });
        } else {
          setState(() {
            _isLoadSuccess = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    if (data != null) {
      return WebView(
        initialUrl: data,
        javascriptMode: JavascriptMode.unrestricted,
      );
    }
    return _isLoadSuccess ? _emptyWidget() : _errorWidget();
  }

  ///空白布局
  Widget _emptyWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitCircle(
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              '努力加载中...',
              style: TextStyle(
                color: Color(ZColors.textSecondaryValue),
                fontSize: 14,
              ),
            ),
          )
        ],
      );

  ///加载失败布局
  Widget _errorWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              color: Color(ZColors.textHintValue),
              size: 50,
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '加载失败',
                style: TextStyle(
                  color: Color(ZColors.textSecondaryValue),
                  fontSize: 14,
                ),
              ),
            )
          ],
        ),
      );
}
