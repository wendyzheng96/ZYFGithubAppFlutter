import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github_app_flutter/widget/common_option_widget.dart';
import 'package:photo_view/photo_view.dart';

/// 图片预览
/// Create by zyf
/// Date: 2019/7/31
class PhotoViewPage extends StatelessWidget {
  final String url;

  PhotoViewPage(this.url);

  @override
  Widget build(BuildContext context) {
    OptionControl optionControl = new OptionControl();
    optionControl.url = url;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xaa000000),
        title: Text(''),
        actions: <Widget>[
          CommonOptionWidget(optionControl),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: PhotoView(
          imageProvider: NetworkImage(url),
          loadingChild: Center(
            child: SpinKitCircle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.file_download),
        onPressed: () {},
      ),
    );
  }
}
