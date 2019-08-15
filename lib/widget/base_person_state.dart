import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/event_dao.dart';
import 'package:github_app_flutter/common/style/style.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/event_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/common/utils/time_utils.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/EventViewModel.dart';
import 'package:github_app_flutter/model/User.dart';
import 'package:github_app_flutter/widget/event_item.dart';
import 'package:github_app_flutter/widget/icon_text.dart';
import 'package:github_app_flutter/widget/sliver_header_delegate.dart';
import 'package:github_app_flutter/widget/user_header.dart';

/// 用户信息基础布局
/// Create by zyf
/// Date: 2019/8/6
abstract class BasePersonState<T extends StatefulWidget> extends State<T>
    with AutomaticKeepAliveClientMixin<T> {
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  ///滑动监听
  ScrollController controller = ScrollController();

  bool isPerformingRequest = false;

  ///是否加载完成
  bool _isComplete = false;

  int _page = 1;

  List<Event> eventList = List();

  @override
  bool get wantKeepAlive => true;

  @protected
  String getUsername();

  @protected
  Future refreshData();

  @override
  void initState() {
    super.initState();
    showRefreshLoading();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  ///显示刷新
  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  final double headerSize = 190;
  final double bottomSize = 50;
  @protected
  sliverBuilder(BuildContext context, User userInfo) {
    final double chartSize =
        (userInfo.login != null && userInfo.type == "Organization") ? 70 : 200;
    return RefreshIndicator(
      key: refreshKey,
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          ///头部信息
          SliverPersistentHeader(
              delegate: SliverHeaderDelegate(
                  minHeight: headerSize,
                  maxHeight: headerSize,
                  child: _userInfo(userInfo))),

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
                  return opacityLoadingProgress(
                      isPerformingRequest, Theme.of(context).primaryColor);
                }
                EventViewModel model =
                    EventViewModel.fromEventMap(eventList[index]);
                return EventItem(
                  model,
                  index,
                  eventList.length,
                  onPressed: () {
                    EventUtils.actionUtils(context, eventList[index], "");
                  },
                );
              },
              childCount: eventList.length + 1,
            ),
          ),
        ],
      ),
      onRefresh: onRefresh,
    );
  }

  //用户信息详情
  _userInfo(User user) {
    return Container(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
        color: Theme.of(context).primaryColor,
        child: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 20),
                  padding: EdgeInsets.all(3),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.avatarUrl ?? ""),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(43),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      user.login ?? "---",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 6, bottom: 8),
                      child: Text(
                        user.email ?? "---",
                        style: ZStyles.smallerTextWhite70,
                      ),
                    ),
                    IconText(
                      user.location ?? "---",
                      Icons.location_on,
                      ZStyles.smallerTextWhite70,
                      padding: 4,
                      iconColor: Colors.white,
                      iconSize: 14,
                    ),
                    Container(
                      height: 6,
                    ),
                    IconText(
                      user.company ?? "---",
                      Icons.group,
                      ZStyles.smallerTextWhite70,
                      padding: 4,
                      iconColor: Colors.white,
                      iconSize: 14,
                    ),
                  ],
                )
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: IconText(
                user.blog ?? "---",
                Icons.link,
                TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    decoration: TextDecoration.underline),
                iconColor: Colors.white,
                iconSize: 14,
                padding: 4,
                onPressed: (){
                  CommonUtils.launchOutURL(user.blog, context);
                },
              ),
            ),
            Text(
              user.bio ?? "---",
              style: ZStyles.smallerTextWhite70,
            ),
            Container(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '创建于 ${getDateStr(user.createdAt)}',
                style: ZStyles.smallerTextWhite70,
              ),
            )
          ],
        ));
  }

  //悬停模块
  Widget _userModules(User user) => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _getFunText('项目', user.publicRepos ?? "", () {
              NavigatorUtils.gotoCommonList(
                  context, user.login, "repository", "user_repos",
                  username: user.login);
            }),
            _getFunText('Stars', user.starred ?? "", () {
              NavigatorUtils.gotoCommonList(
                  context, user.login, "repository", "user_star",
                  username: user.login);
            }),
            _getFunText('关注', user.following ?? "", () {
              NavigatorUtils.gotoCommonList(
                  context, user.login, "user", "followed",
                  username: user.login);
            }),
            _getFunText('粉丝', user.followers ?? "", () {
              NavigatorUtils.gotoCommonList(
                  context, user.login, "user", "follower",
                  username: user.login);
            }),
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

  Widget _getFunText(String name, num, onPressed) => Expanded(
        child: RawMaterialButton(
          constraints: BoxConstraints(minWidth: 0, minHeight: bottomSize),
          onPressed: onPressed,
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
              '——到底线啦——',
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

  ///刷新 初始化数据
  Future<Null> onRefresh() async {
    _page = 1;
    await _getData();
    refreshData();
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
    await EventDao.getEventDao(getUsername(), page: _page).then((res) {
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
        setState(() {
          _isComplete =
              (res.data != null && res.data.length < Config.PAGE_SIZE);
        });
      });
    });
  }
}
