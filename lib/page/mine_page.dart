import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/left_line.dart';
import 'package:github_app_flutter/widget/user_header.dart';

/// 我的页面
/// Create by zyf
/// Date: 2019/7/15
class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  User userInfo = User.name('wendyzheng96');

  int listSize = 10;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    double headerSize = 170;
    double bottomSize = 56;
    double chartSize = 200;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              ///头部信息
              SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                      minHeight: headerSize,
                      maxHeight: headerSize,
                      child: _userInfoTop())),

              ///悬停item
              SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: _SliverAppBarDelegate(
                      minHeight: bottomSize,
                      maxHeight: bottomSize,
                      child: _userModules())),

              ///提交图表
              SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                      minHeight: chartSize,
                      maxHeight: chartSize,
                      child: SizedBox.expand(
                        child: Container(
                          height: chartSize,
                          child: UserHeaderChart(userInfo),
                        ),
                      ))),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return getItem(index);
                  },
                  childCount: listSize,
                ),
              ),
            ],
          ),
        ));
  }

  //用户信息详情
  Widget _userInfoTop() => Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              padding: EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                    'https://hbimg.huabanimg.com/0d2a3fca3b1829736261fdf7db36d8001ecb0ea715f10c-3Dv8Bn_fw658'),
              ),
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(44)),
            ),
            Text(
              'WendyYan',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Text(
                'WendyYan',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      );

  //悬停模块
  Widget _userModules() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _getFunText('仓库', 16),
            _getFunText('关注', 3),
            _getFunText('星标', 22),
            _getFunText('荣耀', 1),
            _getFunText('粉丝', 3),
          ],
        ),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                spreadRadius: 3,
                color: Color.fromARGB(50, 0, 0, 0),
              )
            ]),
        margin: EdgeInsets.only(bottom: 6),
      );

  Widget _getFunText(String name, int num) => Column(
        children: <Widget>[
          Text(
            name,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6, bottom: 10),
            child: Text(
              num.toString(),
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          )
        ],
      );

  //列表item 布局
  Widget getItem(int index) => Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 32,
                child: LeftLineWidget(index != 0, index != listSize - 1, false),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(ZColors.primaryValue),
                backgroundImage: NetworkImage(
                    'https://hbimg.huabanimg.com/b2c76a5f74dbfdcbf0c425e68f88e2d9fc20af561b779-LeAzGo_fw658'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'wendy$index',
                  style: TextStyle(
                      color: Color(ZColors.textPrimaryValue), fontSize: 14),
                ),
              ),
              Expanded(child: Container(
                padding: EdgeInsets.only(right: 16),
                alignment: Alignment.bottomRight,
                child: Text(
                  '2019/7/16 17:54',
                  style: TextStyle(
                      color: Color(ZColors.textHintValue), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              )),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                      width: 1,
                      color: index == listSize - 1
                          ? Colors.transparent
                          : Color(ZColors.lineColor))),
            ),
            margin: EdgeInsets.only(left: 23),
            padding: EdgeInsets.fromLTRB(22, 6, 16, 30),
            child: Text(
              '万物的怪物的鼓舞的怪物的怪物更多无辜的有关费用官方也发个衣服v。',
              style: TextStyle(
                  color: Color(ZColors.textSecondaryValue),
                  fontSize: 13,
              ),
            ),
          ),
        ],
      );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
