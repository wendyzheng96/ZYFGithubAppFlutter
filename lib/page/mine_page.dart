import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/event_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/zyf_state.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/EventViewModel.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/event_item.dart';
import 'package:github_app_flutter/widget/sliver_header_delegate.dart';
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
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  ///滑动监听
  ScrollController _controller = ScrollController();

  bool isPerformingRequest = false;

  ///是否加载完成
  bool _isComplete = false;

  int _page = 1;

  List<Event> eventList = List();

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
  void initState() {
    super.initState();
    showRefreshLoading();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onRefresh();
  }

  final double headerSize = 180;
  final double bottomSize = 50;
  final double chartSize = 200;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      child: StoreBuilder<ZYFState>(
        builder: (context, store) {
          User userInfo = store.state.userInfo;
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              body: RefreshIndicator(
                key: refreshKey,
                child: CustomScrollView(
                  controller: _controller,
                  slivers: <Widget>[
                    ///头部信息
                    SliverPersistentHeader(
                        delegate: SliverHeaderDelegate(
                            minHeight: headerSize,
                            maxHeight: headerSize,
                            child: _userInfoTop(userInfo))),

                    ///悬停item
                    SliverPersistentHeader(
                        pinned: true,
                        floating: true,
                        delegate: SliverHeaderDelegate(
                            minHeight: bottomSize,
                            maxHeight: bottomSize,
                            child: _userModules(userInfo))),

                    ///提交图表
                    SliverPersistentHeader(
                        delegate: SliverHeaderDelegate(
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
                          if (index == eventList.length) {
                            return opacityLoadingProgress(isPerformingRequest,
                                Theme.of(context).primaryColor);
                          }
                          EventViewModel model =
                              EventViewModel.fromEventMap(eventList[index]);
                          return EventItem(model, index, eventList.length);
                        },
                        childCount: eventList.length + 1,
                      ),
                    ),
                  ],
                ),
                onRefresh: _onRefresh,
              ),
            ),
          );
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
                style: ZStyles.smallerTextWhite70,
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
                      style: ZStyles.smallerTextWhite70,
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
                      style: ZStyles.smallerTextWhite70,
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
            _getFunText('项目', user.public_repos),
            _getFunText('Stars', user.starred),
            _getFunText('关注', user.following),
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

  Widget _getFunText(String name, num) => Expanded(
        child: RawMaterialButton(
          constraints: BoxConstraints(minWidth: 0, minHeight: bottomSize),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Container(
                margin: EdgeInsets.only(left: 4),
                padding: EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Text(
                  num.toString(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      );

  ///加载更多布局
  Widget opacityLoadingProgress(isPerformingRequest, loadingColor) {
    return _isComplete
        ? Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 5, bottom: 15),
            child: Text(
              '——我是有底线的——',
              style: ZStyles.smallTextHint,
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Opacity(
                opacity: isPerformingRequest ? 1.0 : 0.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                ),
              ),
            ),
          );
  }

  ///显示刷新
  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  ///刷新 初始化数据
  Future<void> _onRefresh() async {
    _page = 1;
    await _getData();
  }

  /// 加载更多数据
  _loadMore() async {
    if (!_isComplete) {
      this.setState(() => isPerformingRequest = true);
      _page++;
      await _getData();
      this.setState(() => isPerformingRequest = false);
    }
  }

  /// 获取数据
  _getData() async {
    await EventDao.getEventDao(_getUsername(), page: _page, needDb: _page <= 1)
        .then((res) {
      setState(() {
        if (res.result) {
          if (_page == 1) {
            eventList = res.data;
          } else {
            eventList.addAll(res.data);
          }
        } else {
          _page--;
        }
        _isComplete = (res.data != null && res.data.length < Config.PAGE_SIZE);
      });
    });
  }
}
