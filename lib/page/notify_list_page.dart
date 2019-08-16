import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/config/config.dart';
import 'package:github_app_flutter/common/dao/user_dao.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/model/EventViewModel.dart';
import 'package:github_app_flutter/widget/commit_item.dart';
import 'package:github_app_flutter/widget/dynamic_list_view.dart';
import 'package:github_app_flutter/model/Notification.dart' as Model;

/// 通知消息列表
/// Create by zyf
/// Date: 2019/8/15
class NotifyListPage extends StatefulWidget {
  final int selectIndex;

  NotifyListPage(this.selectIndex, {Key key}) : super(key: key);

  @override
  NotifyListPageState createState() => NotifyListPageState();
}

class NotifyListPageState extends State<NotifyListPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();

  int _page = 1;

  bool _isComplete = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: DynamicListView.build(
        itemBuilder: _renderItem(),
        dataRequester: _dataRequester,
        initRequester: _initRequester,
        dividerColor: Theme.of(context).dividerColor,
        isLoadComplete: _isComplete,
        refreshKey: refreshKey,
        emptyText: '暂无消息',
      ),
    );
  }

  _renderItem() => (List dataList, BuildContext context, int index) {
        Model.Notification notification = dataList[index];
        EventViewModel model = EventViewModel.fromNotify(notification);
        return CommitItem(model, onPressed: () {
          if (notification.unread) {
            UserDao.setNotificationAsRead(notification.id);
          }
          if (notification.subject.type == 'Issue') {
            String url = notification.subject.url;
            List<String> tmp = url.split('/');
            String number = tmp[tmp.length - 1];
            String username = notification.repository.owner.login;
            String reposName = notification.repository.name;
            NavigatorUtils.goIssueDetail(context, username, reposName, number)
                .then((res) {
              showRefreshLoading();
            });
          }
        });
      };

  ///刷新数据
  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  _initRequester() async {
    _page = 1;
    return await _getSearchResult();
  }

  _dataRequester() async {
    _page++;
    return await _getSearchResult();
  }

  ///获取搜索结果
  _getSearchResult() async {
    return await UserDao.getNotify(
            widget.selectIndex == 2, widget.selectIndex == 2, _page)
        .then((res) {
      if (!res.result) {
        _page--;
      }
      setState(() {
        _isComplete = (res.result && res.data.length < Config.PAGE_SIZE);
      });
      return res.data ?? List();
    });
  }
}
