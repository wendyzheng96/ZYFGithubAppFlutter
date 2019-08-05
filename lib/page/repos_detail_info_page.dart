import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/repos_dao.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/Event.dart';
import 'package:github_app_flutter/model/EventViewModel.dart';
import 'package:github_app_flutter/model/RepoCommit.dart';
import 'package:github_app_flutter/page/repository_detail_page.dart';
import 'package:github_app_flutter/widget/commit_item.dart';
import 'package:github_app_flutter/widget/event_item.dart';
import 'package:github_app_flutter/widget/repos_header_item.dart';
import 'package:github_app_flutter/widget/select_item_widget.dart';
import 'package:github_app_flutter/widget/sliver_header_delegate.dart';
import 'package:scoped_model/scoped_model.dart';

/// 仓库信息详情页面
/// Create by zyf
/// Date: 2019/7/26
class ReposDetailInfoPage extends StatefulWidget {
  final String username;

  final String reposName;

  ReposDetailInfoPage(this.username, this.reposName, {Key key})
      : super(key: key);
  @override
  _ReposDetailInfoPageState createState() => _ReposDetailInfoPageState();
}

class _ReposDetailInfoPageState extends State<ReposDetailInfoPage>
    with AutomaticKeepAliveClientMixin<ReposDetailInfoPage> {
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();

  bool isShow = false;

  ///初始化 header 默认大小，后面动态调整
  double headerSize = 250;

  ///滑动监听
  ScrollController _controller = ScrollController();

  int selectIndex = 0;

  bool isPerformingRequest = false;

  int page = 1;

  List<Event> eventList = List();

  List<RepoCommit> commitList = List();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    isShow = true;
    super.initState();
    showRefreshLoading();
    _getReposDetail();
    _onRefresh();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScopedModelDescendant<ReposDetailModel>(
      builder: (context, child, model) {
        return Scaffold(
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
                        child: ReposHeaderItem(
                          ReposHeaderViewModel.fromHttpMap(
                              widget.username,
                              widget.reposName,
                              ReposDetailModel.of(context).repository),
                          layoutListener: (size) {
                            setState(() {
                              headerSize = size.height;
                            });
                          },
                        ))),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverHeaderDelegate(
                      minHeight: 60,
                      maxHeight: 60,
                      child: SizedBox.expand(
                          child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: SelectItemWidget(
                          ['动态', '提交'],
                          (index) {
                            _controller
                                .animateTo(0,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.bounceInOut)
                                .then(
                              (_) {
                                selectIndex = index;
                                clearData();
                                showRefreshLoading();
                                _getDataLogic();
                              },
                            );
                          },
                          margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                        ),
                      ))),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return itemBuilder(context, index);
                    },
                    childCount: selectIndex == 1
                        ? commitList.length + 1
                        : eventList.length + 1,
                  ),
                ),
              ],
            ),
            onRefresh: _onRefresh,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    isShow = false;
    super.dispose();
  }

  ///设置布局
  itemBuilder(BuildContext context, int index) {
    if (selectIndex == 1) {
      if (index == commitList.length) {
        return opacityLoadingProgress(
            isPerformingRequest, Theme.of(context).primaryColor);
      }
      ///提交
      EventViewModel model = EventViewModel.fromCommitMap(commitList[index]);
      return CommitItem(
        model,
        needImage: false,
        onPressed: (){
          NavigatorUtils.goPushDetailPage(context, widget.username,
              widget.reposName, commitList[index].sha, false);
        },
      );
    }
    if (index == eventList.length) {
      return opacityLoadingProgress(
          isPerformingRequest, Theme.of(context).primaryColor);
    }
    ///动态
    EventViewModel model = EventViewModel.fromEventMap(eventList[index]);
    return EventItem(model, index, eventList.length);
  }

  ///加载更多布局
  Widget opacityLoadingProgress(isPerformingRequest, loadingColor) {
    return Padding(
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

  ///获取仓库详情
  _getReposDetail() {
    ReposDao.getReposDetail(widget.username, widget.reposName,
            ReposDetailModel.of(context).currentBranch)
        .then((res) {
      if (res != null && res.result) {
        ReposDetailModel.of(context).repository = res.data;
        return res.next();
      }
      return Future.value(null);
    }).then((res) {
      if (res != null && res.result) {
        if (!isShow) {
          return;
        }
        ReposDetailModel.of(context).repository = res.data;
      }
    });
  }

  /// 刷新 数据初始化
  Future<Null> _onRefresh() async {
    page = 1;
    await _getDataLogic();
  }

  /// 加载更多数据
  _loadMore() async {
    this.setState(() => isPerformingRequest = true);
    page++;
    await _getDataLogic();
    this.setState(() => isPerformingRequest = false);
  }

  ///获取列表
  _getDataLogic() async {
    if (selectIndex == 1) {
      ///获取提交列表
      await ReposDao.getReposCommits(
        widget.username,
        widget.reposName,
        page: page,
        branch: ReposDetailModel.of(context).currentBranch,
        needDb: page <= 1,
      ).then((res) {
        setState(() {
          if (page == 1) {
            commitList = res.data ?? List();
          } else {
            commitList.addAll(res.data);
          }
        });
      });
    } else {
      ///获取动态列表
      await ReposDao.getReposEvents(
        widget.username,
        widget.reposName,
        page: page,
        branch: ReposDetailModel.of(context).currentBranch,
        needDb: page <= 1,
      ).then((res) {
        setState(() {
          if (page == 1) {
            eventList = res.data ?? List();
          } else {
            eventList.addAll(res.data);
          }
        });
      });
    }
  }

  ///清空数据
  clearData() {
    if (isShow) {
      setState(() {
        eventList.clear();
        commitList.clear();
      });
    }
  }
}
