import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// 弹框工具类
/// Create by zyf
/// Date: 2019/8/2
///显示加载中进度框
class DialogUtils {
  static Future<Null> showLoadingDialog(BuildContext context) {
    return showAppDialog(
        context: context,
        builder: (BuildContext context) {
          return Material(
            color: Colors.transparent,
            child: WillPopScope(
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: SpinKitCircle(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          '加载中...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              onWillPop: () => Future.value(false),
            ),
          );
        });
  }

  static showColorDialog(
      BuildContext context, List<Color> colorList, ValueChanged<int> onTap) {
    DialogUtils.showAppDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            width: 270,
            height: 280,
            decoration: new BoxDecoration(
              color: Colors.white,
              //用一个BoxDecoration装饰器提供背景图片
              borderRadius: BorderRadius.circular(10),
            ),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                return RawMaterialButton(
                  constraints: BoxConstraints(minWidth: 0, minHeight: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 3),
                        child: CircleAvatar(
                          backgroundColor: colorList[index],
                          radius: 25,
                        ),
                      ),
                      Text(
                        index == 0 ? '默认主题' : '主题$index',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(ZColors.textSecondaryValue),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    onTap(index);
                  },
                );
              },
              itemCount: colorList.length,
            ),
          ),
        );
      },
    );
  }

  ///列表item dialog
  static Future<Null> showCommitOptionDialog(
    BuildContext context,
    List<String> commitMaps,
    ValueChanged<int> onTap, {
    width = 250.0,
    height = 400.0,
    List<Color> colorList,
  }) {
    return showAppDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: new Container(
              width: width,
              height: height,
              padding: new EdgeInsets.all(4.0),
              margin: new EdgeInsets.all(20.0),
              decoration: new BoxDecoration(
                color: Colors.white,
                //用一个BoxDecoration装饰器提供背景图片
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: new ListView.builder(
                  itemCount: commitMaps.length,
                  itemBuilder: (context, index) {
                    return RaisedButton(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      textColor: Colors.white,
                      color: colorList != null
                          ? colorList[index]
                          : Theme.of(context).primaryColor,
                      child: Text(
                        commitMaps[index],
                        style: TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onTap(index);
                      },
                    );
                  }),
            ),
          );
        });
  }

  ///弹出dialog
  static Future<T> showAppDialog<T>({
    @required BuildContext context,
    bool barrierDismissible = true,
    WidgetBuilder builder,
  }) {
    return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return MediaQuery(
            ///不受系统字体缩放影响
            data: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .copyWith(textScaleFactor: 1),
            child: SafeArea(child: builder(context)),
          );
        });
  }
}
