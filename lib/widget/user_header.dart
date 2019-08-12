import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/model/User.dart';

/// 用户
/// Create by zyf
/// Date: 2019/7/16
class UserHeaderChart extends StatelessWidget {
  final User userInfo;

  UserHeaderChart(this.userInfo);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Text(
              userInfo.type == 'Organization' ? '组织成员' : '个人动态',
              style: Theme.of(context).textTheme.title.copyWith(fontSize: 16),
            ),
            margin: EdgeInsets.fromLTRB(12, 10, 0, 10),
          ),
          _renderChart(context),
        ],
      ),
    );
  }

  _renderChart(BuildContext context) {
    double height = 130;
    double width = 3 * MediaQuery.of(context).size.width / 2;
    if (userInfo.login != null && userInfo.type == 'Organization') {
      return Container();
    }
    return (userInfo.login != null)
        ? Card(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                width: width,
                height: height,
                child: SvgPicture.network(
                  CommonUtils.getUserChartUrl(userInfo.login),
                  width: width,
                  height: height - 10,
                  allowDrawingOutsideViewBox: true,
                  placeholderBuilder: (context) => Container(
                    width: width,
                    height: height,
                    child: Center(
                      child: SpinKitRipple(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container(
            height: height,
            child: Center(
              child: SpinKitRipple(
                color: Theme.of(context).primaryColor,
              ),
            ),
          );
  }
}
