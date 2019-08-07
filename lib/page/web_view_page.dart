import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:github_app_flutter/widget/common_option_widget.dart';

/// webView页面
/// Create by zyf
/// Date: 2019/8/6
class WebViewPage extends StatelessWidget {
  final String url;

  final String title;

  final OptionControl optionControl = new OptionControl();

  WebViewPage(this.url, this.title);

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: _renderTitle(),
      url: url,
      scrollBar: true,
      withJavascript: true,
      withLocalUrl: true,
    );
  }

  _renderTitle() {
    if (url == null || url.length == 0) {
      return AppBar(
        title: Text(title),
      );
    }
    optionControl.url = url;
    return AppBar(
      title: Container(),
      actions: <Widget>[
        CommonOptionWidget(optionControl),
      ],
    );
  }
}
