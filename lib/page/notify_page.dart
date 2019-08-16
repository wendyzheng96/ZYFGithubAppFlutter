import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/dao/user_dao.dart';
import 'package:github_app_flutter/common/utils/dialog_utils.dart';
import 'package:github_app_flutter/page/notify_list_page.dart';

/// 通知
/// Create by zyf
/// Date: 2019/8/15
class NotifyPage extends StatefulWidget {
  @override
  _NotifyPageState createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  final List<String> types = ['未读', '参与', '所有'];

  final GlobalKey<NotifyListPageState> unreadKey = GlobalKey();

  final GlobalKey<NotifyListPageState> participateKey = GlobalKey();

  final GlobalKey<NotifyListPageState> allKey = GlobalKey();

  final PageController _pageController = PageController();

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: types.length, vsync: ScaffoldState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知'),
        actions: <Widget>[
          RawMaterialButton(
            onPressed: () {
              _setAllRead();
            },
            child: Text(
              '全标已读',
              style: Theme.of(context).primaryTextTheme.body1,
            ),
          )
        ],
        bottom: TabBar(
          tabs: types.map((String f) {
            return Text(f);
          }).toList(),
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          labelPadding: EdgeInsets.only(top: 10, bottom: 10),
          onTap: (index) {
            _pageController.jumpToPage(index);
          },
        ),
      ),
      body: PageView(
        children: <Widget>[
          NotifyListPage(0, key: unreadKey),
          NotifyListPage(1, key: participateKey),
          NotifyListPage(2, key: allKey)
        ],
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
      ),
    );
  }

  _setAllRead() async {
    DialogUtils.showLoadingDialog(context);
    await UserDao.setAllNotificationAsRead().then((res) {
      Navigator.pop(context);
      showRefreshData();
    });
  }

  ///刷新数据
  showRefreshData() {
    if (unreadKey.currentState != null && unreadKey.currentState.mounted) {
      unreadKey.currentState.showRefreshLoading();
    }
    if (participateKey.currentState != null &&
        participateKey.currentState.mounted) {
      participateKey.currentState.showRefreshLoading();
    }
    if (allKey.currentState != null && allKey.currentState.mounted) {
      allKey.currentState.showRefreshLoading();
    }
  }
}
