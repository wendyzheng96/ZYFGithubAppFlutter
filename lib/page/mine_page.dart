import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/dao/event_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/widget/event_item.dart';
import 'package:github_app_flutter/widget/left_line.dart';
import 'package:github_app_flutter/widget/user_header.dart';
import 'package:redux/redux.dart';

/// 我的页面
/// Create by zyf
/// Date: 2019/7/15
class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  List<Event> eventList = List();

  int _page = 1;

  bool isLoading = false; //是否正在刷新数据

  @override
  bool get wantKeepAlive => true;

  Store<ZYFState> _getStore() {
    return StoreProvider.of(context);
  }

  ///从全局状态中获取我的用户名
  _getUsername() {
    if (_getStore()?.state?.userInfo == null) {
      return null;
    }
    return _getStore()?.state?.userInfo?.login;
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double headerSize = 190;
    double bottomSize = 56;
    double chartSize = 200;

    return Material(
      child: StoreBuilder<ZYFState>(
        builder: (context, store) {
          User userInfo = store.state.userInfo;
          return DefaultTabController(
              length: 2,
              child: Scaffold(
                  body: RefreshIndicator(
                child: CustomScrollView(
                  slivers: <Widget>[
                    ///头部信息
                    SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                            minHeight: headerSize,
                            maxHeight: headerSize,
                            child: _userInfoTop(userInfo))),

                    ///悬停item
                    SliverPersistentHeader(
                        pinned: true,
                        floating: true,
                        delegate: _SliverAppBarDelegate(
                            minHeight: bottomSize,
                            maxHeight: bottomSize,
                            child: _userModules(userInfo))),

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
                          EventViewModel model =
                              EventViewModel.fromEventMap(eventList[index]);
                          return EventItem(model, index, eventList.length);
                        },
                        childCount: eventList.length,
                      ),
                    ),
                  ],
                ),
                onRefresh: _onRefresh,
              )));
        },
      ),
    );
  }

  //用户信息详情
  Widget _userInfoTop(User user) => Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              padding: EdgeInsets.all(4),
              child: CircleAvatar(
                  radius: 40, backgroundImage: NetworkImage(user.avatar_url)),
              decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(44)),
            ),
            Text(
              user.login,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: EdgeInsets.only(top: 6, bottom: 6),
              child: Text(
                user.email,
                style: ZStyles.smallTextWhite70,
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      user.location ?? "---",
                      maxLines: 1,
                      style: ZStyles.smallTextWhite70,
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  Icon(
                    Icons.group,
                    size: 14,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      user.company ?? "---",
                      maxLines: 1,
                      style: ZStyles.smallTextWhite70,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );

  //悬停模块
  Widget _userModules(User user) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _getFunText('仓库', user.public_repos),
            _getFunText('关注', user.following),
            _getFunText('星标', user.starred),
            _getFunText('荣耀', 1),
            _getFunText('粉丝', user.followers),
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

  Widget _getFunText(String name, num) => Column(
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

  Future<void> _onRefresh() async {
    _page = 1;
    await getData();
  }

  /// 获取数据
  getData() async {
    await EventDao.getEventDao(_getUsername(), page: _page, needDb: _page <= 1)
        .then((res) {
      setState(() {
        if(_page == 1){
          eventList = res.data;
        } else{
          eventList.addAll(res.data);
        }
        print('下拉刷新结束');
      });
    });
  }
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
