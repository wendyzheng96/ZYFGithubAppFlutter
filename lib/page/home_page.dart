import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/utils/common_utils.dart';
import 'package:github_app_flutter/common/utils/navigator_utils.dart';
import 'package:github_app_flutter/page/dynamic_page.dart';
import 'package:github_app_flutter/page/mine_page.dart';
import 'package:github_app_flutter/page/search_page.dart';
import 'package:github_app_flutter/page/trend_page.dart';
import 'package:github_app_flutter/widget/home_drawer.dart';

/// 主页
/// Create by zyf
/// Date: 2019/7/13
class HomePage extends StatefulWidget {
  static final String sName = 'home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _pages = [TrendPage(), DynamicPage(), MinePage()];

  int _tabIndex = 0;

  var _pageController = PageController();

  DateTime _lastPressedAt;

  void _pageChanged(int index) {
    print('_pageChanged');
    setState(() {
      if (_tabIndex != index) {
        _tabIndex = index;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        drawer: HomeDrawer(),
        appBar: AppBar(
          elevation: 0,
          title: Text('GithubFlutter'),
          actions: <Widget>[_getActionButton()],
        ),
        body: PageView.builder(
            physics: NeverScrollableScrollPhysics(), //禁止页面左右滑动切换
            controller: _pageController,
            onPageChanged: _pageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) => _pages[index]),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.trending_up), title: Text('趋势')),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera),
              title: Text('动态'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity),
              title: Text('我的'),
            ),
          ],
          selectedFontSize: 12,
          onTap: (index) {
            print('onTap');
            _pageController.jumpToPage(index);
          },
          type: BottomNavigationBarType.fixed,
          currentIndex: _tabIndex,
        ),
      ),
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt) > Duration(seconds: 1)) {
          ///两次点击间隔超过1秒则重新计时
          _lastPressedAt = DateTime.now();
          CommonUtils.showToast('再按一次退出程序');
          return false;
        }
        return true;
      },
    );
  }

  Widget _getActionButton() {
    switch (_tabIndex) {
      case 0:
      case 1:
        return IconButton(
          icon: const Icon(Icons.search),
          tooltip: '搜索',
          onPressed: () {
            NavigatorUtils.navigatorRouter(context, SearchPage());
          },
        );
      case 2:
        return IconButton(
          icon: const Icon(Icons.notifications),
          tooltip: '通知',
          onPressed: () {},
        );
      default:
        return null;
    }
  }
}
