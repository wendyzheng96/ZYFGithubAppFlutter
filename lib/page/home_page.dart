import 'package:flutter/material.dart';
import 'package:github_app_flutter/page/dynamic_page.dart';
import 'package:github_app_flutter/page/mine_page.dart';
import 'package:github_app_flutter/page/trend_page.dart';

/// 主页
/// Create by zyf
/// Date: 2019/7/13
class HomePage extends StatefulWidget {
  static final String sName = 'home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _pages = [DynamicPage(), TrendPage(), MinePage()];
  int _tabIndex = 0;

  var _pageController = PageController();

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('GithubFlutter'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () {},
          )
        ],
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
              icon: Icon(Icons.dashboard), title: Text('动态')),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), title: Text('趋势')),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity), title: Text('我的')),
        ],
        selectedFontSize: 12,
        onTap: (index) {
          print('onTap');
          _pageController.jumpToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        currentIndex: _tabIndex,
      ),
    );
  }
}
